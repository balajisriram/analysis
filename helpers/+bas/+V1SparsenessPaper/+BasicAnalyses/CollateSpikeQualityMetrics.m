% This script loops over sessions collects information about 
% (1) Statistics of SpikeQuality

clear all;
loc = '/media/ghosh/My Passport/workingSessions';
% loc = 'E:\workingSessionsnoWaveform';
d = dir(fullfile(loc,'*.mat'));

DETAILS = {};
problems = []; % 35, 27 22, 21, 19, 14 12 % 11, 10, 9, 7 is weird
for j = 1:length(d)
    disp(j)
    clear sess
    load(fullfile(loc,d(j).name));
    disp(d(j).name)
    
    % firing Rates and OSI
    try
        SpikeQual = sess.getFeature('SpikeQualityMahal');
    catch ex
        SpikeQual = [];
        
    end
    SpikeQual.sessionName = d(j).name;
    DETAILS{end+1} = {SpikeQual};
end
% 
save('Details_SpikeQuality.mat','DETAILS');
%%
clear all
load Details_SpikeQuality_NoExtras
unitID = {};
quals = [];
contamRates = [];
for i = 1:length(DETAILS)
    [~,sessName] = fileparts(DETAILS{i}{1}.sessionName);
    for j = 1:length(DETAILS{i}{1}.uID)
        unitID{end+1} = sprintf('%s_%s',sessName,DETAILS{i}{1}.uID{j});
        quals(end+1) = DETAILS{i}{1}.quality(j);
        contamRates(end+1) = DETAILS{i}{1}.contaminationRate(j);
    end
end
SpikeQualityTable = table(unitID',quals',contamRates','VariableNames',{'uID','spikeQuality','contaminationRate'});
