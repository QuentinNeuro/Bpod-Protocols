function OptoTuning

global BpodSystem nidaq S

%% Define parameters

S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
ParamPC=BpodParam_PCdep();
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    OptoTuning_TaskParameters(ParamPC);
end

% Initialize parameter GUI plugin and Pause
BpodParameterGUI('init', S);
BpodSystem.Pause=1;
HandlePauseCondition;
S = BpodParameterGUI('sync', S);

%% Stimulation
PulsePal('COM6');
S.TrialsNames={'Pulse_3ms_5V','Pulse_5ms_5V','Pulse_10ms_5V'};
BNCpp=2;
for i=1:size(S.TrialsNames,2)
    thisPP=S.TrialsNames{i};
    pm{i}=load(thisPP);
end

%% Define stim sequence
TrialSequence=1:size(S.TrialsNames,2);
TrialSequence=repmat(TrialSequence,S.GUI.Repetition,1);
TrialSequence=TrialSequence(randperm(length(TrialSequence)));
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

%% Main trial loop
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.
for currentTrial = 1:S.MaxTrials
%% Initialize current trial parameters
    ProgramPulsePal(pm{1,TrialSequence(currentTrial)}.ParameterMatrix);
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
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
        'OutputActions', {'BNCState',BNCpp});
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
        if S.GUI.DbleFibers == 1
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
