function [trialsNames, trialsMatrix]=OptoPsycho_Phase(S)

OptoPowers=linspace(S.GUI.Opto_PowerMin,S.GUI.Opto_PowerMax,S.GUI.Opto_PowerNb);
for p=1:S.GUI.Opto_PowerNb
    trialsNames{p}=sprintf('Power_%.2d',OptoPowers(p));
    trialsMatrix(p,:)=[p, 1/S.GUI.Opto_PowerNb, OptoPowers(p), S.GUI.Delay, S.GUI.RewardValve, S.InterRew, double('o')];
end
end