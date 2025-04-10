function GoNogo_TaskParameters(Param)
%
%

global S
    S.Names.Phase={'Pavlovian','GoNoGo'};
    S.Names.Type={'Direct','Delay','Trace'};
    S.Names.Cue={'Sweep','Tones','Visual','Odors'};
    S.Names.StateToZero={'CueDelivery','PostOutcome'};
    S.Names.StateToStim={'Baseline','CueDelivery','Delay','PostOutcome'};
    S.Names.PPProtocols={'Train_10Hz_500ms_5ms_5V','Pulse_500ms_5V','Pulse_5ms_5V','Pulse_10ms_5V'};
	S.Names.RecordingTypes={'Photometry','Spikes','AOD','Prime','Miniscope'};
    S.Names.Rig=Param.rig;

%% General Parameters    
    S.GUI.Phase = 1;
    S.GUIMeta.Phase.Style='popupmenu';
    S.GUIMeta.Phase.String=S.Names.Phase;
    S.GUI.Type=1;
	S.GUIMeta.Type.Style='checkbox';
    S.GUIMeta.Type.String='Auto';
    S.GUI.Punishment=0;
	S.GUIMeta.Punishment.Style='checkbox';
    S.GUIMeta.Punishment.String='Auto';
    S.GUI.CueType=2;
    S.GUIMeta.CueType.Style='popupmenu';
    S.GUIMeta.CueType.String=S.Names.Cue;
    S.GUIPanels.Task={'Phase','Type','CueType','Punishment'};
     
    S.GUI.Bonsai=0;
    S.GUIMeta.Bonsai.Style='checkbox';
    S.GUIMeta.Bonsai.String='Auto';
    S.GUI.Wheel=1;
    S.GUIMeta.Wheel.Style='checkbox';
    S.GUIMeta.Wheel.String='Auto';
    S.GUI.Optogenetic=0;
    S.GUIMeta.Optogenetic.Style='checkbox';
    S.GUIMeta.Optogenetic.String='Auto';
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
    S.GUI.RecordingTypes=1;
    S.GUIMeta.RecordingTypes.Style='popupmenu';
    S.GUIMeta.RecordingTypes.String=S.Names.RecordingTypes;
    S.GUIPanels.Recording={'RecordingTypes','Bonsai','Wheel','Photometry','DbleFibers','Isobestic405','RedChannel','Optogenetic'};
            
    S.GUITabs.General={'Recording','Task'};

%% Figure
    S.GUI.StateToZero=2;
	S.GUIMeta.StateToZero.Style='popupmenu';
    S.GUIMeta.StateToZero.String=S.Names.StateToZero;
    S.GUI.TimeMin=-4;
    S.GUI.TimeMax=4;
    S.GUI.BaselineBegin=1.5;
    S.GUI.BaselineEnd=2.5;
    S.GUI.NidaqMin=-5;
    S.GUI.NidaqMax=10;

    S.GUIPanels.PlotPhotometry={};
    S.GUIPanels.PlotPhotometry={'StateToZero','TimeMin','TimeMax','BaselineBegin','BaselineEnd','NidaqMin','NidaqMax'};
    S.GUITabs.Figure={'PlotPhotometry'};

%% Timing
    S.GUI.MaxTrials=150;
    S.GUI.PreCue=3;
    S.GUI.CueDuration=0.5;
    S.GUI.Delay=0;
    S.GUI.DelayIncrement=0;
    S.GUI.PostOutcome=5;
    S.GUI.TimeNoLick=2;
    S.GUI.ITI=5;
    S.GUIPanels.Timing={'MaxTrials','PreCue','CueDuration','Delay','DelayIncrement','PostOutcome','TimeNoLick','ITI'};
    
    S.GUITabs.TaskTiming={'Timing'};

%% Cue   
    S.GUI.LowFreq=4000;
    S.GUI.HighFreq=20000;
    S.GUI.SoundRamp=0;
    S.GUI.NbOfFreq=1;
    S.GUI.FreqWidth=1;
	S.GUI.SoundSamplingRate=192000;
    S.GUIPanels.Auditory={'LowFreq','HighFreq','SoundRamp','NbOfFreq','FreqWidth','SoundSamplingRate'};
    S.GUITabs.Cue={'Auditory'};
%% Outcome
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
    S.GUI.PhotometryVersion=1.2;
    S.GUI.Modulation=1;
    S.GUIMeta.Modulation.Style='checkbox';
    S.GUIMeta.Modulation.String='Auto';
	S.GUI.NidaqDuration=30;
    S.GUI.NidaqSamplingRate=6100;
    S.GUI.DecimateFactor=610;
    S.GUI.modPhase=-1.5708;
    S.GUI.LED1_Name='Fiber1 470-A1';
    S.GUI.LED1_Amp=Param.LED1Amp;
    S.GUI.LED1_Freq=211;
    S.GUI.LED2_Name='Fiber1 405 / 565';
    S.GUI.LED2_Amp=Param.LED2Amp;
    S.GUI.LED2_Freq=531;
    S.GUI.LED1b_Name='Fiber2 470-mPFC';
    S.GUI.LED1b_Amp=Param.LED1bAmp;
    S.GUI.LED1b_Freq=531;

    S.GUIPanels.Photometry={'PhotometryVersion','Modulation','NidaqDuration',...
                            'NidaqSamplingRate','DecimateFactor','modPhase',...
                            'LED1_Name','LED1_Amp','LED1_Freq',...
                            'LED2_Name','LED2_Amp','LED2_Freq',...
                            'LED1b_Name','LED1b_Amp','LED1b_Freq'};
                        
    S.GUITabs.Photometry={'Photometry'};
%% Optogenetic stimulation
    S.GUI.PulsePalProtocol=1;
    S.GUIMeta.PulsePalProtocol.Style='popupmenu';
    S.GUIMeta.PulsePalProtocol.String=S.Names.PPProtocols;
    S.GUI.Opto_BNC=Param.BPPP_BNC;
    S.GUI.Opto_State=4;
    S.GUIMeta.Opto_State.Style='popupmenu';
    S.GUIMeta.Opto_State.String=S.Names.StateToStim;
    S.GUI.Opto_Proba=0.5;
    S.GUI.Opto_TrialType=0;
    S.GUI.Opto_Block=0;
    S.GUI.Opto_Pairing=0; % Auto-adjust GUI parameters for pairing protocol, used for AuditoryTuning and VisualTuning
    S.GUIMeta.Opto_Pairing.Style='checkbox';
    S.GUIMeta.Opto_Pairing.String='Auto'; 
    S.GUIPanels.Optogenetic={'PulsePalProtocol','Opto_BNC','Opto_State','Opto_Proba','Opto_TrialType','Opto_Block','Opto_Pairing'};
    S.GUITabs.Opto={'Optogenetic'};              
end
