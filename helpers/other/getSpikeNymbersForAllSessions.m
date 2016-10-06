

saveLoc = {'F:\Response_0','F:\Response_10','F:\Response_50','F:\Response_100','F:\Response_200','F:\Response_500'};

clc;
sessLocation = 'F:\070\070_InspectedSessions';
d = dir(sessLocation);
d = d(~ismember({d.name},{'.','..'}));
for i = 1:length(d)
    clear sess
    d1 = dir(fullfile(saveLoc{1},d(i).name));
    if ~isempty(d1)
         fprintf('\n%s : ALREADY COMPLETED\n',d(i).name);
         continue
    end
    load(fullfile(sessLocation,d(i).name));
    try
        spikeRasters = sess.getStimAndSpikeNumberDetails(0);
        save(fullfile(saveLoc{1},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(10);
        save(fullfile(saveLoc{2},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(50);
        save(fullfile(saveLoc{3},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(100);
        save(fullfile(saveLoc{4},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(200);
        save(fullfile(saveLoc{5},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(500);
        save(fullfile(saveLoc{6},d(i).name),'spikeRasters');
        fprintf('\n%s : SUCCESS\n',d(i).name);
    catch ex
        fprintf('\n%s : FAILED\n',d(i).name);
    end
end


sessLocation = 'F:\072\072_InspectedSessions';
d = dir(sessLocation);
d = d(~ismember({d.name},{'.','..'}));
for i = 1:length(d)
    clear sess
    d1 = dir(fullfile(saveLoc{1},d(i).name));
    if ~isempty(d1)
         fprintf('\n%s : ALREADY COMPLETED\n',d(i).name);
         continue
    end
    load(fullfile(sessLocation,d(i).name));
    try
        spikeRasters = sess.getStimAndSpikeNumberDetails(0);
        save(fullfile(saveLoc{1},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(10);
        save(fullfile(saveLoc{2},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(50);
        save(fullfile(saveLoc{3},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(100);
        save(fullfile(saveLoc{4},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(200);
        save(fullfile(saveLoc{5},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(500);
        save(fullfile(saveLoc{6},d(i).name),'spikeRasters');
        fprintf('\n%s : SUCCESS\n',d(i).name);
    catch ex
        fprintf('\n%s : FAILED\n',d(i).name);
    end
end

sessLocation = 'F:\074\074_InspectedSessions';
d = dir(sessLocation);
d = d(~ismember({d.name},{'.','..'}));
for i = 1:length(d)
    clear sess
    d1 = dir(fullfile(saveLoc{1},d(i).name));
    if ~isempty(d1)
         fprintf('\n%s : ALREADY COMPLETED\n',d(i).name);
         continue
    end
    load(fullfile(sessLocation,d(i).name));
    try
        spikeRasters = sess.getStimAndSpikeNumberDetails(0);
        save(fullfile(saveLoc{1},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(10);
        save(fullfile(saveLoc{2},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(50);
        save(fullfile(saveLoc{3},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(100);
        save(fullfile(saveLoc{4},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(200);
        save(fullfile(saveLoc{5},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(500);
        save(fullfile(saveLoc{6},d(i).name),'spikeRasters');
        fprintf('\n%s : SUCCESS\n',d(i).name);
    catch ex
        fprintf('\n%s : FAILED\n',d(i).name);
    end
end

sessLocation = 'F:\077\InspectedSessions';
d = dir(sessLocation);
d = d(~ismember({d.name},{'.','..'}));
for i = 1:length(d)
    clear sess
    d1 = dir(fullfile(saveLoc{1},d(i).name));
    if ~isempty(d1)
         fprintf('\n%s : ALREADY COMPLETED\n',d(i).name);
         continue
    end
    load(fullfile(sessLocation,d(i).name));
    try
        spikeRasters = sess.getStimAndSpikeNumberDetails(0);
        save(fullfile(saveLoc{1},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(10);
        save(fullfile(saveLoc{2},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(50);
        save(fullfile(saveLoc{3},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(100);
        save(fullfile(saveLoc{4},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(200);
        save(fullfile(saveLoc{5},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(500);
        save(fullfile(saveLoc{6},d(i).name),'spikeRasters');
        fprintf('\n%s : SUCCESS\n',d(i).name);
    catch ex
        fprintf('\n%s : FAILED\n',d(i).name);
    end
end

sessLocation = 'F:\079\InspectedSessions';
d = dir(sessLocation);
d = d(~ismember({d.name},{'.','..'}));
for i = 1:length(d)
    clear sess
    d1 = dir(fullfile(saveLoc{1},d(i).name));
    if ~isempty(d1)
         fprintf('\n%s : ALREADY COMPLETED\n',d(i).name);
         continue
    end
    load(fullfile(sessLocation,d(i).name));
    try
        spikeRasters = sess.getStimAndSpikeNumberDetails(0);
        save(fullfile(saveLoc{1},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(10);
        save(fullfile(saveLoc{2},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(50);
        save(fullfile(saveLoc{3},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(100);
        save(fullfile(saveLoc{4},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(200);
        save(fullfile(saveLoc{5},d(i).name),'spikeRasters');
        spikeRasters = sess.getStimAndSpikeNumberDetails(500);
        save(fullfile(saveLoc{6},d(i).name),'spikeRasters');
        fprintf('\n%s : SUCCESS\n',d(i).name);
    catch ex
        fprintf('\n%s : FAILED\n',d(i).name);
    end
end