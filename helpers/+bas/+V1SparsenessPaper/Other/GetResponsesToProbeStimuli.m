clear all;
% loc = '/media/ghosh/My Passport/workingSessions';
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
        fr = sess.getFeature('FiringRate');
        osi = sess.getFeature('OSIsWithJackKnife');
    catch ex
        getReport(ex)
        fr = [];
        osi = [];
    end
    fr.sessionName = d(j).name;
    osi.sessionName = d(j).name;
    DETAILS{end+1} = {fr,osi};
end

save('Details.mat','DETAILS');
