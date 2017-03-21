% % This script loops over sessions collects information about 
% % (1)  'gratings_LED'
% 
% clear all;
% %loc = 'F:\workingSessionsnoWaveform';
% loc = '/media/ghosh/My Passport1/workingSessionsnoWaveform';
% d = dir(fullfile(loc,'*.mat'));
% 
% SPIKEDETAILS = {};
% 
% for j = 1:length(d)
%     disp(j)
%     clear sess
%     load(fullfile(loc,d(j).name));
%     disp(d(j).name)
%     
%     % firing Rates and OSI
%     try
%         spikeDetails_10 = sess.getFeature('SpikeAndStimDetails',-0.01);
%         spikeDetails_25 = sess.getFeature('SpikeAndStimDetails',-0.025);
%         spikeDetails_50 = sess.getFeature('SpikeAndStimDetails',-0.05);
%         spikeDetails_75 = sess.getFeature('SpikeAndStimDetails',-0.075);
%         spikeDetails_100 = sess.getFeature('SpikeAndStimDetails',-0.1);
%         spikeDetails10 = sess.getFeature('SpikeAndStimDetails',0.01);
%         spikeDetails25 = sess.getFeature('SpikeAndStimDetails',0.025);
%         spikeDetails50 = sess.getFeature('SpikeAndStimDetails',0.05);
%         spikeDetails75 = sess.getFeature('SpikeAndStimDetails',0.075);
%         spikeDetails100 = sess.getFeature('SpikeAndStimDetails',0.1);
%         spikeDetails150 = sess.getFeature('SpikeAndStimDetails',0.15);
%         spikeDetails200 = sess.getFeature('SpikeAndStimDetails',0.2);
%         spikeDetails250 = sess.getFeature('SpikeAndStimDetails',0.25);
%         spikeDetails300 = sess.getFeature('SpikeAndStimDetails',0.3);
%         spikeDetails350 = sess.getFeature('SpikeAndStimDetails',0.35);
%         spikeDetails400 = sess.getFeature('SpikeAndStimDetails',0.4);
%         spikeDetails450 = sess.getFeature('SpikeAndStimDetails',0.45);
%         spikeDetails500 = sess.getFeature('SpikeAndStimDetails',0.5);
%         
%     catch ex
%         getReport(ex)
%         spikeDetails_10 = [];
%         spikeDetails_25 = [];
%         spikeDetails_50 = [];
%         spikeDetails_75 = [];
%         spikeDetails_100 = [];
%         spikeDetails10 = [];
%         spikeDetails25 = [];
%         spikeDetails50 = [];
%         spikeDetails75 = [];
%         spikeDetails100 = [];
%         spikeDetails150 = [];
%         spikeDetails200 = [];
%         spikeDetails250 = [];
%         spikeDetails300 = [];
%         spikeDetails350 = [];
%         spikeDetails400 = [];
%         spikeDetails450 = [];
%         spikeDetails500 = [];
% 
%     end
%     spikeDetails_10.sessionName = d(j).name;
%     spikeDetails_25.sessionName = d(j).name;
%     spikeDetails_50.sessionName = d(j).name;
%     spikeDetails_75.sessionName = d(j).name;
%     spikeDetails_100.sessionName = d(j).name;
%     spikeDetails10.sessionName = d(j).name;
%     spikeDetails25.sessionName = d(j).name;
%     spikeDetails50.sessionName = d(j).name;
%     spikeDetails75.sessionName = d(j).name;
%     spikeDetails100.sessionName = d(j).name;
%     spikeDetails150.sessionName = d(j).name;
%     spikeDetails200.sessionName = d(j).name;
%     spikeDetails250.sessionName = d(j).name;
%     spikeDetails300.sessionName = d(j).name;
%     spikeDetails350.sessionName = d(j).name;
%     spikeDetails400.sessionName = d(j).name;
%     spikeDetails450.sessionName = d(j).name;
%     spikeDetails500.sessionName = d(j).name;
% 
%     spikeDetails_10.collectionMode = '-10';
%     spikeDetails_25.collectionMode = '-25';
%     spikeDetails_50.collectionMode = '-50';
%     spikeDetails_75.collectionMode = '-75';
%     spikeDetails_100.collectionMode = '-100';
%     spikeDetails10.collectionMode = '10';
%     spikeDetails25.collectionMode = '25';
%     spikeDetails50.collectionMode = '50';
%     spikeDetails75.collectionMode = '75';
%     spikeDetails100.collectionMode = '100';
%     spikeDetails150.collectionMode = '150';
%     spikeDetails200.collectionMode = '200';
%     spikeDetails250.collectionMode = '250';
%     spikeDetails300.collectionMode = '300';
%     spikeDetails350.collectionMode = '350';
%     spikeDetails400.collectionMode = '400';
%     spikeDetails450.collectionMode = '450';
%     spikeDetails500.collectionMode = '500';
% 
% %     osi.sessionName = d(j).name;
%     
%     SPIKEDETAILS{end+1} = {...
%         spikeDetails_10,...
%         spikeDetails_25,...
%         spikeDetails_50,...
%         spikeDetails_75,...
%         spikeDetails_100,...
%         spikeDetails10,...
%         spikeDetails25,...
%         spikeDetails50,...
%         spikeDetails75,...
%         spikeDetails100,...
%         spikeDetails150,...
%         spikeDetails200,...
%         spikeDetails250,...
%         spikeDetails300,...
%         spikeDetails350,...
%         spikeDetails400,...
%         spikeDetails450,...
%         spikeDetails500,...
%         };
%     
% %         case 'OSIs'
% %             out = sess.getAllOSI();
% %         case 'OSIsWithJackKnife'
% %             out = sess.getAllOSIWithJackKnife();
% %         case 'OrientedVectorWithJackKnife'
% %             out = sess.getAllOrVectorsWithJackKnife();
% %     end
%                     
%     
% end
% save('DetailsAtVariousTimescales_Detailed2.mat','SPIKEDETAILS');


% This script loops over sessions collects information about 
% (1)  'gratings_LED'

clear all;
loc = 'E:\workingSessionsnoWaveform';
% loc = '/media/ghosh/My Passport1/workingSessionsnoWaveform';
d = dir(fullfile(loc,'*.mat'));

SPIKEDETAILS = {};

for j = 1:length(d)
    disp(j)
    clear sess
    load(fullfile(loc,d(j).name));
    disp(d(j).name)
    
    % firing Rates and OSI
    try
        spikeDetails_500_stimStart = sess.getFeature('SpikeAndStimDetails-500');
        if all(all(isnan(spikeDetails_500_stimStart.spikeNumsActual)))
            keyboard
        end
    catch ex
        getReport(ex)
        spikeDetails_500_stimStart = [];
    end
    spikeDetails_500_stimStart.sessionName = d(j).name;

    spikeDetails_500_stimStart.collectionMode = '_500';
   
    SPIKEDETAILS{end+1} = {...
        spikeDetails_500_stimStart,...
        };

end
save('DetailsAt500MS.mat','SPIKEDETAILS');