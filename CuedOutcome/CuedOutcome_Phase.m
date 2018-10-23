function [trialsNames, trialsMatrix, ezTrialsSeq]=CuedOutcome_Phase(S,PhaseName)

switch PhaseName
	case 'RewardAPunishB' 
        trialsNames={'Cue A Reward','Cue A Omission',...
            'Cue B Punishment','Cue B Omission',...
            'Uncued Reward','Uncued Punishment','Uncued Omission'};
        trialsMatrix=[...
        %  1.type, 2.proba, 3.sound, 4.delay,   5.valve,                6.Outcome         	7.Marker
            1,   0.35,     1,    S.GUI.Delay,   S.GUI.RewardValve,      S.InterRew,         double('o');...   
            2,   0.06,     1,    S.GUI.Delay,   S.GUI.OmissionValve,    S.InterRew,         double('s');...   
            3,   0.35,     2,    S.GUI.Delay,   S.GUI.PunishValve,      S.GUI.PunishTime,   double('d');...   
            4,   0.06,     2,    S.GUI.Delay,   S.GUI.OmissionValve,    S.InterRew,         double('s');...    
            5,   0.06,     3,    S.GUI.Delay,   S.GUI.RewardValve,      S.InterRew,         double('o');...    
            6,   0.06,     3,    S.GUI.Delay,   S.GUI.PunishValve,      S.GUI.PunishTime,   double('d');...
            7,   0.06,     3,    S.GUI.Delay,   S.GUI.OmissionValve,    S.InterRew,         double('s')];
        easyTrials=[1 1 1 1 3 3 3 5 5 5 ];
        
	case 'RewardBPunishA' 
        trialsNames={'Cue B Reward','Cue B Omission',...
            'Cue A Punishment','Cue A Omission',...
            'Uncued Reward','Uncued Punishment','Uncued Omission'};
        trialsMatrix=[...
        %  1.type, 2.proba, 3.sound, 4.delay,   5.valve,                6.Outcome         	7.Marker
            1,   0.35,     2,    S.GUI.Delay,   S.GUI.RewardValve,      S.InterRew,         double('o');...   
            2,   0.06,     2,    S.GUI.Delay,   S.GUI.OmissionValve,    S.InterRew,         double('s');...   
            3,   0.35,     1,    S.GUI.Delay,   S.GUI.PunishValve,      S.GUI.PunishTime,   double('d');...   
            4,   0.06,     1,    S.GUI.Delay,   S.GUI.OmissionValve,    S.InterRew,         double('s');...    
            5,   0.06,     3,    S.GUI.Delay,   S.GUI.RewardValve,      S.InterRew,         double('o');...    
            6,   0.06,     3,    S.GUI.Delay,   S.GUI.PunishValve,      S.GUI.PunishTime,   double('d');...
            7,   0.06,     3,    S.GUI.Delay,   S.GUI.OmissionValve,    S.InterRew,         double('s')];
        easyTrials=[1 1 1 1 3 3 3 5 5 5 ];
        
    case 'RewardValues' 
        trialsNames={'Cue A Small Reward','Cue A Inter Reward',...
            'Cue A Omission','Cue B Inter Reward',...
            'Cue B Large Reward','Cue B Omission',...
            'Uncued Inter Reward'};
        trialsMatrix=[...
        %  1.type, 2.proba, 3.sound, 4.delay,   5.valve,                6.Outcome         	7.Marker
            1,   0.175,     1,    S.GUI.Delay,  S.GUI.RewardValve,  	S.SmallRew,         double('o');...   
            2,   0.175,     1,    S.GUI.Delay,	S.GUI.RewardValve,      S.InterRew,         double('d');...   
            3,   0.1,       1,    S.GUI.Delay,	S.GUI.OmissionValve,	S.InterRew,         double('s');...   
            4,   0.175,     2,    S.GUI.Delay,	S.GUI.RewardValve,       S.InterRew,         double('o');...    
            5,   0.175,     2,    S.GUI.Delay,	S.GUI.RewardValve,      S.LargeRew,         double('d');...    
            6,   0.01,      2,    S.GUI.Delay,	S.GUI.OmissionValve,	S.InterRew,         double('s');...
            7,   0.01,      3,    S.GUI.Delay,	S.GUI.RewardValve,      S.InterRew,         double('o')];    
        easyTrials=[1 1 2 3 3 4 5 5];
        
	case 'RewardAPunishBValues' 
        trialsNames={'Cue A Reward','Cue A Punishment','Cue A Omission'...
            'Cue B Reward','Cue B Punishment','Cue B Omission',...
            'Uncued Reward','Uncued Punishment','Uncued Omission'};
        trialsMatrix=[...
        %  1.type, 2.proba, 3.sound, 4.delay, 	5.valve,                6.Outcome         	7.Marker
            1,   0.325,     1,    S.GUI.Delay,  S.GUI.RewardValve,  	S.InterRew,         double('o');...   
            2,   0.05,      1,    S.GUI.Delay,  S.GUI.PunishValve,      S.GUI.PunishTime, 	double('d');...   
            3,   0.05,    	1,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s');...   
            4,   0.15,      2,    S.GUI.Delay,  S.GUI.RewardValve,       S.InterRew,         double('o');...    
            5,   0.225,     2,    S.GUI.Delay,  S.GUI.PunishValve,      S.GUI.PunishTime, 	double('d');...    
            6,   0.05,      2,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s');...
            7,   0.05,      3,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,         double('o');...
            8,   0.05,      3,    S.GUI.Delay,  S.GUI.PunishValve,      S.GUI.PunishTime,	double('d');...
            9,   0.05,      3,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s')];
        easyTrials=[1 1 1 1 3 3 3 5 5 5 ];
        
	case 'RewardBPunishAValues' 
        trialsNames={'Cue A Reward','Cue A Punishment','Cue A Omission'...
            'Cue B Reward','Cue B Punishment','Cue B Omission',...
            'Uncued Reward','Uncued Punishment','Uncued Omission'};
        trialsMatrix=[...
        %  1.type, 2.proba, 3.sound, 4.delay, 	5.valve,                6.Outcome         	7.Marker
            1,   0.15,     1,    S.GUI.Delay,  S.GUI.RewardValve,  	S.InterRew,         double('o');...   
            2,   0.225,      1,    S.GUI.Delay,  S.GUI.PunishValve,      S.GUI.PunishTime, 	double('d');...   
            3,   0.05,    	1,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s');...   
            4,   0.325,     2,    S.GUI.Delay,  S.GUI.RewardValve,       S.InterRew,         double('o');...    
            5,   0.05,      2,    S.GUI.Delay,  S.GUI.PunishValve,      S.GUI.PunishTime, 	double('d');...    
            6,   0.05,      2,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s');...
            7,   0.05,      3,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,         double('o');...
            8,   0.05,      3,    S.GUI.Delay,  S.GUI.PunishValve,      S.GUI.PunishTime,	double('d');...
            9,   0.05,      3,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s')]; 
        easyTrials=[1 1 1 1 3 3 3 5 5 5 ];

	case 'RewardA'  % training
        trialsNames={'Cue A Reward','Cue A Omission',...
                     'Cue B Omission','Uncued Reward',...
                     'Uncued Omission','blank'};
        trialsMatrix=[...
        % 1.type, 2.proba, 3.sound, 4.delay,    5.valve,                6.Outcome         	7.Marker
            1,   0.3,       1,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,         double('o');...   
            2,   0.1,       1,    S.GUI.Delay,  S.GUI.OmissionValve, 	S.InterRew,         double('s');...   
            3,   0.3,       2,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s');...   
            4,   0.2,       3,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,         double('o');...    
            5,   0.1,       3,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s')];
        easyTrials=[1 1 1 1 3 3 4 4];
          
    case 'RewardB'
        trialsNames={'Cue A Omission','Cue B Reward',...
                     'Cue B Omission','Uncued Reward',...
                     'Uncued Omission','blank'};
        trialsMatrix=[...
        % 1.type, 2.proba, 3.sound, 4.delay,    5.valve,                6.Outcome         	7.Marker
            1,   0.3,       1,    S.GUI.Delay,  S.GUI.OmissionValve,    S.InterRew,         double('s');...   
            2,   0.3,       2,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,         double('o');...   
            3,   0.1,       2,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s');...   
            4,   0.2,       3,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,         double('o');...    
            5,   0.1,       3,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s')];
        easyTrials=[1 1 2 2 2 2 4 4];
  	
    case 'PunishA'  % training
        trialsNames={'Cue A Punish','Cue A Omission',...
                     'Cue B Omission','Uncued Punish',...
                     'Uncued Omission','blank'};
        trialsMatrix=[...
        % 1.type, 2.proba, 3.sound, 4.delay,    5.valve,                6.Outcome         	7.Marker
            1,   0.3,       1,    S.GUI.Delay,  S.GUI.PunishValve,      S.GUI.PunishTime,   double('o');...   
            2,   0.1,       1,    S.GUI.Delay,  S.GUI.OmissionValve, 	S.InterRew,         double('s');...   
            3,   0.3,       2,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s');...   
            4,   0.2,       3,    S.GUI.Delay,  S.GUI.PunishValve,      S.GUI.PunishTime,   double('o');...    
            5,   0.1,       3,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s')];
        easyTrials=[1 1 1 1 3 3 4 4];
        
    case 'PunishB'
        trialsNames={'Cue A Omission','Cue B Punish',...
                     'Cue B Omission','Uncued Punish',...
                     'Uncued Omission','blank'};
        trialsMatrix=[...
        % 1.type, 2.proba, 3.sound, 4.delay,    5.valve,                6.Outcome         	7.Marker
            1,   0.3,       1,    S.GUI.Delay,  S.GUI.OmissionValve,    S.InterRew,         double('s');...   
            2,   0.3,       2,    S.GUI.Delay,  S.GUI.PunishValve,      S.GUI.PunishTime,   double('o');...   
            3,   0.1,       2,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s');...   
            4,   0.2,       3,    S.GUI.Delay,  S.GUI.PunishValve,      S.GUI.PunishTime,   double('o');...    
            5,   0.1,       3,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s')];
        easyTrials=[1 1 2 2 2 2 4 4];
        
        
        
    case 'RewardACBValues'
        trialsNames={'Cue A Reward','Cue A Omission',...
                     'Cue B Reward','Cue B Omission',...
                     'Cue C Reward','Cue C Omission'};
        trialsMatrix=[...
        % 1.type, 2.proba, 3.sound, 4.delay,    5.valve,                6.Outcome         	7.Marker
            1,   0.25,       1,    S.GUI.Delay,  S.GUI.RewardValve,     S.InterRew,        double('o');...   
            2,   0.08,       1,    S.GUI.Delay,  S.GUI.OmissionValve,   S.InterRew,        double('s');...   
            3,   0.17,       4,    S.GUI.Delay,  S.GUI.RewardValve,     S.InterRew,        double('o');...   
            4,   0.17,       4,    S.GUI.Delay,  S.GUI.OmissionValve,   S.InterRew,        double('s');...    
            5,   0.08,       2,    S.GUI.Delay,  S.GUI.RewardValve,     S.InterRew,        double('o');...    
            6,   0.25,       2,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,        double('s')];
        easyTrials=[1 1 2 3 3 4 5 5];
        
	case 'RewardA-2CuesVS'  % training
        trialsNames={'Cue A Reward','Cue A Omission',...
                     'Cue B Omission','Uncued Reward',...
                     'Uncued Omission','blank'};
        trialsMatrix=[...
        % 1.type, 2.proba, 3.sound, 4.delay,    5.valve,                6.Outcome         	7.Marker
            1,   0.3,       1,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,         double('o');...   
            2,   0.1,       1,    S.GUI.Delay,  S.GUI.OmissionValve, 	S.InterRew,         double('s');...   
            3,   0.3,       2,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s');...   
            4,   0.2,       3,    S.GUI.Delay,  S.GUI.RewardValve,      S.InterRew,         double('o');...    
            5,   0.1,       3,    S.GUI.Delay,  S.GUI.OmissionValve,	S.InterRew,         double('s')];
        easyTrials=[1 1 1 1 3 3 4 4];        
end
ezTrialsSeq=easyTrials(randperm(length(easyTrials),length(easyTrials)));
end

%% ------------------- OLD PHASES ---------------------- %%
% 
% case 'Pavlovian1Cue'  % training
%     trialsNames={'Cue A Small Reward ','Cue A Omission',...
%         'Cue A Large Reward','Cue B Omission',...
%         'Uncued Reward','blank'};
%     trialsMatrix=[...
%     %  type, proba,  sound,     delay,       valve,      Pav/Inst 0/1    Marker
%         1,   0.4,     1,    S.GUI.Delay,   S.Valve,    0,              double('o'), S.SmallRew   ;...   % 
%         2,   0.1,     1,    S.GUI.Delay,   S.noValve,  0,              double('s'), S.SmallRew   ;...   % 
%         3,   0.1,     1,    S.GUI.Delay,   S.Valve,    0,              double('d'), S.LargeRew   ;...   % 
%         4,   0.3,     2,    S.GUI.Delay,   S.noValve,  0,              double('s'), S.LargeRew   ;...   % 
%         5,   0.1,     3,    S.GUI.Delay,   S.Valve,    0,              double('o'), S.UncuedRew  ;...   % 
%         6,   0.0,     3,    S.GUI.Delay,   S.Valve,    0,              double('s'), S.UncuedRew];       % 
% 
% case 'Pavlovian2CuesA'
%     trialsNames={'Cue A Small Reward ','Cue A Omission',...
%         'Cue A Large Reward','Cue B Large Reward',...
%         'Cue B Omission','Uncued Small Reward'};
%    trialsMatrix=[...
%     %  type, proba,  sound,     delay,       valve,      Pav/Inst 0/1    Marker
%         1,   0.3,      1,    S.GUI.Delay,   S.Valve,    0,              double('o'), S.SmallRew   ;...   %
%         2,   0.1,      1,    S.GUI.Delay,   S.noValve,  0,              double('s'), S.SmallRew   ;...   %
%         3,   0.1,      1,    S.GUI.Delay,   S.Valve,    0,              double('d'), S.LargeRew   ;...   %
%         4,   0.1,  	   2,    S.GUI.Delay,   S.Valve,    0,              double('d'), S.LargeRew   ;...   %
%         5,   0.3,      2,    S.GUI.Delay,   S.noValve,  0,              double('o'), S.LargeRew   ;...   % 
%         6,   0.1,      3,    S.GUI.Delay,   S.Valve,    0,              double('s'), S.UncuedRew];       % 
% 
%  case 'Pavlovian2CuesB'
%     trialsNames={'Cue A Small Reward ','Cue A Omission',...
%         'Cue A Large Reward','Cue B Large Reward',...
%         'Cue B Omission','Uncued Small Reward'};
%    trialsMatrix=[...
%     %  type, proba,  sound,     delay,       valve,      Pav/Inst 0/1    Marker
%         1,   0.3,      1,    S.GUI.Delay,   S.Valve,    0,              double('o'), S.SmallRew   ;...   %
%         2,   0.1,      1,    S.GUI.Delay,   S.noValve,  0,              double('s'), S.SmallRew   ;...   %
%         3,   0.1,      1,    S.GUI.Delay,   S.Valve,    0,              double('d'), S.LargeRew   ;...   %
%         4,   0.3,  	   2,    S.GUI.Delay,   S.Valve,    0,              double('d'), S.LargeRew   ;...   %
%         5,   0.1,      2,    S.GUI.Delay,   S.noValve,  0,              double('s'), S.LargeRew   ;...   % 
%         6,   0.1,      3,    S.GUI.Delay,   S.Valve,    0,              double('o'), S.UncuedRew];       % 
% 
% case 'Inversion'
%     trialsNames={'Cue A Large Reward ','Cue A Omission',...
%         'Cue B Small Reward','Cue B Omission',...
%         'Uncued Small Reward','blank'};
%    trialsMatrix=[...
%     %  type, proba,  sound,     delay,       valve,      Pav/Inst 0/1    Marker
%         1,   0.35,      1,    S.GUI.Delay,   S.Valve,    0,              double('o'), S.LargeRew   ;...   %
%         2,   0.1,       1,    S.GUI.Delay,   S.noValve,  0,              double('s'), S.LargeRew   ;...   %
%         3,   0.35,      2,    S.GUI.Delay,   S.Valve,    0,              double('v'), S.SmallRew   ;...   %
%         4,   0.1,  	    2,    S.GUI.Delay,   S.noValve,  0,              double('s'), S.SmallRew   ;...   %
%         5,   0.1,       3,    S.GUI.Delay,   S.Valve,    0,              double('o'), S.UncuedRew  ;...   % 
%         6,   0,         3,    S.GUI.Delay,   S.Valve,    0,              double('s'), S.UncuedRew];       %    
