% This script loops over sessions and creates figures about 
% (1) Firing rates of neurons
% (2) Statistics of ISI
% (3) Waveforms (mean+sd)
% (4) Number of Channels
% (5) Different ways to characterize the waveforms FW at 0, FWHM, PK2TROUGH

clear all;
loc = 'E:\workingSessions';%'/media/ghosh/My Passport/workingSessions';
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
        keyboard
        fr = [];
    end
    fr.sessionName = d(j).name;
    MEANFIRINGRATE{end+1} = fr;
    
    % ISI
    try
        isi = sess.getFeature('ISIs');
    catch ex
        getReport(ex);
        keyboard
        isi = [];
    end
    isi.sessionName = d(j).name;
    ISI{end+1} = isi;
    
    % WAVEFORMS
    try
        wvfrm = sess.getFeature('Waveforms');
    catch ex
        getReport(ex);
        keyboard
        wvfrm = [];
    end
    wvfrm.sessionName = d(j).name;
    WAVEFORMS{end+1} = wvfrm;
    
     % NUMCHANS
    try
        numChans = sess.getFeature('NumChans');
    catch ex
        getReport(ex);
        keyboard
        numChans = [];
    end
    numChans.sessionName = d(j).name;
    NUMCHANS{end+1} = numChans;
    
     % FWAT0
    try
        fwat0 = sess.getFeature('FWAt0s');
    catch ex
        getReport(ex);
        keyboard
        fwat0 = [];
    end
    fwat0.sessionName = d(j).name;
    FWAT0{end+1} = fwat0;
    
     % FWHM
    try
        fwhm = sess.getFeature('FWHMs');
    catch ex
        getReport(ex);
        keyboard
        fwhm = [];
    end
    fwhm.sessionName = d(j).name;
    FWHM{end+1} = fwhm;
    
     % PK2TROUGHS
    try
        pk2tr = sess.getFeature('PeakToTroughs');
    catch ex
        getReport(ex);
        keyboard
        pk2tr = [];
    end
    pk2tr.sessionName = d(j).name;
    PK2TROUGHS{end+1} = pk2tr;
    
end

save('Details.mat','MEANFIRINGRATE','ISI','WAVEFORMS','NUMCHANS','FWAT0','FWHM','PK2TROUGHS')

%% make Tabls using Data
%% FWAT0
SpikeFullWidthAt0 = [];
unitID = {};
for i = 1:length(FWAT0)
    for j = 1:length(FWAT0{i}.FWAt0s)
        if ~isempty(FWAT0{i}.FWAt0s{j})
            SpikeFullWidthAt0(end+1) = FWAT0{i}.FWAt0s{j};
        else
            SpikeFullWidthAt0(end+1) = NaN;
            keyboard
        end
        temp = FWAT0{i}.sessionName;
        [~,temp] = fileparts(temp);
        unitID{end+1} = sprintf('%s_%s', temp, FWAT0{i}.uid{j});
    end
end
SpikeFullWidthAt0Table = table(unitID',SpikeFullWidthAt0','VariableNames',{'uID','SpikeFullWidthAt0'});


%%
SpikeFullWidthAtHalfMax = [];
unitID = {};
for i = 1:length(FWHM)
    for j = 1:length(FWHM{i}.FWHMs)
        if ~isempty(FWHM{i}.FWHMs{j})
            try
                SpikeFullWidthAtHalfMax(end+1) = FWHM{i}.FWHMs{j};
            catch ex
                temp = FWHM{i}.FWHMs{j};
                SpikeFullWidthAtHalfMax(end+1) = temp(2);
            end
        else
            SpikeFullWidthAtHalfMax(end+1) = NaN;
            keyboard
        end
        temp = FWHM{i}.sessionName;
        [~,temp] = fileparts(temp);
        unitID{end+1} = sprintf('%s_%s', temp, FWHM{i}.uid{j});
    end
end
SpikeFullWidthAtHalfMaxTable = table(unitID',SpikeFullWidthAtHalfMax','VariableNames',{'uID','SpikeFullWidthAtHalfMax'});


%% MEANFIRINGRATE2
MeanFiringRate2 = [];
unitID = {};
for i = 1:length(MEANFIRINGRATE)
    for j = 1:length(MEANFIRINGRATE{i}.firingRates)
        if ~isempty(MEANFIRINGRATE{i}.firingRates(j))
            try
                MeanFiringRate2(end+1) = MEANFIRINGRATE{i}.firingRates(j);
            catch ex
                temp = MEANFIRINGRATE{i}.firingRates(j);
                keyboard
            end
        else
            MeanFiringRate2(end+1) = NaN;
            keyboard
        end
        temp = MEANFIRINGRATE{i}.sessionName;
        [~,temp] = fileparts(temp);
        unitID{end+1} = sprintf('%s_%s', temp, MEANFIRINGRATE{i}.uid{j});
    end
end
MeanFiringRate2Table = table(unitID',MeanFiringRate2','VariableNames',{'uID','MeanFiringRate2'});

%% NUMCHANS
NumChans = [];
unitID = {};
for i = 1:length(NUMCHANS)
    for j = 1:length(NUMCHANS{i}.NumChans)
        if ~isempty(NUMCHANS{i}.NumChans{j})
            try
                NumChans(end+1) = NUMCHANS{i}.NumChans{j};
            catch ex
                temp = NUMCHANS{i}.NumChans{j};
                keyboard
            end
        else
            NumChans(end+1) = NaN;
            keyboard
        end
        temp = NUMCHANS{i}.sessionName;
        [~,temp] = fileparts(temp);
        unitID{end+1} = sprintf('%s_%s', temp, NUMCHANS{i}.uid{j});
    end
end
NumChansTable = table(unitID',NumChans','VariableNames',{'uID','NumChans'});

%% PK2TROUGHS
SpikePeakToTroughWidth = [];
unitID = {};
for i = 1:length(PK2TROUGHS)
    for j = 1:length(PK2TROUGHS{i}.PeakToTroughs)
        if ~isempty(PK2TROUGHS{i}.PeakToTroughs{j})
            try
                SpikePeakToTroughWidth(end+1) = PK2TROUGHS{i}.PeakToTroughs{j};
            catch ex
                temp = PK2TROUGHS{i}.PeakToTroughs{j};
                keyboard
            end
        else
            SpikePeakToTroughWidth(end+1) = NaN;
            keyboard
        end
        temp = PK2TROUGHS{i}.sessionName;
        [~,temp] = fileparts(temp);
        unitID{end+1} = sprintf('%s_%s', temp, PK2TROUGHS{i}.uid{j});
    end
end
SpikePeakToTroughWidthTable = table(unitID',SpikePeakToTroughWidth','VariableNames',{'uID','SpikePeakToTroughWidth'});

%% ISI
ISIS = {};
unitID = {};
for i = 1:length(ISI)
    for j = 1:length(ISI{i}.ISIs)
        if ~isempty(ISI{i}.ISIs{j})
            try
                ISIS{end+1} = ISI{i}.ISIs{j};
            catch ex
                temp = ISI{i}.ISIs{j};
                keyboard
            end
        else
            ISIS{end+1} = NaN;
            keyboard
        end
        temp = ISI{i}.sessionName;
        [~,temp] = fileparts(temp);
        unitID{end+1} = sprintf('%s_%s', temp, ISI{i}.uid{j});
    end
end


ISITable = table(unitID',ISIS','VariableNames',{'uID','ISI'});


%%
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