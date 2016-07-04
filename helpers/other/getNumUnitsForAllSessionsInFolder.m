sessLocation = 'D:\070\070_InspectedSessions';
stimLocation = 'D:\074\StimRecords';
clc;
d = dir(sessLocation);
d = d(~ismember({d.name},{'.','..'}));
for i = 1:length(d)
    
    clear sess
    load(fullfile(sessLocation,d(i).name));
    
    
    fprintf('\n%s : numUnits: %d\n',d(i).name,sess.numUnits);
end