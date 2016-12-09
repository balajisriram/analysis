% This script loops over sessions collects information about 
% (1)  'gratings_LED'

clear all;
%loc = 'F:\workingSessionsnoWaveform';
loc = '/media/ghosh/My Passport1/workingSessionsnoWaveform';
d = dir(fullfile(loc,'*.mat'));

SPIKEDETAILS = {};
FIRINGRATE = {};
OSIS = {};
OSIJACKKNIFE = {};
ORVECTOR = {};
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
    catch ex
        getReport(ex)
        spikeDetails0 = [];
        spikeDetails50 = [];
        spikeDetails100 = [];
        spikeDetails200 = [];
        spikeDetails500 = [];
        spikeDetails1000 = [];
    end
    spikeDetails0.sessionName = d(j).name;
    spikeDetails50.sessionName = d(j).name;
    spikeDetails100.sessionName = d(j).name;
    spikeDetails200.sessionName = d(j).name;
    spikeDetails500.sessionName = d(j).name;
    spikeDetails1000.sessionName = d(j).name;
    
%     osi.sessionName = d(j).name;
    
    SPIKEDETAILS{end+1} = {spikeDetails0,spikeDetails50,...
        spikeDetails100,spikeDetails200,spikeDetails500,...
        spikeDetails1000};
    
%         case 'OSIs'
%             out = sess.getAllOSI();
%         case 'OSIsWithJackKnife'
%             out = sess.getAllOSIWithJackKnife();
%         case 'OrientedVectorWithJackKnife'
%             out = sess.getAllOrVectorsWithJackKnife();
%     end
                    
    try
        firingRate = sess.getFeature('FiringRate');
    catch ex
        getReport(ex)
        firingRate = [];
    end
    firingRate.sessionName = d(j).name;
    FIRINGRATE{end+1} = firingRate;
    
    try
        osi = sess.getFeature('OSIs');
    catch ex
        getReport(ex)
        osi = [];
    end
    osi.sessionName = d(j).name;
    OSIS{end+1} = osi;
    
    try
        OSIJackKnife = sess.getFeature('OSIsWithJackKnife');
    catch ex
        getReport(ex)
        OSIJackKnife = [];
    end
    OSIJackKnife.sessionName = d(j).name;
    OSIJACKKNIFE{end+1} = OSIJackKnife;
    
    try
        ORVector = sess.getFeature('OrientedVectorWithJackKnife');
    catch ex
        getReport(ex)
        ORVector = [];
    end
    ORVector.sessionName = d(j).name;
    ORVECTOR{end+1} = ORVector;
    
end
% save('DetailsAtVariousTimescales.mat','SPIKEDETAILS');