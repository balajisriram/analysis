sessLocation = 'D:\074\074_InspectedSessions';
stimLocation = 'D:\074\StimRecords';
clc;
d = dir(sessLocation);
d = d(~ismember({d.name},{'.','..'}));
for i = 1
    
    clear sess
    load(fullfile(sessLocation,d(i).name));
    
    
    fprintf('\n%s : SUMMARY\n',d(i).name);
    sess.summarizeTrialDetails;
    fprintf('\n============================================================================');
    fprintf('\n============================================================================\n');
end