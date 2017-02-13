% This script loops over sessions collects information about 
% (1)  'gratings_LED'

clear all;
%loc = 'F:\workingSessionsnoWaveform';
loc = '/media/ghosh/My Passport1/workingSessionsnoWaveform';
d = dir(fullfile(loc,'*.mat'));

SPIKEDETAILS = {};

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
        
        spikeDetails_0 = sess.getFeature('SpikeAndStimDetails-0');
        spikeDetails_50 = sess.getFeature('SpikeAndStimDetails-50');
        spikeDetails_100 = sess.getFeature('SpikeAndStimDetails-100');
        spikeDetails_200 = sess.getFeature('SpikeAndStimDetails-200');
        spikeDetails_500 = sess.getFeature('SpikeAndStimDetails-500');
        spikeDetails_1000 = sess.getFeature('SpikeAndStimDetails-1000');
        spikeDetails_5000 = sess.getFeature('SpikeAndStimDetails-5000');
    catch ex
        getReport(ex)
        spikeDetails0 = [];
        spikeDetails50 = [];
        spikeDetails100 = [];
        spikeDetails200 = [];
        spikeDetails500 = [];
        spikeDetails1000 = [];
        
        spikeDetails_0 = [];
        spikeDetails_50 = [];
        spikeDetails_100 = [];
        spikeDetails_200 = [];
        spikeDetails_500 = [];
        spikeDetails_1000 = [];
        spikeDetails_5000 = [];
    end
    spikeDetails0.sessionName = d(j).name;
    spikeDetails50.sessionName = d(j).name;
    spikeDetails100.sessionName = d(j).name;
    spikeDetails200.sessionName = d(j).name;
    spikeDetails500.sessionName = d(j).name;
    spikeDetails1000.sessionName = d(j).name;

    spikeDetails_0.sessionName = d(j).name;
    spikeDetails_50.sessionName = d(j).name;
    spikeDetails_100.sessionName = d(j).name;
    spikeDetails_200.sessionName = d(j).name;
    spikeDetails_500.sessionName = d(j).name;
    spikeDetails_1000.sessionName = d(j).name;
    spikeDetails_5000.sessionName = d(j).name;

    spikeDetails0.collectionMode = '0';
    spikeDetails50.collectionMode = '50';
    spikeDetails100.collectionMode = '100';
    spikeDetails200.collectionMode = '200';
    spikeDetails500.collectionMode = '500';
    spikeDetails1000.collectionMode = '1000';

    spikeDetails_0.collectionMode = '_0';
    spikeDetails_50.collectionMode = '_50';
    spikeDetails_100.collectionMode = '_100';
    spikeDetails_200.collectionMode = '_200';
    spikeDetails_500.collectionMode = '_500';
    spikeDetails_1000.collectionMode = '_1000';
    spikeDetails_5000.collectionMode = '_5000';

%     osi.sessionName = d(j).name;
    
    SPIKEDETAILS{end+1} = {spikeDetails0,spikeDetails50,spikeDetails100,spikeDetails200,spikeDetails500,spikeDetails1000,...
        spikeDetails_0,spikeDetails_50,spikeDetails_100,spikeDetails_200,spikeDetails_500,spikeDetails_1000,spikeDetails_5000,...
        };
    
%         case 'OSIs'
%             out = sess.getAllOSI();
%         case 'OSIsWithJackKnife'
%             out = sess.getAllOSIWithJackKnife();
%         case 'OrientedVectorWithJackKnife'
%             out = sess.getAllOrVectorsWithJackKnife();
%     end
                    
    
end
save('DetailsAtVariousTimescales.mat','SPIKEDETAILS');