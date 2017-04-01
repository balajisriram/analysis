clear all;
%loc = 'F:\workingSessionsnoWaveform';
loc = '/media/ghosh/My Passport1/workingSessionsnoWaveform';
d = dir(fullfile(loc,'*.mat'));

STIMDURATION = {};

for j = 1:length(d)
    disp(j)
    clear sess
    load(fullfile(loc,d(j).name));
    disp(d(j).name)
    
    % firing Rates and OSI
    try
        stimDuration = sess.getFeature('StimStartTimes');
        
    catch ex
        getReport(ex)
        stimDuration = [];

    end
    stimDuration.sessionName = d(j).name;
    STIMDURATION{end+1} = {...
        stimDuration,...
        };
end

%% now get details from stuff
for i = 1:58
    try
        disp(min(diff(STIMDURATION{i}{1}.stimStartTime)))
    catch ex
        fprintf('no info for %d\n',i)
    end
end