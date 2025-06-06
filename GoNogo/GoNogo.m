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
        WhiteNoise=WhiteNoiseGenerator(S.GUI.SoundSamplingRate,S.GUI.CueDuration+1,0);
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
if ~S.GUI.Bloc
[S.TrialsNames, S.TrialsMatrix]=GoNogo_Phase(S,S.Names.Phase{S.GUI.Phase});
if S.GUI.Optogenetic
    [S.TrialsNames, S.TrialsMatrix]=Phase_Add_Stim(S.TrialsNames, S.TrialsMatrix);
end
TrialSequence=WeightedRandomTrials(S.TrialsMatrix(:,2)', S.GUI.MaxTrials);
else
    [S.TrialsNames, S.TrialsMatrix,TrialSequence, S.BlocSequence]=GoNogo_Phase_Bloc(S);
    S.GUI.MaxTrials=length(TrialSequence);
end
S.NumTrialTypes=max(TrialSequence);
FigLick=Online_LickPlot('ini',TrialSequence);

%% Stimulation
Stim_State=zeros(length(S.Names.StateToStim));
if S.GUI.Optogenetic
    Stim_State(S.GUI.Opto_State)=1*S.GUI.Opto_BNC;
    PulsePal(ParamPC.PPCOM);
    S.PulsePalProtocol=S.Names.PPProtocols{S.GUI.PulsePalProtocol};
    load(S.PulsePalProtocol);
    S.ParameterMatrix=ParameterMatrix;
    ProgramPulsePal(ParameterMatrix);
end
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
for currentTrial = 1:S.GUI.MaxTrials
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin 
%% Initialize current trial parameters
	S.Cue           =	S.TrialsMatrix(TrialSequence(currentTrial),3);
	S.Delay         =	S.GUI.Delay+(S.GUI.DelayIncrement*(currentTrial-1));
	S.GoValve       =	S.TrialsMatrix(TrialSequence(currentTrial),4);
    S.noGoValve     =   S.TrialsMatrix(TrialSequence(currentTrial),5);
    S.Valve=S.GoValve; % for plotting purposes
    if S.GoValve==S.GUI.PunishValve
         S.GoValveTime   =   S.GUI.PunishTime;
    else
         S.GoValveTime   =   S.TrialsMatrix(TrialSequence(currentTrial),6);
    end
    if S.noGoValve==S.GUI.PunishValve
         S.noGoValveTime   =   S.GUI.PunishTime;
    else
         S.noGoValveTime   =   S.TrialsMatrix(TrialSequence(currentTrial),6);
    end
    S.ITI = 100;
    while S.ITI > 3 * S.GUI.ITI
        S.ITI = exprnd(S.GUI.ITI);
    end
%% Cue definition    
    S.AudCue    =   255;    % No AudCue by default
    S.VisualCue =   [0 0];  % Left right LED
    S.WireOlf   =   0;
	S.LickCue    =   [255 20];
    if S.Cue~=0
    switch S.GUI.CueType
        case {1,2}  % Auditory Cues
                S.AudCue=S.Cue;
        case 3      % Visual Cues
    S.VisualCue(S.Cue)=20; 
        case 4      % Olfactory Cues
    S.WireOlf=(1+2^(S.Cue));
    end   
    end
%% Optogenetic
if S.GUI.Optogenetic
    S.Stim_State=Stim_State*S.TrialsMatrix(TrialSequence(currentTrial),8);
else
    S.Stim_State=Stim_State;
end
%% Assemble State matrix
 	sma = NewStateMatrix();
    sma = SetGlobalTimer(sma, 1, S.Cue); 
    sma = AddState(sma,'Name', 'ITI',...
        'Timer',S.ITI,...
        'StateChangeConditions', {'Tup', 'PreState'},...
        'OutputActions',{});
    %Pre task states
    sma = AddState(sma, 'Name','PreState',...
        'Timer',S.GUI.PreCue,...
        'StateChangeConditions',{'Tup','CueDelivery'},...
        'OutputActions',{'BNCState',1+S.Stim_State(1)});
    switch S.GUI.Type
        case 1
            sma=AddState(sma,'Name', 'CueDelivery',...
                'Timer',S.GUI.CueDuration,...
                'StateChangeConditions',{'Tup', 'noGo','Port1In','Go'},...
                'OutputActions', {'SoftCode',S.AudCue,'PWM4',S.VisualCue(1),'PWM5',S.VisualCue(2),... 
                            'BNCState',S.Stim_State(2),'WireState',S.WireOlf});
        case 2
            sma=AddState(sma,'Name', 'CueDelivery',...
                'Timer',S.GUI.CueDuration,...
                'StateChangeConditions',{'Tup', 'noGo','Port1In','Delay'},...
                'OutputActions', {'SoftCode',S.AudCue,'PWM4',S.VisualCue(1),'PWM5',S.VisualCue(2),... 
                                    'BNCState',S.Stim_State(2),'WireState',S.WireOlf,'GlobalTimerTrig', 1});
            sma=AddState(sma,'Name', 'Delay',...
                'Timer',S.Delay,...
                'StateChangeConditions', {'GlobalTimer1_End', 'Go'},...
                'OutputActions', {'PWM4',S.VisualCue(1),'PWM5',S.VisualCue(2),... 
                                    'BNCState',S.Stim_State(2),'WireState',S.WireOlf});  
        case 3
                %Stimulus delivery
            sma=AddState(sma,'Name', 'CueDelivery',...
                'Timer',S.GUI.CueDuration,...
                'StateChangeConditions',{'Tup', 'Delay'},...
                'OutputActions', {'SoftCode',S.AudCue,'PWM4',S.VisualCue(1),'PWM5',S.VisualCue(2),... 
                            'BNCState',S.Stim_State(2),'WireState',S.WireOlf});
            sma=AddState(sma,'Name', 'Delay',...
                'Timer',S.Delay,...
                'StateChangeConditions', {'Tup', 'CueResponse'},...
                'OutputActions', {'SoftCode',255,'BNCState',S.Stim_State(3)});  
            sma=AddState(sma,'Name', 'CueResponse',...
                'Timer',S.GUI.CueResponse,...
                'StateChangeConditions', {'Tup', 'noGo','Port1In','Go'},...
                'OutputActions', {'SoftCode',S.LickCue(1),'PWM1',S.LickCue(2)});
       case 4
                %Stimulus delivery
            sma=AddState(sma,'Name', 'CueDelivery',...
                'Timer',S.GUI.CueDuration,...
                'StateChangeConditions',{'Tup', 'Delay'},...
                'OutputActions', {'SoftCode',S.AudCue,'PWM4',S.VisualCue(1),'PWM5',S.VisualCue(2),... 
                            'BNCState',S.Stim_State(2),'WireState',S.WireOlf});
            sma=AddState(sma,'Name', 'Delay',...
                'Timer',S.Delay,...
                'StateChangeConditions', {'Tup', 'CueResponse'},...
                'OutputActions', {'SoftCode',255,'BNCState',S.Stim_State(3)});  
            sma=AddState(sma,'Name', 'CueResponse',...
                'Timer',S.GUI.CueResponse,...
                'StateChangeConditions', {'Tup', 'Response'},...
                'OutputActions', {'SoftCode',S.LickCue(1),'PWM1',S.LickCue(2)});
            sma=AddState(sma,'Name', 'Response',...
                'Timer',S.GUI.CueResponse,...
                'StateChangeConditions', {'Tup', 'noGo','Port1In','Go'},...
                'OutputActions', {'SoftCode',255});
            
    end
    %GoNoGo State
    sma=AddState(sma,'Name', 'Go',...
        'Timer',S.GoValveTime,...
        'StateChangeConditions', {'Tup', 'PostOutcome'},...
        'OutputActions', {'ValveState',S.GoValve,'SoftCode',255, 'BNCState',S.Stim_State(4)});
    sma=AddState(sma,'Name', 'noGo',...
        'Timer',S.noGoValveTime,...
        'StateChangeConditions', {'Tup', 'PostOutcome'},...
        'OutputActions', {'ValveState',S.noGoValve,'SoftCode',255,'BNCState',S.Stim_State(4)});
    %Post task states
    sma=AddState(sma,'Name', 'PostOutcome',...
        'Timer',S.GUI.PostOutcome,...
        'StateChangeConditions',{'Tup', 'End'},...
        'OutputActions',{});
    sma = AddState(sma,'Name', 'End',...
        'Timer',1,...
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
[FigPhoto1,FigPhoto2,FigWheel]=Online_NidaqPlots('update',FigPhoto1,FigPhoto2,FigWheel,currentLickEvents);
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
    sprintf('Water collected : %.0d ul', FigLick.water)
    Analysis_Bpod_Launcher;
catch
    disp('Post recording analysis failed - check whether analysis pipeline is present')
end
end
