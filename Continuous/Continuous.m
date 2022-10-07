function Continuous
%Functions used in this protocol:
%"CuedReward_Phase": specify the phase of the training
%"WeightedRandomTrials" : generate random trials sequence

%"Online_LickPlot"      : initialize and update online lick and outcome plot
%"Online_LickEvents"    : extract the data for the online lick plot
%"Online_NidaqPlot"     : initialize and update online nidaq plot
%"Online_NidaqEvents"   : extract the data for the online nidaq plot

global BpodSystem nidaq S

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
ParamPC=BpodParam_PCdep();
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    Continuous_TaskParameters(ParamPC);
end 

% Initialize parameter GUI plugin and Pause
BpodParameterGUI('init', S);
BpodSystem.Pause=1;
HandlePauseCondition;
S = BpodParameterGUI('sync', S);

S.SmallRew  =   GetValveTimes(S.GUI.SmallReward, S.GUI.RewardValve);
S.InterRew  =   GetValveTimes(S.GUI.InterReward, S.GUI.RewardValve);
S.LargeRew  =   GetValveTimes(S.GUI.LargeReward, S.GUI.RewardValve);

%% Define stimuli and send to sound server
TimeSound=0:1/S.GUI.SoundSamplingRate:S.GUI.CueDuration;
HalfTimeSound=0:1/S.GUI.SoundSamplingRate:S.GUI.CueDuration/2;
WhiteNoise=WhiteNoiseGenerator(S.GUI.SoundSamplingRate,S.GUI.CueDuration,0);
switch S.GUI.CueType
    case 1 % Chirp/sweep
        CueA=chirp(TimeSound,S.GUI.LowFreq,S.GUI.CueDuration,S.GUI.HighFreq);
        CueB=chirp(TimeSound,S.GUI.HighFreq,S.GUI.CueDuration,S.GUI.LowFreq);
        CueC=[chirp(HalfTimeSound,S.GUI.LowFreq,S.GUI.CueDuration/2,S.GUI.HighFreq) chirp(HalfTimeSound,S.GUI.HighFreq,S.GUI.CueDuration/2,S.GUI.LowFreq)];
    case 2 % Tones
        CueA=SoundGenerator(S.GUI.SoundSamplingRate,S.GUI.LowFreq,S.GUI.FreqWidth,S.GUI.NbOfFreq,S.GUI.CueDuration,S.GUI.SoundRamp);
        CueB=SoundGenerator(S.GUI.SoundSamplingRate,S.GUI.HighFreq,S.GUI.FreqWidth,S.GUI.NbOfFreq,S.GUI.CueDuration,S.GUI.SoundRamp);
        CueC=SoundGenerator(S.GUI.SoundSamplingRate,(S.GUI.LowFreq+S.GUI.HighFreq)/2,S.GUI.FreqWidth,S.GUI.NbOfFreq,S.GUI.CueDuration,S.GUI.SoundRamp);
    otherwise % WhiteNoise for No Lick period
        WhiteNoise=WhiteNoiseGenerator(S.GUI.SoundSamplingRate,S.GUI.TimeNoLick+1,0);
end
PsychToolboxSoundServer('init');
if S.GUI.CueType==1 || S.GUI.CueType==2
PsychToolboxSoundServer('Load', 1, CueA);
PsychToolboxSoundServer('Load', 2, CueB);
PsychToolboxSoundServer('Load', 3, CueC);
end
PsychToolboxSoundServer('Load', 4, WhiteNoise);
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';

%% Define trial types parameters, trial sequence and Initialize plots
[S.TrialsNames, S.TrialsMatrix]=Continuous_Phase(S,S.Names.Phase{S.GUI.Phase});
TrialSequence=WeightedRandomTrials(S.TrialsMatrix(:,2)', S.GUI.MaxTrials);
S.NumTrialTypes=max(TrialSequence);
FigLick=Online_LickPlot('ini',TrialSequence);

%% NIDAQ Initialization amd Plots
if S.GUI.Photometry || S.GUI.Wheel
    if (S.GUI.DbleFibers+S.GUI.Isobestic405+S.GUI.RedChannel)*S.GUI.Photometry >1
        disp('Error - Incorrect photometry recording parameters')
        return
    end
    Nidaq_photometry('ini',ParamPC);
end
[FigPhoto1,FigPhoto2,FigWheel]=Nidaq_Plots('ini');
%% Bonsai
if S.GUI.Bonsai
BpodSystem.Pause=1;
disp('Adjust ROI and time to 200 sec - resume when ready');
success=Bpod2Bonsai_Quentin()
HandlePauseCondition;
end
%% Main trial loop
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.
for currentTrial = 1:S.GUI.MaxTrials
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin 
%% Initialize current trial parameters
    S.AudCue       =   S.TrialsMatrix(TrialSequence(currentTrial),3);
	S.Valve     =	S.TrialsMatrix(TrialSequence(currentTrial),5);
	S.Outcome   =   S.TrialsMatrix(TrialSequence(currentTrial),6);
    thisITI = [100 ; 100 ; 100];
    for i=1:length(thisITI)
    while thisITI(i) > 3 * S.GUI.ITI || thisITI(i)<10
        thisITI(i) = exprnd(S.GUI.ITI);
    end
    S.ITI(i)=thisITI(i);
    end
    disp(thisITI)
    if S.AudCue==0
        S.AudCue=255;
    end
%% Assemble State matrix
% one
 	sma = NewStateMatrix();
    sma = AddState(sma,'Name', 'ITI',...
        'Timer',S.ITI(1),...
        'StateChangeConditions', {'Tup', 'PreState'},...
        'OutputActions',{'BNCState',1});
    %Pre task states
    sma = AddState(sma, 'Name','PreState',...
        'Timer',S.GUI.PreCue,...
        'StateChangeConditions',{'Tup','Outcome'},...
        'OutputActions',{});
    %Reward
    sma=AddState(sma,'Name', 'Outcome',...
        'Timer',S.Outcome,...
        'StateChangeConditions', {'Tup', 'PostOutcome'},...
        'OutputActions', {'ValveState', S.Valve,'SoftCode',S.AudCue});  
    %Post task states
    sma=AddState(sma,'Name', 'PostOutcome',...
        'Timer',S.GUI.PostOutcome,...
        'StateChangeConditions',{'Tup', 'ITI2'},...
        'OutputActions',{});
% two
    sma = AddState(sma,'Name', 'ITI2',...
        'Timer',S.ITI(2),...
        'StateChangeConditions', {'Tup', 'PreState2'},...
        'OutputActions',{});
    %Pre task states
    sma = AddState(sma, 'Name','PreState2',...
        'Timer',S.GUI.PreCue,...
        'StateChangeConditions',{'Tup','Outcome2'},...
        'OutputActions',{});
    %Reward
    sma=AddState(sma,'Name', 'Outcome2',...
        'Timer',S.Outcome,...
        'StateChangeConditions', {'Tup', 'PostOutcome2'},...
        'OutputActions', {'ValveState', S.Valve,'SoftCode',S.AudCue});  
    %Post task states
    sma=AddState(sma,'Name', 'PostOutcome2',...
        'Timer',S.GUI.PostOutcome,...
        'StateChangeConditions',{'Tup', 'ITI3'},...
        'OutputActions',{});    
 % three   
    sma = AddState(sma,'Name', 'ITI3',...
        'Timer',S.ITI(3),...
        'StateChangeConditions', {'Tup', 'PreState3'},...
        'OutputActions',{});
    %Pre task states
    sma = AddState(sma, 'Name','PreState3',...
        'Timer',S.GUI.PreCue,...
        'StateChangeConditions',{'Tup','Outcome3'},...
        'OutputActions',{});
    %Reward
    sma=AddState(sma,'Name', 'Outcome3',...
        'Timer',S.Outcome,...
        'StateChangeConditions', {'Tup', 'PostOutcome3'},...
        'OutputActions', {'ValveState', S.Valve,'SoftCode',S.AudCue});  
    %Post task states
    sma=AddState(sma,'Name', 'PostOutcome3',...
        'Timer',S.GUI.PostOutcome,...
        'StateChangeConditions',{'Tup', 'End'},...
        'OutputActions',{});
    sma = AddState(sma,'Name', 'End',...
        'Timer',4,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions',{'SoftCode', 255});
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

%% PLOT - extract events from BpodSystem.data and update figures
try
[currentOutcome, currentLickEvents]=Online_LickEvents(S.Names.StateToZero{S.GUI.StateToZero});
FigLick=Online_LickPlot('update',[],FigLick,currentOutcome,currentLickEvents);
[FigPhoto1,FigPhoto2,FigWheel]=Nidaq_Plots('update',FigPhoto1,FigPhoto2,FigWheel,'PreState',currentLickEvents);
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
