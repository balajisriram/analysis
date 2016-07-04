

saveLoc = 'D:\Response_100';

clc;
sessLocation = 'D:\070\070_InspectedSessions';
d = dir(sessLocation);
d = d(~ismember({d.name},{'.','..'}));
for i = 19:length(d)
    clear sess
    d1 = dir(fullfile(saveLoc,d(i).name));
    if ~isempty(d1)
         fprintf('\n%s : ALREADY COMPLETED\n',d(i).name);
         continue
    end
    load(fullfile(sessLocation,d(i).name));
    try
        spikeRasters = sess.getStimAndSpikeNumberDetails(100);
        fprintf('\n%s : SUCCESS\n',d(i).name);
        save(fullfile(saveLoc,d(i).name),'spikeRasters');
    catch ex
        fprintf('\n%s : FAILED\n',d(i).name);
    end
end


sessLocation = 'D:\072\072_InspectedSessions';
d = dir(sessLocation);
d = d(~ismember({d.name},{'.','..'}));
for i = 2:length(d)
    clear sess
    d1 = dir(fullfile(saveLoc,d(i).name));
    if ~isempty(d1)
         fprintf('\n%s : ALREADY COMPLETED\n',d(i).name);
         continue
    end
    load(fullfile(sessLocation,d(i).name));
    try
        spikeRasters = sess.getStimAndSpikeNumberDetails(100);
        fprintf('\n%s : SUCCESS\n',d(i).name);
        save(fullfile(saveLoc,d(i).name),'spikeRasters');
    catch ex
        fprintf('\n%s : FAILED\n',d(i).name);
    end
end

sessLocation = 'D:\074\074_InspectedSessions';
d = dir(sessLocation);
d = d(~ismember({d.name},{'.','..'}));
for i = 1:length(d)
    clear sess
    d1 = dir(fullfile(saveLoc,d(i).name));
    if ~isempty(d1)
         fprintf('\n%s : ALREADY COMPLETED\n',d(i).name);
         continue
    end
    load(fullfile(sessLocation,d(i).name));
    try
        spikeRasters = sess.getStimAndSpikeNumberDetails(100);
        fprintf('\n%s : SUCCESS\n',d(i).name);
        save(fullfile(saveLoc,d(i).name),'spikeRasters');
    catch ex
        fprintf('\n%s : FAILED\n',d(i).name);
    end
end