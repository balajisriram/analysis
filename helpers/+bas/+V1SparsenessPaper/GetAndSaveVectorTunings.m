%% Characterize the firing rates
warning off;
dataFolders = {...
    'C:\Users\Ghosh\Desktop\PhysData\284\InspectedSessions',...
    'C:\Users\Ghosh\Desktop\PhysData\070\InspectedSessions',...
    'C:\Users\Ghosh\Desktop\PhysData\072\InspectedSessions',...
    'C:\Users\Ghosh\Desktop\PhysData\074\InspectedSessions'};

saveLoc = 'C:\Users\Ghosh\Desktop\PhysAnalysis\VectorSumNorm';

numUnitsTotal = 0;
frUnits = [];
swUnits = [];
failures = [];
for i = 1:length(dataFolders);
    fprintf('i = %d\n',i);
    d = dir(dataFolders{i});
    d = d(~ismember({d.name},{'.','..'}));
    for j = 1:length(d)
        fprintf('filename = %s\n',d(j).name);
        try
            temp = load(fullfile(dataFolders{i},d(j).name));
            out = temp.sess.getAllOrVectors;
            save(fullfile(saveLoc,d(j).name),'out');clear out;
        catch ex
            disp('failed')
            close all;
            failures(end+1).which = d(j).name;
            failures (end).reason = ex;
            clear out
        end
    end
end