% Plot basic feaures of spiking data
% (1) FIRING RATES
% (2) ISI
% (3) Distribution of Waveform 

clear all;

%% (1) firing rates
load('C:\Users\ghosh\Dropbox\Manuscripts\V1 paper\Figure\BasicCharacterizationOfSpikes\Details.mat','MEANFIRINGRATE') ;
f = figure;
f.Position = [-1566 476 1109 420];
ax = subplot(1,2,1);
[count, centers] = hist(firingRates,40);
b = bar(centers,count);
b.EdgeColor = 'none';
b.FaceColor = [0.5, 0.5, 0.5];

ax = subplot(1,2,2); hold on;
[count,centers] = hist(log10(firingRates),40);
b = bar(centers,count);
b.EdgeColor = 'none';
b.FaceColor = [0.5, 0.5, 0.5];

ax.XTick = [log10(0.01:0.01:0.1) log10(0.2:0.1:1) log10(2:1:10) log10(20:10:100)];
ax.XTickLabel = {};

Labels = {'0.01'}; for i = 1:8, Labels{end+1} = ''; end
Labels{end+1} = '0.1'; for i = 1:8, Labels{end+1} = '';end
Labels{end+1} = '1'; for i = 1:8,Labels{end+1} = '';end
Labels{end+1} = '10';for i = 1:8,Labels{end+1} = '';end
Labels{end+1} = '100';
ax.XTickLabel = Labels;
%% the firing rates are bi gaussian in log scale
x = -10:0.01:10;
y1 = exp(-(x+6).^2/4); y1 = y1/sum(y1);
y2 = exp(-(x-2).^2/10);y2 = y2/sum(y2);
plot(x,y1,x,y2,x,y1+y2);


obj = fitgmdist(log10(firingRates'),2);

%% (2) ISI 
load('C:\Users\ghosh\Dropbox\Manuscripts\V1 paper\Figure\BasicCharacterizationOfSpikes\Details.mat','ISI');

f = figure;
ax = axes; hold on;
k = 0;
for i = 1:length(ISI)
    for j = 1:length(ISI{i}.ISIs)
        isi = ISI{i}.ISIs{j};
        logisi = log10(isi);
        
        n = histc(logisi,linspace(-3,2,50));
        n = n/sum(n);
        k = k+1;
        X = [linspace(-3,2,50) fliplr(linspace(-3,2,50))];
        Y = [n' zeros(size(n))'];
%         Z = k*ones(length(n)*2,1);
        h = fill(X,Y,[0 0 0]);
        h.EdgeColor = 'none';
        h.FaceAlpha = 0.01;
    end
end

%% (3) Get Waveforms
clear all;
load('C:\Users\ghosh\Dropbox\Manuscripts\V1 paper\Figure\BasicCharacterizationOfSpikes\Details.mat','FWAT0','FWHM','PK2TROUGHS');

fprintf('FWAT0\tFWHM\tPK2TR\n');
for i = 1:length(FWHM)
    fprintf('%d\t%d\t%d\n',...
        length(FWAT0{i}.FWAt0s),...
        length(FWHM{i}.FWHMs),...
        length(PK2TROUGHS{i}.PeakToTroughs));
    
    if (length(FWAT0{i}.FWAt0s)~=length(FWHM{i}.FWHMs) || ...
            length(FWAT0{i}.FWAt0s)~=length(PK2TROUGHS{i}.PeakToTroughs) || ...
            length(FWHM{i}.FWHMs)~=length(PK2TROUGHS{i}.PeakToTroughs))
        disp(FWAT0{i}.sessionName);
    end
end

l1 = []; l2 = []; l3 = [];
fwAt0s = [];
fwhms = [];
pk2trough = [];
for i = 1:length(FWAT0)
    temp = FWAT0{i}.FWAt0s;
    if any(cellfun(@isempty,temp))
        temp{cellfun(@isempty,temp)} = NaN;
    end
    fwAt0s = [fwAt0s cell2mat(temp)];
    l1 = [l1,length(fwAt0s)];
end

for i = 1:length(FWHM)
    temp = FWHM{i}.FWHMs;
    if any(cellfun(@isempty,temp))
        temp{cellfun(@isempty,temp)} = NaN;
    end
    fwhms = [fwhms cellfun(@(x) x(1),temp)];
    l2 = [l2,length(fwhms)];
end

for i = 1:length(PK2TROUGHS)
    temp = PK2TROUGHS{i}.PeakToTroughs;
    if any(cellfun(@isempty,temp))
        temp{cellfun(@isempty,temp)} = NaN;
    end
    pk2trough = [pk2trough cell2mat(temp)];
    l3 = [l3,length(pk2trough)];
end

%% Relationship between firing rates and FWHM
clear all;
load('C:\Users\ghosh\Dropbox\Manuscripts\V1 paper\Figure\BasicCharacterizationOfSpikes\Details.mat','MEANFIRINGRATE','FWHM');

frs = [];
for i = 1:length(MEANFIRINGRATE)
    try
        temp = MEANFIRINGRATE{i}.firingRates;
        frs = [frs temp];
    catch ex
        getReport(ex)
    end
end


fwhms = [];
for i = 1:length(FWHM)
    temp = FWHM{i}.FWHMs;
    if any(cellfun(@isempty,temp))
        temp{cellfun(@isempty,temp)} = NaN;
    end
    fwhms = [fwhms cellfun(@(x) x(1),temp)];
end
f = figure;
ax = subplot(2,2,1);inb
plot(fwhms, frs,'k.'); xlabel('FWHM (ms)');ylabel('Firing Rate (Hz)');

subplot(2,2,2);
[countsFr,binFr] = histcounts(frs,50);
b = barh(binFr(2:end-1),countsFr(2:end));
ylabel('FiringRates(Hz)');

subplot(2,2,3);
histogram(fwhms,50);
xlabel('Spike Width(ms)');

ax = subplot(2,2,4);
which = fwhms<0.2;
t1 = frs(which);
t2 = frs(~which);
[h,p] = ttest2(t1,t2);
errorbar([1 2],[mean(t1) mean(t2)],[2*std(t1)/sqrt(length(t1)) 2*std(t2)/sqrt(length(t2))]);
ax.XTick = [1,2];
ax.XTickLabel = {'<0.2 ms','>0.2 ms'};
xlabel('Spike Width');
ylabel('Firing Rate (Hz)')