% This script loops over sessions collects information about 
% (1) Firing rates of neurons
% (2) Statistics of OSI
clear all;
% loc = '/media/ghosh/My Passport/workingSessions';
loc = 'F:\workingSessionsnoWaveform';
d = dir(fullfile(loc,'*.mat'));

DETAILS = {};
for j = 1:length(d)
    disp(j)
    clear sess
    load(fullfile(loc,d(j).name));
    disp(d(j).name)
    
    % firing Rates and OSI
    try
        fr = sess.getFeature('FiringRate');
        osi = sess.getFeature('OSIs');
    catch ex
        getReport(ex)
        fr = [];
        osi = [];
    end
    fr.sessionName = d(j).name;
    osi.sessionName = d(j).name;
    DETAILS{end+1} = {fr,osi};
end

save('Details.mat','DETAILS');

%% 
OSIs = [];
FRs = [];
for i = 1:length(DETAILS)
    if isfield(DETAILS{i}{2},'OSI')
        OSIs = [OSIs DETAILS{i}{2}.OSI];
        FRs = [FRs DETAILS{i}{1}.firingRates];
    end
end

%% hist OSI 
ax = axes;
hist(OSIs,30); 
ax.YTick = [0 50 100 150];
xlabel('OSI');
ylabel('# units');

%% scatter OSI vs fr
ax = axes;
h = scatter(log10(FRs),OSIs);

% firingRates = [];
% for j = 1:length(MEANFIRINGRATE)
%     if ~isempty(MEANFIRINGRATE{j})
%     firingRates = [firingRates MEANFIRINGRATE{j}.firingRates];
%     end
% end
% 
% f = figure;
% f.Position = [-1566 476 1109 420];
% ax = subplot(1,2,1);
% [count, centers] = hist(firingRates,40);
% b = bar(centers,count);
% b.EdgeColor = 'none';
% b.FaceColor = [0.5, 0.5, 0.5];
% 
% ax = subplot(1,2,2); hold on;
% [count,centers] = hist(log10(firingRates),40);
% b = bar(centers,count);
% b.EdgeColor = 'none';
% b.FaceColor = [0.5, 0.5, 0.5];
% 
% ax.XTick = [log10(0.01:0.01:0.1) log10(0.2:0.1:1) log10(2:1:10) log10(20:10:100)];
% ax.XTickLabel = {};
% 
% Labels = {'0.01'}; for i = 1:8, Labels{end+1} = ''; end
% Labels{end+1} = '0.1'; for i = 1:8, Labels{end+1} = '';end
% Labels{end+1} = '1'; for i = 1:8,Labels{end+1} = '';end
% Labels{end+1} = '10';for i = 1:8,Labels{end+1} = '';end
% Labels{end+1} = '100';
% ax.XTickLabel = Labels;
% %% 
% x = -10:0.01:10;
% y1 = exp(-(x+6).^2/4); y1 = y1/sum(y1);
% y2 = exp(-(x-2).^2/10);y2 = y2/sum(y2);
% plot(x,y1,x,y2,x,y1+y2);
% 
% 
% obj = fitgmdist(log10(firingRates'),2)