function CuedOutcome_AOD
%Functions used in this protocol:
%"CuedReward_Phase": specify the phase of the training
%"WeightedRandomTrials" : generate random trials sequence

%"Online_LickPlot"      : initialize and update online lick and outcome plot
%"Online_LickEvents"    : extract the data for the online lick plot
%"Online_NidaqPlot"     : initialize and update online nidaq plot
%"Online_NidaqEvents"   : extract the data for the online nidaq plot

global BpodSystem S

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
CuedOutcome_AOD_TaskParameters
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
[S.TrialsNames, S.TrialsMatrix,ezTrialsSeq]=CuedOutcome_Phase(S,S.Names.Phase{S.GUI.Phase});
TrialSequence=WeightedRandomTrials(S.TrialsMatrix(:,2)', S.GUI.MaxTrials);
if S.GUI.eZTrials
    TrialSequence(1:length(ezTrialsSeq))=ezTrialsSeq;
end
S.NumTrialTypes=max(TrialSequence);
FigLick=Online_LickPlot('ini',TrialSequence);

%% Main trial loop
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.
for currentTrial = 1:S.GUI.MaxTrials
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin 
%% Initialize current trial parameters
	S.Cue       =	S.TrialsMatrix(TrialSequence(currentTrial),3);
	S.Delay     =	S.TrialsMatrix(TrialSequence(currentTrial),4)+(S.GUI.DelayIncrement*(currentTrial-1));
	S.Valve     =	S.TrialsMatrix(TrialSequence(currentTrial),5);
	S.Outcome   =   S.TrialsMatrix(TrialSequence(currentTrial),6);
    S.ITI = 100;
    while S.ITI > 3 * S.GUI.ITI
        S.ITI = exprnd(S.GUI.ITI);
    end
%% Cue definition    
    S.AudCue    =   255;    % No AudCue by default
    S.VisualCue =   [0 0]; % Left right LED
    S.WireOlf   =   0;
	S.NoLick=[4 0];
    if S.Cue~=0
    switch S.GUI.CueType
        case {1,2}  % Auditory Cues
                S.AudCue=S.Cue;
                S.NoLick    =   [255 100];
        case 3      % Visual Cues
    S.VisualCue(S.Cue)=100; 
        case 4      % Olfactory Cues
    S.WireOlf=(1+2^(S.Cue));
    end   
    end

%% Assemble State matrix
 	sma = NewStateMatrix();
    sma = AddState(sma,'Name', 'AO_WarmUp',...
        'Timer',7,...
        'StateChangeConditions', {'Tup', 'ITI'},...
        'OutputActions',{});
    sma = AddState(sma,'Name', 'ITI',...
        'Timer',S.ITI,...
        'StateChangeConditions', {'Tup', 'PreState'},...
        'OutputActions',{});
    %Pre task states
    sma = AddState(sma, 'Name','PreState',...
        'Timer',S.GUI.PreCue,...
        'StateChangeConditions',{'Tup','CueDelivery'},...
        'OutputActions',{'BNCState',1+S.Stim_State(1)});
    %Stimulus delivery
    sma=AddState(sma,'Name', 'CueDelivery',...
        'Timer',S.GUI.CueDuration,...
        'StateChangeConditions',{'Tup', 'Delay'},...
        'OutputActions', {'SoftCode',S.AudCue,'PWM4',S.VisualCue(1),'PWM5',S.VisualCue(2),... 
                            'BNCState',S.Stim_State(2),'WireState',S.WireOlf});
    %Delay
    sma=AddState(sma,'Name', 'Delay',...
        'Timer',S.Delay,...
        'StateChangeConditions', {'Tup', 'Outcome'},...
        'OutputActions', {'SoftCode',255,'BNCState',S.Stim_State(3)});
    %Reward
    sma=AddState(sma,'Name', 'Outcome',...
        'Timer',S.Outcome,...
        'StateChangeConditions', {'Tup', 'PostOutcome'},...
        'OutputActions', {'ValveState', S.Valve,...
                            'BNCState',S.Stim_State(4)});  
    %Post task states
    sma=AddState(sma,'Name', 'PostOutcome',...
        'Timer',S.GUI.PostOutcome,...
        'StateChangeConditions',{'Tup', 'NoLick'},...
        'OutputActions',{});
    %ITI + noLick period
    sma = AddState(sma,'Name', 'NoLick', ...
        'Timer', S.GUI.TimeNoLick,...
        'StateChangeConditions', {'Tup', 'End','Port1In','RestartNoLick'},...
        'OutputActions', {'SoftCode',S.NoLick(1),'PWM1',S.NoLick(2)});  
    sma = AddState(sma,'Name', 'RestartNoLick', ...
        'Timer', 0,...
        'StateChangeConditions', {'Tup', 'NoLick',},...
        'OutputActions', {'SoftCode',S.NoLick(1),'PWM1',S.NoLick(2)}); 
    sma = AddState(sma,'Name', 'End',...
        'Timer',1,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions',{'SoftCode', 255});
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    
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
catch
    disp('Oups, something went wrong with the online analysis... May be you closed a plot ?') 
end

%% End of trial
HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
if BpodSystem.BeingUsed == 0
    return
end
end
end
