function sess = processAndSaveSession( dataFolder )

% add paths
addpath(genpath(pwd));

%these remain constant no matter what file is selected
monitor = ViewSonicV3D245('one');
etrode = NNX_Buszaki32_CM32();
rigState = StandardRigJuly2015();


sessionPath = dataFolder(1:find(dataFolder=='\',1, 'last')-1);
sessionFolder = dataFolder((find(dataFolder=='\',1, 'last')+1):length(dataFolder));
subject = sessionFolder(1:find(sessionFolder == '_')-1);
trialDataPath = fullfile(sessionPath,sessionFolder);
keyboard
sess = Session(subject,sessionPath,sessionFolder,trialDataPath, etrode, monitor, rigState);

%decides which mappings to use based on MACaddress of computer running
%program.
[~, b] = getMACaddress();
if strcmp(b, 'F8BC128444CB') || strcmp(b, '6805CA25DFB1') %two analysis computers
    mappings = 'phys';
else                                %otherwise must be one of behavior computers
    mappings = 'behavior';
end

sess = process(sess, mappings);
    
saveSession(sess);

end

