function [trialsNames, trialsMatrix]=GoNogo_Phase(S,PhaseName)

switch PhaseName
    	case 'Pavlovian'
        trialsNames={'Go',...
                     'NoGo'};
        trialsMatrix=[...
        % 1.type, 2.proba, 3.Cue,   4.GoValve,                    5.NoGoValve,          6.Outcome           7.Marker
            1,   0.6,       1,      S.GUI.RewardValve,            S.GUI.RewardValve,      S.InterRew,         double('o');...    
            2,   0.4,       2,      S.GUI.OmissionValve,          S.GUI.OmissionValve,	  S.InterRew,         double('s')];

	case 'Go'
        trialsNames={'Go'};
        trialsMatrix=[...
        % 1.type, 2.proba, 3.Cue,   4.GoValve,                  5.NoGoValve,          6.Outcome           7.Marker
            1,   1,       1,      S.GUI.RewardValve,          S.GUI.OmissionValve,  S.InterRew,         double('o')];


	case 'GoNoGo'
        trialsNames={'Go',...
                     'NoGo'};
        if S.GUI.Punishment
        trialsMatrix=[...
        % 1.type, 2.proba, 3.Cue,   4.GoValve,                  5.NoGoValve,          6.Outcome           7.Marker
            1,   0.6,       1,      S.GUI.RewardValve,          S.GUI.OmissionValve,  S.InterRew,         double('o');...    
            2,   0.4,       2,      S.GUI.PunishValve,          S.GUI.OmissionValve,S.InterRew,         double('s')];
        else
        trialsMatrix=[...
        % 1.type, 2.proba, 3.Cue,   4.GoValve,                  5.NoGoValve,          6.Outcome           7.Marker
            1,   0.6,       1,      S.GUI.RewardValve,          S.GUI.OmissionValve,  S.InterRew,         double('o');...    
            2,   0.4,       2,      S.GUI.OmissionValve,        S.GUI.OmissionValve,  S.InterRew,         double('s')];
        end
end
end