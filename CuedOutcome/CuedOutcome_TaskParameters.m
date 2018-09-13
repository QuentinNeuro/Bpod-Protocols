function CuedOutcome_TaskParameters(Param)
%
%

global S
    S.Names.Phase={'RewardA','RewardB','RewardAPunishB','RewardBPunishA','RewardAPunishBValues','RewardBPunishAValues','RewardACBValues'};
    S.Names.Cue={'Sweep','Tones','Visual'};
    S.Names.StateToZero={'PostOutcome','CueDelivery'};
    S.Names.Rig=Param.rig;

%% General Parameters    
    S.GUI.Phase = 1;
    S.GUIMeta.Phase.Style='popupmenu';
    S.GUIMeta.Phase.String=S.Names.Phase;
    S.GUI.eZTrials=1;
	S.GUIMeta.eZTrials.Style='checkbox';
    S.GUIMeta.eZTrials.String='Auto';
    S.GUIPanels.Task={'Phase','eZTrials'};
    
    S.GUI.Wheel=1;
    S.GUIMeta.Wheel.Style='checkbox';
    S.GUIMeta.Wheel.String='Auto';
 	S.GUI.Photometry=1;
    S.GUIMeta.Photometry.Style='checkbox';
    S.GUIMeta.Photometry.String='Auto';
    S.GUI.DbleFibers=0;
    S.GUIMeta.DbleFibers.Style='checkbox';
    S.GUIMeta.DbleFibers.String='Auto';
    S.GUI.Isobestic405=0;
    S.GUIMeta.Isobestic405.Style='checkbox';
    S.GUIMeta.Isobestic405.String='Auto';
    S.GUI.RedChannel=0;
    S.GUIMeta.RedChannel.Style='checkbox';
    S.GUIMeta.RedChannel.String='Auto';    
    S.GUIPanels.Recording={'Wheel','Photometry','DbleFibers','Isobestic405','RedChannel'};
    
    S.GUI.TimeMin=-4;
    S.GUI.TimeMax=4;
    S.GUI.NidaqMin=-5;
    S.GUI.NidaqMax=10;
    S.GUIPanels.Plot={'TimeMin','TimeMax','NidaqMin','NidaqMax'};
    
    S.GUITabs.General={'Plot','Recording','Task'};

%% Timing
    S.GUI.MaxTrials=300;
    S.GUI.PreCue=3;
    S.GUI.Delay=1;
    S.GUI.DelayIncrement=0;
    S.GUI.PostOutcome=5;
    S.GUI.TimeNoLick=2;
    S.GUI.ITI=3;
    S.GUIPanels.TaskTiming={'MaxTrials','PreCue','Delay','DelayIncrement','PostOutcome','TimeNoLick','ITI'};
    
    S.GUI.StateToZero=1;
	S.GUIMeta.StateToZero.Style='popupmenu';
    S.GUIMeta.StateToZero.String=S.Names.StateToZero;
    S.GUI.BaselineBegin=1.5;
    S.GUI.BaselineEnd=2.5;
    S.GUIPanels.PlotTiming={'StateToZero','BaselineBegin','BaselineEnd'};
    S.GUITabs.Timing={'TaskTiming','PlotTiming'};
%% Task Parameters    
    S.GUI.CueType=1;
    S.GUIMeta.CueType.Style='popupmenu';
    S.GUIMeta.CueType.String=S.Names.Cue;
    S.GUI.SoundDuration=0.5;
    S.GUI.LowFreq=4000;
    S.GUI.HighFreq=20000;
    S.GUI.SoundRamp=0;
    S.GUI.NbOfFreq=1;
    S.GUI.FreqWidth=1;
	S.GUI.SoundSamplingRate=192000;
    S.GUIPanels.Cue={'CueType','SoundDuration','LowFreq','HighFreq','SoundRamp','NbOfFreq','FreqWidth','SoundSamplingRate'};
    S.GUITabs.Cue={'Cue'};
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
    
%% Nidaq and Photometry
    S.GUI.Modulation=1;
    S.GUIMeta.Modulation.Style='checkbox';
    S.GUIMeta.Modulation.String='Auto';
	S.GUI.NidaqDuration=10;
    S.GUI.NidaqSamplingRate=6100;
    S.GUI.DecimateFactor=610;
    S.GUI.LED1_Name='Fiber1 470-A1';
    S.GUI.LED1_Amp=Param.LED1Amp;
    S.GUI.LED1_Freq=211;
    S.GUI.LED2_Name='Fiber1 405 / 565';
    S.GUI.LED2_Amp=Param.LED2Amp;
    S.GUI.LED2_Freq=531;
    S.GUI.LED1b_Name='Fiber2 470-mPFC';
    S.GUI.LED1b_Amp=Param.LED1bAmp;
    S.GUI.LED1b_Freq=531;

    S.GUIPanels.Photometry={'Modulation','NidaqDuration',...
                            'NidaqSamplingRate','DecimateFactor',...
                            'LED1_Name','LED1_Amp','LED1_Freq',...
                            'LED2_Name','LED2_Amp','LED2_Freq',...
                            'LED1b_Name','LED1b_Amp','LED1b_Freq'};
                        
    S.GUITabs.Photometry={'Photometry'};
end
