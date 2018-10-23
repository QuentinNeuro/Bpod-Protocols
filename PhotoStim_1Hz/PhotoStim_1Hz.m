%{
----------------------------------------------------------------------------

This file is part of the Bpod Project
Copyright (C) 2014 Joshua I. Sanders, Cold Spring Harbor Laboratory, NY, USA

-------------------------------------------------------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3.

This program is distributed  WITHOUT ANY WARRANTY and without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
%}
function PhotoStim_1Hz
% PhotoStim_1Hz  for optogenetic tagging
% Written by Hyun-Jae Pi 11/2014.

global BpodSystem
PulsePal;
%load('/home/kepecslab/Documents/MATLAB/Bpod_0_5/Protocols/PhotoStim_1Hz/LightPulse_3ms');  % Light-pulse :  1ms pulse width
load('LightPulse_3ms');
ProgramPulsePal(ParameterMatrix);

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.PulseWidth = 5; % msec
    S.InitialDelay = 1;
    S.DeliverStimulus = 0;
end

% Initialize parameter GUI plugin
BpodParameterGUI('init', S)


%% Define trials
numTrialTypes = 1;  %%%    <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
MaxTrials = 100+1;
TrialTypes = ceil(rand(1,MaxTrials)*numTrialTypes);
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.

%% Initialize plots
BpodSystem.ProtocolFigures.OutcomePlotFig = figure('Position', [400 600 1000 200],'Name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.OutcomePlot = axes('Position', [.075 .3 .89 .6]);
OutcomePlot_PhotoStim_1Hz(BpodSystem.GUIHandles.OutcomePlot,'init',2-TrialTypes,MaxTrials);

%% Main trial loop
for currentTrial = 1:MaxTrials-1
    
    
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    
    sma = NewStateMatrix(); % Assemble state matrix
    
    sma = AddState(sma, 'Name', 'InitialDelay', ...
        'Timer', S.InitialDelay,...
        'StateChangeConditions', {'Tup', 'DeliverStimulus'},...
        'OutputActions', {});
    
    sma = AddState(sma, 'Name', 'DeliverStimulus', ...
        'Timer', 0,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {'BNCState', 1});
    
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        % BpodSystem.Data = BpodNotebook(BpodSystem.Data); % Sync with Bpod notebook plugin
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        BpodSystem.Data.TrialTypes(currentTrial) = TrialTypes(currentTrial); % Adds the trial type of the current trial to data
        UpdateOutcomePlot(TrialTypes, BpodSystem.Data);
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
    end
    
    if BpodSystem.BeingUsed == 0
        return
    end
    
    % close the procotol
    if currentTrial == MaxTrials-1
        BpodSystem.BeingUsed = 1;
        RunProtocol;
    end
    
end

function UpdateOutcomePlot(TrialTypes, Data)
global BpodSystem
Outcomes = zeros(1,Data.nTrials);
for x = 1:Data.nTrials
    if ~isnan(Data.RawEvents.Trial{x}.States.DeliverStimulus(1))
        Outcomes(x) = 1;
    else
        Outcomes(x) = 3;
    end
end
OutcomePlot_PhotoStim_1Hz(BpodSystem.GUIHandles.OutcomePlot,'update',Data.nTrials+1,2-TrialTypes,Outcomes)
