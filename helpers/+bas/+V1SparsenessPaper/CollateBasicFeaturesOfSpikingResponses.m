% This script loops over sessions and creates figures about 
% (1) Firing rates of neurons
% (2) Statistics of ISI
% (3) Waveforms (mean+sd)
% (4) Number of Channels
% (5) Different ways to characterize the waveforms FW at 0, FWHM, PK2TROUGH

clear all;
loc = '/media/ghosh/My Passport/workingSessions';
d = dir(fullfile(loc,'*.mat'));

MEANFIRINGRATE = {};
ISI = {};
WAVEFORMS = {};
NUMCHANS = {};
FWAT0 = {};
FWHM = {};
PK2TROUGHS = {};

for j = 1:length(d)
    disp(j)
    clear sess
    load(fullfile(loc,d(j).name));
    disp(d(j).name)
    
    % firing Rates
    try
        fr = sess.getFeature('FiringRate');
    catch ex
        getReport(ex);
        fr = [];
    end
    fr.sessionName = d(j).name;
    MEANFIRINGRATE{end+1} = fr;
    
    % ISI
    try
        isi = sess.getFeature('ISIs');
    catch ex
        getReport(ex);
        isi = [];
    end
    isi.sessionName = d(j).name;
    ISI{end+1} = isi;
    
    % WAVEFORMS
    try
        wvfrm = sess.getFeature('Waveforms');
    catch ex
        getReport(ex);
        wvfrm = [];
    end
    wvfrm.sessionName = d(j).name;
    WAVEFORMS{end+1} = wvfrm;
    
     % NUMCHANS
    try
        numChans = sess.getFeature('NumChans');
    catch ex
        getReport(ex);
        numChans = [];
    end
    numChans.sessionName = d(j).name;
    NUMCHANS{end+1} = numChans;
    
     % FWAT0
    try
        fwat0 = sess.getFeature('FWAt0s');
    catch ex
        getReport(ex);
        fwat0 = [];
    end
    fwat0.sessionName = d(j).name;
    FWAT0{end+1} = fwat0;
    
     % FWHM
    try
        fwhm = sess.getFeature('FWHMs');
    catch ex
        getReport(ex);
        fwhm = [];
    end
    fwhm.sessionName = d(j).name;
    FWHM{end+1} = fwhm;
    
     % PK2TROUGHS
    try
        pk2tr = sess.getFeature('PeakToTroughs');
    catch ex
        getReport(ex);
        pk2tr = [];
    end
    pk2tr.sessionName = d(j).name;
    PK2TROUGHS{end+1} = pk2tr;
    
end

save('Details.mat','MEANFIRINGRATE','ISI','WAVEFORMS','NUMCHANS','FWAT0','FWHM','PK2TROUGHS')

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