% This script loops over sessions collects information about 
% (1)  'gratings_LED'

clear all;
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
        spikeDetails = sess.getFeature('SpikeAndStimDetails');
    catch ex
        getReport(ex)
        spikeDetails = [];
    end
    spikeDetails.sessionName = d(j).name;
    DETAILS{end+1} = {spikeDetails};
end
% 
save('Details_SpikeDetails.mat','DETAILS');
%%
for i = 1:length(DETAILS)
DETAILS{i}{1}.spikeNumsActual
disp(i)
pause(1)
end

%%
[7,9,10,11,17,35]
DETAILS{35}{1}.spikeNumsActual


%% Plotting sparseness

% what fraction of neurons are responding?
numResponding = [];
numRecorded = [];
contrast = [];
orientation = [];
actualStimDuration = [];

for i = setdiff(1:length(DETAILS),[7,9,10,11,17,35])
    contrast = [contrast;DETAILS{i}{1}.contrasts];
    orientation = [orientation;DETAILS{i}{1}.orientations];
    actualStimDuration = [actualStimDuration;DETAILS{i}{1}.actualStimDurations];
    numResponding = [numResponding;sum(DETAILS{i}{1}.spikeNumsActual>0,2)];
    numRecorded = [numRecorded;repmat(size(DETAILS{i}{1}.spikeNumsActual,2),size(DETAILS{i}{1}.spikeNumsActual,1),1)];
end


% what fractino of neurons responded wrt contrast
% which  = contrast==0;
allResponseRatios = numResponding./numRecorded;
contrastZeros = contrast ==0; nZero = sum(contrastZeros);
contrastLo = contrast==0.15; nLo = sum(contrastLo);
contrastHi = contrast==1; nHi = sum(contrastHi);
responseRatiosZeroContrast = numResponding(contrastZeros)./numRecorded(contrastZeros);
responseRatiosLoContrast = numResponding(contrastLo)./numRecorded(contrastLo);
responseRatiosHiContrast = numResponding(contrastHi)./numRecorded(contrastHi);

fprintf('Response prob across all contrats:%2.2f\n',mean(allResponseRatios));
fprintf('Response prob for zero contrast:%2.2f\n',mean(responseRatiosZeroContrast));
fprintf('Response prob for lo contrasts:%2.2f\n',mean(responseRatiosLoContrast));
fprintf('Response prob for hi contrasts:%2.2f\n',mean(responseRatiosHiContrast));

% [h,p] = ttest2(responseRatiosZeroContrast,responseRatiosNonZeroContrast)


% [h1,p1] = ttest2(actualStimDuration(which),actualStimDuration(~which))

violin({responseRatiosZeroContrast,responseRatiosLoContrast,responseRatiosHiContrast},'xlabel',{'C=0','Lo','Hi'},'facealpha',0.2,'medc',[]);
% figure;
hold on;
errorbar([mean(responseRatiosZeroContrast) mean(responseRatiosLoContrast) mean(responseRatiosHiContrast)],...
    [std(responseRatiosZeroContrast) std(responseRatiosLoContrast) std(responseRatiosHiContrast)]);
%% what was the increase in spiking rate wrt contrast
% what fraction of neurons are responding?
spikeRates = [];
numRecorded = [];
contrast = [];
orientation = [];
actualStimDuration = [];

for i = setdiff(1:length(DETAILS),[7,9,10,11,17,35])
    contrast = [contrast;DETAILS{i}{1}.contrasts];
    orientation = [orientation;DETAILS{i}{1}.orientations];
    actualStimDuration = [actualStimDuration;DETAILS{i}{1}.actualStimDurations];
    spikeRates = [spikeRates;nanmean(DETAILS{i}{1}.spikeRatesActual,2)];
end

contrastZeros = contrast ==0; nZero = sum(contrastZeros);
contrastLo = contrast==0.15; nLo = sum(contrastLo);
contrastHi = contrast==1; nHi = sum(contrastHi);
spikeRateZeroContrast = spikeRates(contrastZeros);
spikeRateLoContrast = spikeRates(contrastLo);
spikeRateHiContrast = spikeRates(contrastHi);

fprintf('spikeRates across all contrats:%2.2f\n',nanmean(spikeRates));
fprintf('spikeRates for zero contrast:%2.2f\n',mean(spikeRateZeroContrast));
fprintf('spikeRates for lo contrasts:%2.2f\n',mean(spikeRateLoContrast));
fprintf('spikeRates for hi contrasts:%2.2f\n',mean(spikeRateHiContrast));

% errorbar([mean(spikeRateZeroContrast) mean(spikeRateLoContrast) mean(spikeRateHiContrast)],...
%     [2*std(spikeRateZeroContrast)/sqrt(nZero) 2*std(spikeRateLoContrast)/sqrt(nLo) 2*std(spikeRateHiContrast)/sqrt(nHi)]);
% violin({log10(spikeRateZeroContrast(~(spikeRateZeroContrast==0))),...
%     log10(spikeRateLoContrast(~(spikeRateLoContrast==0))),...
%     log10(spikeRateHiContrast(~(spikeRateHiContrast==0)))},...
%     'xlabel',{'C=0','Lo','Hi'},'facealpha',0.2,'medc',[]);

violin({spikeRateZeroContrast,...
    spikeRateLoContrast,...
    spikeRateHiContrast},...
    'xlabel',{'C=0','Lo','Hi'},'facealpha',0.2,'medc',[]);

errorbar([mean(spikeRateZeroContrast) mean(spikeRateLoContrast) mean(spikeRateHiContrast)],...
    [std(spikeRateZeroContrast) std(spikeRateLoContrast) std(spikeRateHiContrast)]);