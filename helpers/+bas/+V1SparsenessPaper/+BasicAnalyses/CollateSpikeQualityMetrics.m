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
