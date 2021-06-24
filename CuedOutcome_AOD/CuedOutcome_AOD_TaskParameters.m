function CuedOutcome_AOD_TaskParameters()
%
%

global S
    S.Names.Phase={'Habituation','RewardA','RewardB','RewardAPunishB','RewardBPunishA','RewardAPunishBValues','RewardBPunishAValues','RewardACBValues','RewardA_DREADD','RewardA_Large','RewardB_Large'};
    S.Names.Cue={'Sweep','Tones','Visual','Odors'};
    S.Names.StateToStim={'Baseline','CueDelivery','Delay','Outcome'};

%% General Parameters    
    S.GUI.Phase = 2;
    S.GUIMeta.Phase.Style='popupmenu';
    S.GUIMeta.Phase.String=S.Names.Phase;
    S.GUI.eZTrials=1;
	S.GUIMeta.eZTrials.Style='checkbox';
    S.GUIMeta.eZTrials.String='Auto';
    S.GUI.CueType=4;
    S.GUIMeta.CueType.Style='popupmenu';
    S.GUIMeta.CueType.String=S.Names.Cue;
    S.GUIPanels.Task={'Phase','CueType','eZTrials'};
     
    S.GUITabs.General={'Task'};

%% Timing
    S.GUI.MaxTrials=150;
    S.GUI.PreCue=3;
    S.GUI.CueDuration=0.5;
    S.GUI.Delay=2;
    S.GUI.DelayIncrement=0;
    S.GUI.PostOutcome=5;
    S.GUI.TimeNoLick=2;
    S.GUI.ITI=3;
    S.GUIPanels.TaskTiming={'MaxTrials','PreCue','CueDuration','Delay','DelayIncrement','PostOutcome','TimeNoLick','ITI'};
    
    S.GUI.StateToZero=2;
	S.GUIMeta.StateToZero.Style='popupmenu';
    S.GUIMeta.StateToZero.String=S.Names.StateToZero;
    S.GUI.TimeMin=-4;
    S.GUI.TimeMax=4;
    S.GUIPanels.PlotTiming={'StateToZero','TimeMin','TimeMax'};
    S.GUITabs.Timing={'TaskTiming','PlotTiming'};
%% Task Parameters    
    S.GUI.LowFreq=4000;
    S.GUI.HighFreq=20000;
    S.GUI.SoundRamp=0;
    S.GUI.NbOfFreq=1;
    S.GUI.FreqWidth=1;
	S.GUI.SoundSamplingRate=192000;
    S.GUIPanels.Auditory={'LowFreq','HighFreq','SoundRamp','NbOfFreq','FreqWidth','SoundSamplingRate'};
    S.GUITabs.Cue={'Auditory'};
%    
    S.GUI.RewardValve=1;
    S.GUIMeta.RewardValve.Style='popupmenu';
    S.GUIMeta.RewardValve.String={1,2,3,4,5,6};
    S.GUI.SmallReward=2;
    S.GUI.InterReward=5;
    S.GUI.LargeReward=8;
    S.GUI.PunishValve=2;
	S.GUIMeta.PunishValve.Style='popupmenu';
    S.GUIMeta.PunishValve.String={1,2,3,4,5,6};
    S.GUI.PunishTime=0.2;
    S.GUI.OmissionValve=4;
	S.GUIMeta.OmissionValve.Style='popupmenu';
    S.GUIMeta.OmissionValve.String={1,2,3,4,5,6};
    S.GUIPanels.Outcome={'RewardValve','SmallReward','InterReward','LargeReward','PunishValve','PunishTime','OmissionValve'};
    S.GUITabs.Outcome={'Outcome'};            
end
