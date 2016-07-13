function s = processMultipleSessions( dataFolder )
% process multiple sessions in one command to allow things to run overnight
% or over the weekend without any user interaction needed.
% NOTE: run from Desktop\analysis

% add paths
addpath(genpath(pwd))

%these remain constant no matter what file is selected
monitor = ViewSonicV3D245('one');
etrode = NNX_Buszaki32_CM32();
rigState = StandardRigJuly2015();

%gets all folders starting with 'bas'
sessionFolders = dir(fullfile(dataFolder,'bas*'));

keyboard
%loops through all session folders
for folder = sessionFolders'
    subject = folder.name(1:find(folder.name == '_')-1);
    sessionPath = dataFolder;
    sessionFolder = folder.name;
    trialDataPath = fullfile(sessionPath,sessionFolder);
    
    sess = Session(subject,sessionPath,sessionFolder,trialDataPath, etrode, monitor, rigState);
    
    [~, b] = getMACaddress();
    if strcmp(b, 'F8BC128444CB') || strcmp(b, '6805CA25DFB1') %two analysis computers
        mappings = 'phys';
    else                                %otherwise must be one of behavior computers
        mappings = 'phys';
    end
    sess = process(sess, mappings);
    
    saveSession(sess);
end

s = true;

end

