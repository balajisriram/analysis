%% Load trialDetails to all!

dataFolders = {'C:\Users\ghosh\Desktop\PhysData\284\InspectedSessions',...
    'C:\Users\ghosh\Desktop\PhysData\bas070\InspectedSessions',...
    'C:\Users\ghosh\Desktop\PhysData\bas072\InspectedSessions',...
    'C:\Users\ghosh\Desktop\PhysData\bas074\InspectedSessions'};
numUnitsTotal = 0;

failures = [];
for i = 1:length(dataFolders)
    fprintf('i = %d\n',i);
    d = dir(dataFolders{i});
    d = d(~ismember({d.name},{'.','..'}));
    for j = 1:length(d)
        fprintf('filename = %s\t:',d(j).name);
        clear sess;
        fileName = fullfile(dataFolders{i},d(j).name);
        load(fileName); % get sess on!
        try
            % get the StimFolder and date
            stimBaseFolder = fullfile(fileparts(fileparts(fileName)),'StimRecords');
            finds = strfind(d(j).name,'_');
            % first find is subject name
            dateRec = d(j).name(finds(1)+1:finds(2)-1);
            stimSubFolder = datestr(datetime(dateRec),'mmddyyyy');
            stimFolder = fullfile(stimBaseFolder,stimSubFolder);
            sess = sess.populateTrialDetails(stimFolder);
            save(fileName,'sess');
            fprintf('SUCCESS\n');
            clear sess
        catch ex
            fprintf('FAILURE\n');
            failures(end+1).sessionName = d(j).name;
            failures(end).reason = ex;
        end
    end
end