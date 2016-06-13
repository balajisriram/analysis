function sess = processAndSaveSession( dataFolder )

% add paths
addpath(genpath(pwd));

%these remain constant no matter what file is selected
monitor = ViewSonicV3D245('one');
etrode = NNX_A1x32_Poly3_5mm_25s_117();
rigState = StandardRigJuly2015();

switch computer
    case 'MACI64'
        sessionPath = dataFolder(1:find(dataFolder=='/',1, 'last')-1);
        sessionFolder = dataFolder((find(dataFolder=='/',1, 'last')+1):length(dataFolder));
        subject = sessionFolder(1:find(sessionFolder == '_')-1);
        trialDataPath = fullfile(sessionPath,sessionFolder);
    otherwise
        
        sessionPath = dataFolder(1:find(dataFolder=='\',1, 'last')-1);
        sessionFolder = dataFolder((find(dataFolder=='\',1, 'last')+1):length(dataFolder));
        subject = sessionFolder(1:find(sessionFolder == '_')-1);
        trialDataPath = fullfile(sessionPath,sessionFolder);
end
sess = Session(subject,sessionPath,sessionFolder,trialDataPath, etrode, monitor, rigState);

%decides which mappings to use based on MACaddress of computer running
%program.
[~, b] = getMACaddress();
if strcmp(b, 'F8BC128444CB') || strcmp(b, '6805CA25DFB1') %two analysis computers
    mappings = 'phys';
else                                %otherwise must be one of behavior computers
    mappings = 'phys';
end

sess = process(sess, mappings);
    
saveSession(sess);

end

