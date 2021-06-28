function GoNogo
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
    GoNogo_TaskParameters(ParamPC);
end

% Initialize parameter GUI plugin and Pause
BpodParameterGUI('init', S);
BpodSystem.Pause=1;
HandlePauseCondition;
S = BpodParameterGUI('sync', S);

S.Reward  =   GetValveTimes(S.GUI.RewardSize, S.GUI.RewardValve);

%% Define stimuli and send to sound server
TimeSound=0:1/S.GUI.SoundSamplingRate:S.GUI.SoundDuration;
switch S.GUI.CueType
    case 1
        CueA=SoundGenerator(S.GUI.SoundSamplingRate,S.GUI.SoundA,S.GUI.FreqWidth,S.GUI.NbOfFreq,S.GUI.SoundDuration,S.GUI.SoundRamp);
        CueB=SoundGenerator(S.GUI.SoundSamplingRate,S.GUI.SoundB,S.GUI.FreqWidth,S.GUI.NbOfFreq,S.GUI.SoundDuration,S.GUI.SoundRamp);
        CueC=chirp(TimeSound,S.GUI.SoundA,S.GUI.SoundDuration,S.GUI.SoundB);
        CueD=chirp(TimeSound,S.GUI.SoundB,S.GUI.SoundDuration,S.SoundA);
    case 2
        CueA=SoundGenerator(S.GUI.SoundSamplingRate,S.GUI.SoundA,S.GUI.FreqWidth,S.GUI.NbOfFreq,S.GUI.SoundDuration,S.GUI.SoundRamp);
        CueB=SoundGenerator(S.GUI.SoundSamplingRate,S.GUI.SoundB,S.GUI.FreqWidth,S.GUI.NbOfFreq,S.GUI.SoundDuration,S.GUI.SoundRamp);
        CueC=SoundGenerator(S.GUI.SoundSamplingRate,S.GUI.SoundC,S.GUI.FreqWidth,S.GUI.NbOfFreq,S.GUI.SoundDuration,S.GUI.SoundRamp);
        CueD=SoundGenerator(S.GUI.SoundSamplingRate,S.GUI.SoundD,S.GUI.FreqWidth,S.GUI.NbOfFreq,S.GUI.SoundDuration,S.GUI.SoundRamp);
    case 3
        CueA=SoundGenerator(S.GUI.SoundSamplingRate,S.GUI.SoundA,S.GUI.FreqWidth,S.GUI.NbOfFreq,S.GUI.SoundDuration,S.GUI.SoundRamp);
        CueB=SoundGenerator(S.GUI.SoundSamplingRate,S.GUI.SoundB,S.GUI.FreqWidth,S.GUI.NbOfFreq,S.GUI.SoundDuration,S.GUI.SoundRamp);
        [CueC,CueD]=SoundsOfTheDay(S.GUI.Day,S.GUI.Week);
end

PsychToolboxSoundServer('init');
PsychToolboxSoundServer('Load', 1, CueA);
PsychToolboxSoundServer('Load', 2, CueB);
PsychToolboxSoundServer('Load', 3, CueC);
PsychToolboxSoundServer('Load', 4, CueD);
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';

%% Define trial types parameters, trial sequence and Initialize plots
[S.TrialsNames, S.TrialsMatrix]=GoNogo_Phase(S,S.Names.Phase{S.GUI.Phase});
TrialSequence=WeightedRandomTrials(S.TrialsMatrix(:,2)', S.GUI.MaxTrials);
S.NumTrialTypes=max(TrialSequence);
FigLick=Online_LickPlot('ini',TrialSequence);
%% NIDAQ Initialization amd Plots
if S.GUI.Photometry || S.GUI.Wheel
    if (S.GUI.DbleFibers+S.GUI.Isobestic405+S.GUI.RedChannel)*S.GUI.Photometry >1
        disp('WARNING - Incorrect photometry recording parameters')
        return
    end
    Nidaq_photometry('ini',ParamPC);
end
[FigPhoto1,FigPhoto2,FigWheel]=Nidaq_Plots('ini');
%% Bonsai
if S.GUI.Bonsai
    BpodSystem.Pause=1;
    disp('Adjust ROI and time to 15sec - resume when ready');
    success=Bpod2Bonsai_Quentin()
    HandlePauseCondition;
end

%% Main trial loop
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.
for currentTrial = 1:S.GUI.MaxTrials
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin 
    
%% Initialize current trial parameters
	S.Sound         =	S.TrialsMatrix(TrialSequence(currentTrial),3);
	S.LickTimer     =	S.TrialsMatrix(TrialSequence(currentTrial),4);
	S.LickValve     =	S.TrialsMatrix(TrialSequence(currentTrial),5);
	S.noLickTimer   =   S.TrialsMatrix(TrialSequence(currentTrial),8);
    S.noLickValve   =   S.TrialsMatrix(TrialSequence(currentTrial),9);
    S.ITI = 100;
    while S.ITI > 3 * S.GUI.ITI
        S.ITI = exprnd(S.GUI.ITI);
    end
  
%% Assemble State matrix
 	sma = NewStateMatrix();
    %Pre task states
    sma = AddState(sma, 'Name','InitialDelay',...
        'Timer',S.GUI.PreCue,...
        'StateChangeConditions',{'Tup','CueDelivery'},...
        'OutputActions',{'BNCState',1});
    %Stimulus delivery
    sma=AddState(sma,'Name', 'CueDelivery',...
        'Timer',S.GUI.SoundDuration,...
        'StateChangeConditions',{'Tup', 'Nogo','Port1In','Go'},...
        'OutputActions', {'SoftCode',S.Sound});
    %Go/Nogo State
    sma=AddState(sma,'Name', 'Go',...
        'Timer',S.LickTimer,...
        'StateChangeConditions', {'Tup', 'PostOutcome'},...
        'OutputActions', {'ValveState',S.LickValve,'SoftCode',255});
    sma=AddState(sma,'Name', 'Nogo',...
        'Timer',S.noLickTimer,...
        'StateChangeConditions', {'Tup', 'PostOutcome'},...
        'OutputActions', {'ValveState',S.noLickValve});
    %Post task states
    sma=AddState(sma,'Name', 'PostOutcome',...
        'Timer',S.GUI.PostOutcome,...
        'StateChangeConditions',{'Tup', 'NoLick'},...
        'OutputActions',{});
    %ITI + noLick period
    sma = AddState(sma,'Name', 'NoLick', ...
        'Timer', S.GUI.TimeNoLick,...
        'StateChangeConditions', {'Tup', 'PostlightExit','Port1In','RestartNoLick'},...
        'OutputActions', {'PWM1', 100});  
    sma = AddState(sma,'Name', 'RestartNoLick', ...
        'Timer', 0,...
        'StateChangeConditions', {'Tup', 'NoLick',},...
        'OutputActions', {'PWM1', 100}); 
    sma = AddState(sma,'Name', 'PostlightExit', ...
        'Timer', 0.5,...
        'StateChangeConditions', {'Tup', 'ITI',},...
        'OutputActions', {});
    sma = AddState(sma,'Name', 'ITI',...
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

%% PLOT - extract events from BpodSystem.data and update figures
try
[currentOutcome, currentLickEvents]=Online_LickEvents(S.Names.StateToZero{S.GUI.StateToZero});
FigLick=Online_LickPlot('update',[],FigLick,currentOutcome,currentLickEvents);
[FigPhoto1,FigPhoto2,FigWheel]=Nidaq_Plots('update',FigPhoto1,FigPhoto2,FigWheel,'InitialDelay');


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
