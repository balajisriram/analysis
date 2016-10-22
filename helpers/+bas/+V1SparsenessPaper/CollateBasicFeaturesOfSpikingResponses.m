% This script loops over sessions and creates figures about 
% (1) Firing rates of neurons
% (2) Statistics of ISI

clear all;
loc = 'F:\workingSessionsnoWaveform';
d = dir(fullfile(loc,'*.mat'));

MEANFIRINGRATE = {};
ISIDISTRIBUTION = {};
OSIS = {};

for j = 1:length(d)
    disp(j)
    clear sess
    load(fullfile(loc,d(j).name));
    disp(d(j).name)
    try
        fr = sess.getFeature('firingRate');
    catch ex
        getReport(ex);
        fr = [];
    end
    MEANFIRINGRATE{end+1} = fr;
    
end

firingRates = [];
for j = 1:length(MEANFIRINGRATE)
    if ~isempty(MEANFIRINGRATE{j})
    firingRates = [firingRates MEANFIRINGRATE{j}.firingRates];
    end
end

f = figure;
f.Position = [-1566 476 1109 420];
ax = subplot(1,2,1);
hist(firingRates,40);

ax = subplot(1,2,2); hold on;
hist(log10(firingRates),40);
ax.XTick = [log10(0.01:0.01:0.1) log10(0.2:0.1:1) log10(2:1:10) log10(20:10:100)];
ax.XTickLabel = {};

Labels = {'0.01'}; for i = 1:8, Labels{end+1} = ''; end
Labels{end+1} = '0.1'; for i = 1:8, Labels{end+1} = '';end
Labels{end+1} = '1'; for i = 1:8,Labels{end+1} = '';end
Labels{end+1} = '10';for i = 1:8,Labels{end+1} = '';end
Labels{end+1} = '100';
ax.XTickLabel = Labels;

[mu,sig,muci,sigmaci] = normfit()