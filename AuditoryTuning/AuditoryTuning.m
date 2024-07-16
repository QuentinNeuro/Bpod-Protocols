function AuditoryTuning

global BpodSystem nidaq S

%% Define parameters

S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
ParamPC=BpodParam_PCdep();
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    AuditoryTuning_TaskParameters(ParamPC);
end

% Initialize parameter GUI plugin and Pause
BpodParameterGUI('init', S);
BpodSystem.Pause=1;
HandlePauseCondition;
S = BpodParameterGUI('sync', S);

% Auto GUI select for pairing
if S.GUI.Optogenetic && S.GUI.Opto_Pairing
    S.GUI=Bpod_GUI_StimPairing(S.GUI,'AuditoryTuning');
    S = BpodParameterGUI('sync', S);
    BpodSystem.Pause=1;
    HandlePauseCondition;
end

%% Define stimuli and send to sound server
TrialSequence=[];
SoundStruct=struct();

if S.GUI.WhiteNoise
    TrialSequence=[TrialSequence 1];
    SoundStruct.Sound_1=WhiteNoiseGenerator(S.GUI.SoundSamplingRate,S.GUI.SoundDuration_wn,S.GUI.SoundRamp_wn);
    S.TrialsNames{1}='WhiteNoise';
end

if S.GUI.Sweeps
	TrialSequence=[TrialSequence 2 3];
    TimeSound=0:1/S.GUI.SoundSamplingRate:S.GUI.SoundDuration_s;
    SoundStruct.Sound_2=chirp(TimeSound,S.GUI.LowFreq_s,S.GUI.SoundDuration_s,S.GUI.HighFreq_s);
    SoundStruct.Sound_3=chirp(TimeSound,S.GUI.HighFreq_s,S.GUI.SoundDuration_s,S.GUI.LowFreq_s);
    
    TempNameSound=sprintf('%.0f Hz to %.0f Hz',S.GUI.LowFreq_s, S.GUI.HighFreq_s);
    S.TrialsNames{2}=TempNameSound;
	TempNameSound=sprintf('%.0f Hz to %.0f Hz',S.GUI.HighFreq_s, S.GUI.LowFreq_s);
    S.TrialsNames{3}=TempNameSound;
end

if S.GUI.PureTones
    Tones=logspace(log10(S.GUI.LowFreq_pt),log10(S.GUI.HighFreq_pt),S.GUI.NbOfTones);
    counter=4;
    for i=1:S.GUI.NbOfTones
        TrialSequence=[TrialSequence counter];
        thisSound=sprintf('Sound_%.0f',counter);
        SoundStruct.(thisSound)=SoundGenerator(S.GUI.SoundSamplingRate,Tones(i),1,1,S.GUI.SoundDuration_pt,S.GUI.SoundRamp_pt);
        TempNameSound=sprintf('%.0f Hz',Tones(i));
        S.TrialsNames{counter}=TempNameSound;
        
        counter=counter+1;
    end
end

fieldSound=fieldnames(SoundStruct);
for thisS=1:length(fieldSound)
    thisField=fieldSound{thisS};
    SoundStruct.(thisField)=SoundStruct.(thisField)*S.GUI.intensityFactor;
end

PsychToolboxSoundServer('init')
for i=TrialSequence
    thisSound=sprintf('Sound_%.0d',i);
    PsychToolboxSoundServer('Load',i,SoundStruct.(thisSound));
end
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';

%% Stimulation
BNCpp=0;
if S.GUI.Optogenetic
    BNCpp=ParamPC.BPPP_BNC;
    PulsePal(ParamPC.PPCOM);
    S.PulsePalProtocol=S.Names.PPProtocols{S.GUI.PulsePalProtocol};
    load(S.PulsePalProtocol);
    S.ParameterMatrix=ParameterMatrix;
    ProgramPulsePal(ParameterMatrix);
    for i=TrialSequence
        S.TrialsNames{i}=[S.TrialsNames{i} 'Stim'];
    end
end

%% Define trial types parameters, trial sequence
TrialSequence=TrialSequence(randperm(length(TrialSequence)));
TrialSequence=repmat(TrialSequence',S.GUI.Repetition,1);
S.TrialSequence=TrialSequence;
S.NumTrialTypes=max(TrialSequence);
S.MaxTrials=length(TrialSequence);

%% NIDAQ Initialization and Plots
if S.GUI.Photometry || S.GUI.Wheel
    if (S.GUI.DbleFibers+S.GUI.Isobestic405+S.GUI.RedChannel)*S.GUI.Photometry >1
        disp('Error - Incorrect photometry recording parameters')
        return
    end
    Nidaq_photometry('ini',ParamPC);
end
[FigPhoto1,FigPhoto2,FigWheel]=Online_NidaqPlots('ini');
%% Bonsai
if S.GUI.Bonsai
    BpodSystem.Pause=1;
    disp('Adjust ROI - resume when ready');
    success=Bpod2Bonsai_Quentin()
    HandlePauseCondition;
end

%% Main trial loop
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.
for currentTrial = 1:S.MaxTrials
%% Initialize current trial parameters
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    S.Sound=TrialSequence(currentTrial);
    
%% Assemble State matrix
 	sma = NewStateMatrix();
    %Pre Cue Delivery
    sma = AddState(sma, 'Name','PreCueState',...
        'Timer',S.GUI.TimePreCue,...
        'StateChangeConditions',{'Tup','CueDelivery'},...
        'OutputActions',{'BNCState',1});
    %Cue Delivery
    sma=AddState(sma,'Name', 'CueDelivery',...
        'Timer',S.GUI.TimeCue,...
        'StateChangeConditions',{'Tup', 'PostCueState'},...
        'OutputActions', {'SoftCode',S.Sound,'BNCState',BNCpp});
    %Post Cue Delivery
    sma=AddState(sma,'Name', 'PostCueState',...
        'Timer',S.GUI.TimePostCue,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {});
    
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
        BpodSystem.Data.NidaqData{currentTrial} = PhotoData;
        if S.GUI.DbleFibers || S.GUI.RedChannel
            BpodSystem.Data.Nidaq2Data{currentTrial}=Photo2Data;
        end
    end
    if S.GUI.Wheel
        BpodSystem.Data.NidaqWheelData{currentTrial} = WheelData;
    end
end
%% Save
if ~isempty(fieldnames(RawEvents))                                          % If trial data was returned
    BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);            % Computes trial events from raw data
    BpodSystem.Data.TrialSettings(currentTrial) = S;                        % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
    BpodSystem.Data.TrialTypes(currentTrial) = TrialSequence(currentTrial); % Adds the trial type of the current trial to data
    SaveBpodSessionData;                                                    % Saves the field BpodSystem.Data to the current data file
end

%% PLOT - extract events from BpodSystem.data and update figures
try
[FigPhoto1,FigPhoto2,FigWheel]=Online_NidaqPlots('update',FigPhoto1,FigPhoto2,FigWheel,[]);
catch
    disp('Oups, something went wrong with the online analysis... May be you closed a plot ?') 
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
try
Analysis_Photometry_Launcher;
catch
    disp('Post recording analysis failed - check whether analysis pipeline is present')
end
end
