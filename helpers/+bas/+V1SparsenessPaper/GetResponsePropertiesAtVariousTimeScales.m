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
        spikeDetails0 = sess.getFeature('SpikeAndStimDetails0');
        spikeDetails50 = sess.getFeature('SpikeAndStimDetails50');
        spikeDetails100 = sess.getFeature('SpikeAndStimDetails100');
        spikeDetails200 = sess.getFeature('SpikeAndStimDetails200');
        spikeDetails500 = sess.getFeature('SpikeAndStimDetails500');
        spikeDetails1000 = sess.getFeature('SpikeAndStimDetails1000');
        osi = sess.getFeature('OSIs');
    catch ex
        getReport(ex)
        spikeDetails0 = [];
        spikeDetails50 = [];
        spikeDetails100 = [];
        spikeDetails200 = [];
        spikeDetails500 = [];
        spikeDetails1000 = [];
        osi = [];
    end
    spikeDetails0.sessionName = d(j).name;
    spikeDetails50.sessionName = d(j).name;
    spikeDetails100.sessionName = d(j).name;
    spikeDetails200.sessionName = d(j).name;
    spikeDetails500.sessionName = d(j).name;
    spikeDetails1000.sessionName = d(j).name;
    
    osi.sessionName = d(j).name;
    
    DETAILS{end+1} = {spikeDetails,osi};
end