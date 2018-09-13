function LEDTuning_TaskParameters(Param)
%
%
%

global S
    S.Names.StateToZero={'CueDelivery','blank'};
    S.Names.Rig=Param.rig;

%% General Parameters
    S.GUI.Wheel=0;
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
    
    S.GUI.TimeMin=-1;
    S.GUI.TimeMax=2;
    S.GUI.NidaqMin=-5;
    S.GUI.NidaqMax=10;
    S.GUIPanels.Plot={'TimeMin','TimeMax','NidaqMin','NidaqMax'};
     
	S.GUI.LED1_Amp_LowWatt=10;
    S.GUI.LED1_Amp_Low=1;
    S.GUI.LED1_Amp_HighWatt=50;
    S.GUI.LED1_Amp_High=5;
    S.GUI.NbOfPower=5;
    S.GUIPanels.LED_PowerSequence={'LED1_Amp_LowWatt','LED1_Amp_Low','LED1_Amp_HighWatt','LED1_Amp_High','NbOfPower'};
    
    S.GUITabs.General={'Plot','Recording','LED_PowerSequence'};

%% Timing
    S.GUI.Repetition=3;
    S.GUI.TimePreCue=2;
    S.GUI.TimeCue=0.5; %independent of the actual length of the cue
    S.GUI.TimePostCue=3;
    S.GUIPanels.TaskTiming={'Repetition','TimePreCue','TimeCue','TimePostCue'};
        
    S.GUI.StateToZero=1;
	S.GUIMeta.StateToZero.Style='popupmenu';
    S.GUIMeta.StateToZero.String=S.Names.StateToZero;
    S.GUI.BaselineBegin=0.1;
    S.GUI.BaselineEnd=1.1;
    S.GUI.CueBegin=0;
    S.GUI.CueEnd=0.5;
    S.GUIPanels.PlotTiming={'StateToZero','BaselineBegin','BaselineEnd','CueBegin','CueEnd'};

    S.GUITabs.OnlinePlot={'TaskTiming','PlotTiming'};
    
%% Cue
    S.GUI.SoundDuration=0.2;
    S.GUI.SoundRamp=0.05;
	S.GUI.SoundSamplingRate=192000;    
    S.GUIPanels.WhiteNoise_Properties={'SoundDuration','SoundRamp','SoundSamplingRate'}; 
    S.GUITabs.Cue={'WhiteNoise_Properties'};
        
%% Nidaq and Photometry
    S.GUI.PhotometryVersion=1;
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

    S.GUIPanels.Photometry={'PhotometryVersion','Modulation','NidaqDuration',...
                            'NidaqSamplingRate','DecimateFactor',...
                            'LED1_Name','LED1_Amp','LED1_Freq',...
                            'LED2_Name','LED2_Amp','LED2_Freq',...
                            'LED1b_Name','LED1b_Amp','LED1b_Freq'};
                        
    S.GUITabs.Photometry={'Photometry'};
end
