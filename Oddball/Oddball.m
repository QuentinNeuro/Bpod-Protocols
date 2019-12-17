function Oddball
%Functions used in this protocol:
%"Oddball_Phase": specify the phase of the training
%"Oddball_SequenceGenerator" : generate random trials sequence
%
%
global BpodSystem S

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
ParamPC=BpodParam_PCdep();
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    Oddball_TaskParameters(ParamPC);
end

% Initialize parameter GUI plugin and Pause
BpodParameterGUI('init', S);
BpodSystem.Pause=1;
HandlePauseCondition;
S = BpodParameterGUI('sync', S);

%% Define stimuli and send to sound server
S.SoundFreq2=S.GUI.SoundFrequency*sqrt(2);
TimeSound=0:1/S.GUI.SoundSamplingRate:S.GUI.SoundDuration;
HalfTimeSound=0:1/S.GUI.SoundSamplingRate:S.GUI.SoundDuration/2;
WhiteNoise=WhiteNoiseGenerator(S.GUI.SoundSamplingRate,S.GUI.SoundDuration,0);
switch S.GUI.CueType
    case 1 % Chirp/sweep
        CueA=chirp(TimeSound,S.GUI.LowFreq,S.GUI.SoundDuration,S.GUI.HighFreq);
        CueB=chirp(TimeSound,S.GUI.HighFreq,S.GUI.SoundDuration,S.GUI.LowFreq);
        CueC=[chirp(HalfTimeSound,S.GUI.LowFreq,S.GUI.SoundDuration/2,S.GUI.HighFreq) chirp(HalfTimeSound,S.GUI.HighFreq,S.GUI.SoundDuration/2,S.GUI.LowFreq)];
    
    case 2
        CueA=SoundGenerator(S.GUI.SoundSamplingRate,S.GUI.SoundFrequency,S.GUI.FreqWidth,S.GUI.NbOfFreq,S.GUI.SoundDuration,S.GUI.SoundRamp);
        CueB=SoundGenerator(S.GUI.SoundSamplingRate,S.SoundFreq2,S.GUI.FreqWidth,S.GUI.NbOfFreq,S.GUI.SoundDuration,S.GUI.SoundRamp);
end

PsychToolboxSoundServer('init');
PsychToolboxSoundServer('Load', 1, CueA);
PsychToolboxSoundServer('Load', 2, CueB);
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';

%% Define trial types parameters and block sequence
[P, S.TrialsNames]=Oddball_Phase(S.Names.Phase{S.GUI.Phase});

TrialSequence=ones(P.BlocksNb,1);
TrialSequence(1:ceil(P.BlocksNb/2))=2;
TrialSequence=TrialSequence(randperm(P.BlocksNb));

%% NIDAQ Initialization
if S.GUI.Photometry || S.GUI.Wheel
    Nidaq_photometry('ini',ParamPC);
end
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.
%% Main trial loop
for currentTrial = 1:P.BlocksNb
%% Initialize current trial parameters
fprintf('Block #_%.0d', currentTrial)
[S.SoundSequence,S.StateSequence]=Oddball_SequenceGenerator(S.GUI.MaxTrials,P.ProbaOdd,P.ConstraitBtw,P.ConstraintEnd);
switch TrialSequence(currentTrial)
    case 1
        S.Sound=[1 2];
    case 2
        S.Sound=[2 1];
end
S.ITI = 100;
while S.ITI > 3 * S.GUI.BlockITI
    S.ITI = exprnd(S.GUI.BlockITI);
end
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin 
    
%% Assemble State matrix
 	sma = NewStateMatrix();
    %Pre task states
    sma = AddState(sma, 'Name','PreState',...
        'Timer',1,...
        'StateChangeConditions',{'Tup',S.StateSequence{1}},...
        'OutputActions',{'BNCState',1});
    for i=1:length(S.SoundSequence)
        sma=AddState(sma,'Name',S.StateSequence{i},...
            'Timer',S.GUI.ITI,...
            'StateChangeConditions',{'Tup',S.StateSequence{i+1}},...
            'OutOutActions',{'SoftCode',S.Sound(S.SoundSequence(i))});
    end
    sma = AddState(sma,'Name', 'ITIBlock',...
        'Timer',S.ITI,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions',{});
    
    SendStateMatrix(sma);
 
%% NIDAQ Get nidaq ready to start
if S.GUI.Photometry || S.GUI.Wheel
     Nidaq_photometry('WaitToStart');
end
     RawEvents = RunStateMatrix;
    
%% NIDAQ Stop acquisition and save data in bpod structure
if S.GUI.Photometry || S.GUI.Wheel
    Nidaq_photometry('Stop');
    [PhotoData,WheelData,Photo2Data]=Nidaq_photometry('Save');
    if S.GUI.Photometry
        BpodSystem.Data.NidaqData{currentTrial}=PhotoData;
        if S.GUI.DbleFibers || S.GUI.RedChannel
            BpodSystem.Data.Nidaq2Data{currentTrial}=Photo2Data;
        end
    end
    if S.GUI.Wheel
        BpodSystem.Data.NidaqWheelData{currentTrial}=WheelData;
    end
end
%% Save
if ~isempty(fieldnames(RawEvents))                                          % If trial data was returned
    BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);            % Computes trial events from raw data
    BpodSystem.Data.TrialSettings(currentTrial) = S;                        % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
    BpodSystem.Data.TrialTypes(currentTrial) = TrialSequence(currentTrial); % Adds the trial type of the current trial to data
    SaveBpodSessionData;                                                    % Saves the field BpodSystem.Data to the current data file
end
%% Photometry QC
if currentTrial==1 && S.GUI.Photometry
    thismax=max(PhotoData(S.GUI.NidaqSamplingRate:S.GUI.NidaqSamplingRate*2,1))
    if thismax>4 || thismax<0.3
        disp('WARNING - Something is wrong with fiber #1 - run check-up! - unpause to ignore')
        BpodSystem.Pause=1;
        HandlePauseCondition;
    end
    if S.GUI.DbleFibers
    thismax=max(Photo2Data(S.GUI.NidaqSamplingRate:S.GUI.NidaqSamplingRate*2,1))
    if thismax>4 || thismax<0.3
        disp('WARNING - Something is wrong with fiber #2 - run check-up! - unpause to ignore')
        BpodSystem.Pause=1;
        HandlePauseCondition;
    end
    end
end
%% End of trial
HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
if BpodSystem.BeingUsed == 0
    return
end
end
display('Good Job Mouse')
end
