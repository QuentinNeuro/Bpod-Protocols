function [trialsNames, trialsMatrix,trialSequence,blocSequence]=GoNogo_Phase_Bloc(S)

%% General Phase
if S.GUI.Punishment
noGoValve=S.GUI.PunishValve;
else
noGoValve=S.GUI.OmissionValve;
end
goProba=S.GUI.GoNogoProba/100;
noGoProba=1-goProba;

trialsNames={'Go1','Go2','Go3','NoGo1','NoGo2','NoGo3'};

trialsMatrix=[...
% 1.type, 2.proba, 3.Cue,   4.GoValve,                  5.NoGoValve,          6.Outcome           7.Marker
    1,   goProba,         1,      S.GUI.RewardValve,          S.GUI.OmissionValve,  S.InterRew,         double('o');...    
    2,   goProba,         2,      S.GUI.RewardValve,          S.GUI.OmissionValve,  S.InterRew,         double('o');...
    3,   goProba,         3,      S.GUI.RewardValve,          S.GUI.OmissionValve,  S.InterRew,         double('o');...
    4,   noGoProba,       1,      noGoValve,                  S.GUI.OmissionValve,  S.InterRew,         double('s');...
    5,   noGoProba,       2,      noGoValve,                  S.GUI.OmissionValve,  S.InterRew,         double('s');...
    6,   noGoProba,       3,      noGoValve,                  S.GUI.OmissionValve,  S.InterRew,         double('s');];

%% Generating Blocs
% Bloc correspondance
blocLetter='ABCDEF';
blocGroup=[15 16 24 26 34 35];

trialSequence=[];
blocSequence=[];
trialNb_Bloc=ceil(S.GUI.MaxTrials*(S.GUI.BlocProba/100));
trialNb_Bloc=trialNb_Bloc+ceil(trialNb_Bloc*0.1);

for b=1:3
    thisBloc=sprintf('Bloc%d',b);
    if isnumeric(S.GUI.(thisBloc))
        thisTrialTypes=dec2base(S.GUI.(thisBloc),10) - '0';
    else
        thisTrialTypes=dec2base(blocGroup(blocLetter==S.GUI.(thisBloc)),10) - '0';
    end
    thisTrialMatrix=trialsMatrix(thisTrialTypes,:);
    thisTrialNb(b)=1;
    while thisTrialNb(b)<S.GUI.BlocMinTrial
        thisTrialNb(b)=randi(trialNb_Bloc);
    end
   
    tempSequence=WeightedRandomTrials(thisTrialMatrix(:,2)', thisTrialNb(b));
    thisTrialSequence=NaN(size(tempSequence));
    thisTrialSequence(tempSequence==1)=thisTrialTypes(1);
    thisTrialSequence(tempSequence==2)=thisTrialTypes(2);
    trialSequence=[trialSequence thisTrialSequence];
    blocSequence=[blocSequence b*ones(size(tempSequence))];
end
