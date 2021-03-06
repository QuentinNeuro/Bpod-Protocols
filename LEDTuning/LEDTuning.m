function LEDTuning

global BpodSystem nidaq S

%% Define parameters

S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
ParamPC=BpodParam_PCdep();
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    LEDTuning_TaskParameters(ParamPC);
end

% Initialize parameter GUI plugin and Pause
BpodParameterGUI('init', S);
BpodSystem.Pause=1;
HandlePauseCondition;
S = BpodParameterGUI('sync', S);

%% Define stimuli and send to sound server
WhiteNoise=WhiteNoiseGenerator(S.GUI.SoundSamplingRate,S.GUI.SoundDuration,S.GUI.SoundRamp);
PsychToolboxSoundServer('init')
PsychToolboxSoundServer('Load',1,WhiteNoise);
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';

%% Define trial types parameters, trial sequence
PowerValuesVolt=round(linspace(S.GUI.LED1_Amp_Low,S.GUI.LED1_Amp_High,S.GUI.NbOfPower),2);
PowerValuesWatt=linspace(S.GUI.LED1_Amp_LowWatt,S.GUI.LED1_Amp_HighWatt,S.GUI.NbOfPower);
for i=1:S.GUI.NbOfPower
    S.TrialsNames{i}=sprintf('%.0f W %.2f V',PowerValuesWatt(i),PowerValuesVolt(i));
end

TrialSequence=1:1:S.GUI.NbOfPower;
TrialSequence=TrialSequence(randperm(length(TrialSequence)));
TrialSequence=repmat(TrialSequence',S.GUI.Repetition,1);

S.NumTrialTypes=max(TrialSequence);
S.MaxTrials=length(TrialSequence);
%% NIDAQ Initialization
if S.GUI.Photometry
    if (S.GUI.DbleFibers+S.GUI.Isobestic405+S.GUI.RedChannel)*S.GUI.Photometry >1
        disp('Error - Incorrect photometry recording parameters')
        return
    end
    Nidaq_photometry('ini',ParamPC);
else
        disp('Error - Activate photometry recording!')
        return
end

FigNidaq1=Online_LEDTuningPlot('ini',TrialSequence);
if S.GUI.DbleFibers || S.GUI.Isobestic405 || S.GUI.RedChannel
    FigNidaq2=Online_LEDTuningPlot('ini',TrialSequence);
end


%% Main trial loop
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.
for currentTrial = 1:S.MaxTrials
%% Initialize current trial parameters
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    S.GUI.LED1_Amp=PowerValuesVolt(TrialSequence(currentTrial));
    
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
        'OutputActions', {'SoftCode',1});
    %Post Cue Delivery
    sma=AddState(sma,'Name', 'PostCueState',...
        'Timer',S.GUI.TimePostCue,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {});
    
    SendStateMatrix(sma);
 
%% NIDAQ Get nidaq ready to start

    Nidaq_photometry('WaitToStart');
    
    RawEvents = RunStateMatrix;
    
%% NIDAQ Stop acquisition and save data in bpod structure
    Nidaq_photometry('Stop');
    [PhotoData,WheelData,Photo2Data]=Nidaq_photometry('Save');
    BpodSystem.Data.NidaqData{currentTrial}=PhotoData;
    if S.GUI.DbleFibers || S.GUI.RedChannel
        BpodSystem.Data.Nidaq2Data{currentTrial}=Photo2Data;
    end

    if S.GUI.Wheel
        BpodSystem.Data.NidaqWheelData{currentTrial}=WheelData;
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
    currentNidaq1=Photometry_demod(PhotoData(:,1),nidaq.LED1,S.GUI.LED1_Freq,S.GUI.LED1_Amp,S.Names.StateToZero{S.GUI.StateToZero});
    FigNidaq1=Online_LEDTuningPlot('update',TrialSequence,FigNidaq1,currentTrial,currentNidaq1);

if S.GUI.Isobestic405 || S.GUI.DbleFibers || S.GUI.RedChannel
    if S.GUI.Isobestic405
    currentNidaq2=Photometry_demod(PhotoData(:,1),nidaq.LED2,S.GUI.LED2_Freq,S.GUI.LED2_Amp,S.Names.StateToZero{S.GUI.StateToZero});
    elseif S.GUI.RedChannel
    currentNidaq2=Photometry_demod(Photo2Data(:,1),nidaq.LED2,S.GUI.LED2_Freq,S.GUI.LED2_Amp,S.Names.StateToZero{S.GUI.StateToZero});
    elseif S.GUI.DbleFibers
    currentNidaq2=Photometry_demod(Photo2Data(:,1),nidaq.LED2,S.GUI.LED1b_Freq,S.GUI.LED1b_Amp,S.Names.StateToZero{S.GUI.StateToZero});
    end
    FigNidaq2=Online_LEDTuningPlot('update',TrialSequence,FigNidaq2,currentTrial,currentNidaq2);
end
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
end
