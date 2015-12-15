function sess = processAndSaveSession( dataFolder )

% add paths
addpath(genpath(pwd));

%these remain constant no matter what file is selected
monitor = ViewSonicV3D245('one');
etrode = NNX_A1x32_Poly3_5mm_25s_117();
rigState = StandardRigJuly2015();


sessionPath = dataFolder(1:find(dataFolder=='\',1, 'last')-1);
sessionFolder = dataFolder((find(dataFolder=='\',1, 'last')+1):length(dataFolder));
subject = sessionFolder(1:find(sessionFolder == '_')-1);
trialDataPath = fullfile(sessionPath,sessionFolder);

sess = Session(subject,sessionPath,sessionFolder,trialDataPath, etrode, monitor, rigState);

sess = process(sess, 'phys');
    
saveSession(sess);

end

