%% Characterize the firing rates
warning off;
dataFolders = {'C:\Users\ghosh\Desktop\PhysData\284\284_InspectedPhys','C:\Users\ghosh\Desktop\PhysData\bas070\InspectedSessions',...
    'C:\Users\ghosh\Desktop\PhysData\bas072\InspectedSessions','C:\Users\ghosh\Desktop\PhysData\bas074\InspectedSessions'};
numUnitsTotal = 0;
frUnits = [];
swUnits = [];
for i = 1:length(dataFolders);
    fprintf('i = %d\n',i);
    d = dir(dataFolders{i});
    d = d(~ismember({d.name},{'.','..'}));
    for j = 1:length(d)
        fprintf('filename = %s\n',d(i).name);
        temp = load(fullfile(dataFolders{i},d(i).name));
        numUnitstotal = temp.sess.numUnits;
        swUnits = [swUnits temp.sess.spikeWidths];
        frUnits = [frUnits temp.sess.firingRates];
    end
end
