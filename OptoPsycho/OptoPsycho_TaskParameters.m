function OptoPsycho_TaskParameters(Param)
%
%

global S
    S.Names.Phase={'LickToReward'};
    S.Names.StateToZero={'CueDelivery','PostOutcome'};
    S.Names.StateToStim={'na'};
    S.Names.PPProtocols={'Pulse_500ms_5V','Pulse_500ms_5V_ch2'};
    S.Names.Rig=Param.rig;

%% General Parameters
    answer = questdlg('Is decoy ligth on ?', ...
	'choose', ...
	'yes','no','no');
switch answer
    case 'yes'
    S.GUI.Decoy=1;
    otherwise
    S.GUI.Decoy=0;   
end
    S.GUIMeta.Decoy.Style='checkbox';
    S.GUIMeta.Decoy.String='Auto';
    S.GUI.Bonsai=1;
    S.GUIMeta.Bonsai.Style='checkbox';
    S.GUIMeta.Bonsai.String='Auto';
    S.GUI.Wheel=0;
    S.GUIMeta.Wheel.Style='checkbox';
    S.GUIMeta.Wheel.String='Auto';
    S.GUI.Optogenetic=1;
    S.GUIMeta.Optogenetic.Style='checkbox';
    S.GUIMeta.Optogenetic.String='Auto';
 	S.GUI.Photometry=0;
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
   
    S.GUI.Phase = 1;
    S.GUIMeta.Phase.Style='popupmenu';
    S.GUIMeta.Phase.String=S.Names.Phase;
    S.GUI.noLickPeriod=1;
	S.GUIMeta.noLickPeriod.Style='checkbox';
    S.GUIMeta.noLickPeriod.String='Auto';
    S.GUI.Opto_PowerMax=2;
    S.GUI.Opto_PowerMin=0;
    S.GUI.Opto_PowerNb=6;

    S.GUIPanels.OptoPsych={'Decoy','Phase','noLickPeriod','Opto_PowerMax','Opto_PowerMin','Opto_PowerNb'};
    S.GUITabs.General={'Recording','OptoPsych'};

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

    S.GUIPanels.PlotPhotometry={'StateToZero','TimeMin','TimeMax','BaselineBegin','BaselineEnd','NidaqMin','NidaqMax'};
    S.GUITabs.Figure={'PlotPhotometry'};

%% Timing
    S.GUI.MaxTrials=100;
    S.GUI.PreCue=3;
    S.GUI.CueDuration=.6;
    S.GUI.Delay=0;
    S.GUI.DelayIncrement=0;
    S.GUI.PostOutcome=5;
    S.GUI.TimeNoLick=2;
    S.GUI.ITI=5;
    S.GUIPanels.Timing={'MaxTrials','PreCue','CueDuration','Delay','DelayIncrement','PostOutcome','TimeNoLick','ITI'};
    S.GUITabs.TaskTiming={'Timing'};

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
    S.GUI.Opto_State=1;
    S.GUIMeta.Opto_State.Style='popupmenu';
    S.GUIMeta.Opto_State.String=S.Names.StateToStim;
    S.GUI.Opto_Proba=1;
    S.GUI.Opto_TrialType=1;
    S.GUI.Opto_Block=0;
    S.GUI.Opto_Pairing=0; % Auto-adjust GUI parameters for pairing protocol, used for AuditoryTuning and VisualTuning
    S.GUIMeta.Opto_Pairing.Style='checkbox';
    S.GUIMeta.Opto_Pairing.String='Auto'; 
    S.GUIPanels.Optogenetic={'PulsePalProtocol','Opto_BNC','Opto_State','Opto_Proba','Opto_TrialType','Opto_Block','Opto_Pairing'};
    S.GUITabs.Opto={'Optogenetic'};              
end
