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
        spikeNum = sess.getFeature('SpikeNumForTest');
        spikeRate = sess.getFeature('SpikeRateForTest');
        stimDuration = sess.getFeature('stimulusDuration');
    catch ex
        spikeNum = [];
        spikeRate = [];
        stimDuration = [];
    end
    spikeNum.sessionName = d(j).name;
    spikeRate.sessionName = d(j).name;
    stimDuration.sessionName = d(j).name;
    DETAILS{end+1} = {spikeNum,spikeRate,stimDuration};
end
% 
save('Details_SpikeDetails.mat','DETAILS');