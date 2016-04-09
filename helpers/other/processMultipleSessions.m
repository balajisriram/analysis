function s = processMultipleSessions( dataFolder )
% process multiple sessions in one command to allow things to run overnight
% or over the weekend without any user interaction needed.
% NOTE: run from Desktop\analysis

% add paths
addpath(genpath(pwd))

%these remain constant no matter what file is selected
monitor = ViewSonicV3D245('one');
etrode = A1x32Poly2();
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
    
    session = process(sess);
    
    saveSession(session);
end

s = true;

end

