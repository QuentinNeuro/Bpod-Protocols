function CuedOutcome_TaskParameters(Param)
%
%
%

global S
    S.Names.Phase={'RewardA','RewardB','RewardAPunishB','RewardBPunishA','RewardAPunishBValues','RewardBPunishAValues','RewardACBValues'};
    S.Names.Sound={'Sweep','Tones'};
    S.Names.StateToZero={'PostReward','SoundDelivery'};
    S.Names.OutcomePlot={'Collect','GoNoGo'};
    S.Names.Symbols={'Reward','Punish','Omission','Small','Inter','Big'};
    S.Names.Rig='Laptop';

%% General Parameters    
    S.GUI.Phase = 1;
    S.GUIMeta.Phase.Style='popupmenu';
    S.GUIMeta.Phase.String=S.Names.Phase;
    S.GUI.MaxTrials=300;
    S.GUI.eZTrials=1;
	S.GUIMeta.eZTrials.Style='checkbox';
    S.GUIMeta.eZTrials.String='Auto';
    S.GUI.Wheel=0;
    S.GUIMeta.Wheel.Style='checkbox';
    S.GUIMeta.Wheel.String='Auto';
 	S.GUI.Photometry=0;
    S.GUIMeta.Photometry.Style='checkbox';
    S.GUIMeta.Photometry.String='Auto';
    S.GUI.Modulation=0;
    S.GUIMeta.Modulation.Style='checkbox';
    S.GUIMeta.Modulation.String='Auto';
    S.GUI.DbleFibers=0;
    S.GUIMeta.DbleFibers.Style='checkbox';
    S.GUIMeta.DbleFibers.String='Auto';
    S.GUIPanels.General={'Phase','MaxTrials','eZTrials','Wheel','Photometry','Modulation','DbleFibers'};
    
    S.GUI.PreCue=3;
    S.GUI.Delay=1;
    S.GUI.DelayIncrement=0;
    S.GUI.PostOutcome=5;
    S.GUI.TimeNoLick=2;
    S.GUI.ITI=5;
    S.GUIPanels.Timing={'PreCue','Delay','DelayIncrement','PostOutcome','TimeNoLick','ITI'};
    
    S.GUITabs.General={'Timing','General'};

%% Task Parameters

    S.GUI.SoundType=1;
    S.GUIMeta.SoundType.Style='popupmenu';
    S.GUIMeta.SoundType.String=S.Names.Sound;
    S.GUI.SoundDuration=0.5;
    S.GUI.LowFreq=4000;
    S.GUI.HighFreq=20000;
    S.GUI.SoundRamp=0;
    S.GUI.NbOfFreq=1;
    S.GUI.FreqWidth=1;
	S.GUI.SoundSamplingRate=192000;
    S.GUIPanels.Cue={'SoundType','SoundDuration','LowFreq','HighFreq','SoundRamp','NbOfFreq','FreqWidth','SoundSamplingRate'};
    
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
 
    S.GUITabs.Cue={'Cue'};
    S.GUITabs.Outcome={'Outcome'};

%% Nidaq and Photometry
	S.GUI.NidaqDuration=10;
    S.GUI.NidaqSamplingRate=6100;
    S.GUI.LED1_Name='A1-470';
    S.GUI.LED1_Amp=0.5;
    S.GUI.LED1_Freq=211;
    S.GUI.LED2_Name='A1-405';
    S.GUI.LED2_Amp=0;
    S.GUI.LED2_Freq=531;
    S.GUI.LED1b_Name='mPFC-470';
    S.GUI.LED1b_Amp=0.5;
    S.GUI.LED1b_Freq=531;

    S.GUIPanels.Photometry={'NidaqDuration','NidaqSamplingRate',...
                            'LED1_Name','LED1_Amp','LED1_Freq',...
                            'LED2_Name','LED2_Amp','LED2_Freq',...
                            'LED1b_Name','LED1b_Amp','LED1b_Freq'};
                        
    S.GUITabs.Photometry={'Photometry'};

%% Online Plots   
    S.GUI.StateToZero=1;
	S.GUIMeta.StateToZero.Style='popupmenu';
    S.GUIMeta.StateToZero.String=S.Names.StateToZero;
    S.GUI.TimeMin=-4;
    S.GUI.TimeMax=4;
    S.GUIPanels.PlotParameters={'StateToZero','TimeMin','TimeMax'};
    
    S.GUI.Outcome=1;
    S.GUIMeta.Outcome.Style='popupmenu';
    S.GUIMeta.Outcome.String=S.Names.OutcomePlot;
    S.GUI.Circle=1;
    S.GUIMeta.Circle.Style='popupmenu';
    S.GUIMeta.Circle.String=S.Names.Symbols;
	S.GUI.Square=3;
    S.GUIMeta.Square.Style='popupmenu';
    S.GUIMeta.Square.String=S.Names.Symbols;
    S.GUI.Diamond=2;
    S.GUIMeta.Diamond.Style='popupmenu';
    S.GUIMeta.Diamond.String=S.Names.Symbols;
    S.GUIPanels.PlotLicks={'Outcome','Circle','Square','Diamond'};
    
    S.GUI.DecimateFactor=610;
	S.GUI.BaselineBegin=1.5;
    S.GUI.BaselineEnd=2.5;
    S.GUI.NidaqMin=-5;
    S.GUI.NidaqMax=10;
    S.GUIPanels.PlotNidaq={'DecimateFactor','NidaqMin','NidaqMax','BaselineBegin','BaselineEnd'};
    
    S.GUITabs.OnlinePlot={'PlotNidaq','PlotLicks','PlotParameters'};
end
