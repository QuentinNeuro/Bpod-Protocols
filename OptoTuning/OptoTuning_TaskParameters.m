function OptoTuning_TaskParameters(Param)
%
%
%

global S
    S.Names.StateToZero={'StimDelivery','blank'};
    S.Names.StateToStim={'NA','ND'};
    S.Names.RecordingTypes={'Photometry','Spikes','AOD','Prime','Miniscope'};

    S.Names.Rig=Param.rig;

%% General Parameters    
    S.GUI.Bonsai=0;
    S.GUIMeta.Bonsai.Style='checkbox';
    S.GUIMeta.Bonsai.String='Auto';
    S.GUI.Wheel=0;
    S.GUIMeta.Wheel.Style='checkbox';
    S.GUIMeta.Wheel.String='Auto';
    S.GUI.Optogenetic=1;
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
   
    S.GUITabs.General={'Recording'};
    
%% Figure
    S.GUI.StateToZero=1;
	S.GUIMeta.StateToZero.Style='popupmenu';
    S.GUIMeta.StateToZero.String=S.Names.StateToZero;
    S.GUI.TimeMin=-2;
    S.GUI.TimeMax=3;
    S.GUI.BaselineBegin=0.1;
    S.GUI.BaselineEnd=1.1;
    S.GUI.NidaqMin=-5;
    S.GUI.NidaqMax=10;

    S.GUIPanels.PlotPhotometry={};
    S.GUIPanels.PlotPhotometry={'StateToZero','TimeMin','TimeMax','BaselineBegin','BaselineEnd',...
        'NidaqMin','NidaqMax'};
    S.GUITabs.Figure={'PlotPhotometry'};

%% Timing
    S.GUI.Repetition=10;
    S.GUI.TimePreStim=4;
    S.GUI.TimeStim=1;
    S.GUI.TimePostStim=5;
    S.GUIPanels.Timing={'Repetition','TimePreStim','TimeStim','TimePostStim'};
    S.GUITabs.TaskTiming={'Timing'}; 

%% Nidaq and Photometry
    S.GUI.PhotometryVersion=1.2;
    S.GUI.Modulation=1;
    S.GUIMeta.Modulation.Style='checkbox';
    S.GUIMeta.Modulation.String='Auto';
	S.GUI.NidaqDuration=15;
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
    S.GUI.PulsePalProtocol='na';
    S.GUI.Opto_BNC=Param.BPPP_BNC;
    S.GUI.Opto_State=1;
    S.GUIMeta.Opto_State.Style='popupmenu';
    S.GUIMeta.Opto_State.String=S.Names.StateToStim;
    S.GUI.Opto_Proba=0;
    S.GUI.Opto_TrialType=0;
    S.GUI.Opto_Block=0;
    S.GUI.Opto_Pairing=0; % Auto-adjust GUI parameters for pairing protocol, used for AuditoryTuning and VisualTuning
    S.GUIMeta.Opto_Pairing.Style='checkbox';
    S.GUIMeta.Opto_Pairing.String='Auto'; 
    S.GUIPanels.Optogenetic={'PulsePalProtocol','Opto_BNC','Opto_State','Opto_Proba','Opto_TrialType','Opto_Block','Opto_Pairing'};
    S.GUITabs.Opto={'Optogenetic'};    
end
