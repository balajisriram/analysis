%% Characterize the firing rates

warning off;
dataFolders = {'E:\workingSessions'};
numUnitsTotal = 0;
frUnits = [];
swUnits = [];
sessNames = {};
for i = 1:length(dataFolders);
    fprintf('i = %d\n',i);
    d = dir(fullfile(dataFolders{i},'*.mat'));
    d = d(~ismember({d.name},{'.','..'}));
    for j = 1:length(d)
        fprintf('filename = %s\n',d(j).name);
        temp = load(fullfile(dataFolders{i},d(j).name));
        numUnitstotal = temp.sess.numUnits;
        swUnits = [swUnits temp.sess.spikeWidths];
        frUnits = [frUnits temp.sess.getAllFiringRates];
        sessNames{end+1} = d(j).name;
    end
end
%% pull out the data one at a time and make a table
spikeWidths = [];
unitID = {};
for i = 1:length(swUnits)
    for j = 1:length(swUnits(i).sw)
        spikeWidths(end+1) = swUnits(i).sw(j);
        unitID{end+1} = sprintf('%s_%s',sessNames{i},swUnits(i).uid{j});
    end
end
SpikeWidthTable = table(unitID',spikeWidths','VariableNames',{'uID','spikeWidth'});

%% 
firingRates = [];
unitID = {};
for i = 1:length(frUnits)
    for j = 1:length(frUnits(i).firingRates)
        firingRates(end+1) = frUnits(i).firingRates(j);
        unitID{end+1} = sprintf('%s_%s',sessNames{i},frUnits(i).uid{j});
    end
end
FiringRateTable = table(unitID',firingRates','VariableNames',{'uID','firingRate'});
%% Characterize correlations

dataFolders = {'C:\Users\Ghosh\Desktop\PhysData\070\070_InspectedSessions',...
    'C:\Users\Ghosh\Desktop\PhysData\072\072_InspectedSessions',...
    'C:\Users\Ghosh\Desktop\PhysData\074\074_InspectedSessions',...
    'C:\Users\Ghosh\Desktop\PhysData\284\284_InspectedPhys'};
correlations = {};
k = 0;
failures = [];
for i = 1:length(dataFolders);
    fprintf('i = %d\n',i);
    d = dir(dataFolders{i});
    d = d(~ismember({d.name},{'.','..'}));
    for j = 1:length(d)
        fprintf('filename = %s\n',d(j).name);
        temp = load(fullfile(dataFolders{i},d(j).name));
        try
        corrs.corrThisSess100MS = temp.sess.getSpikeCorrelation(100);
        corrs.corrThisSess250MS = temp.sess.getSpikeCorrelation(250);
        corrs.corrThisSess1000MS = temp.sess.getSpikeCorrelation(1000);
        correlations{k+1} = corrs;
        k = k+1;
        catch ex
            failures(end+1) = d(j).name;
            failures(end).reason = ex;
            correlations{k+1} = [];
            k = k+1;
        end
    end
end

allCorrs100 = [];
allCorrs250 = [];
allCorrs1000 = [];
for i = 1:length(correlations)
    allCorrs100 = [allCorrs100; correlations{i}.corrThisSess100MS(:)];
    allCorrs250 = [allCorrs250; correlations{i}.corrThisSess250MS(:)];
    allCorrs1000 = [allCorrs1000; correlations{i}.corrThisSess1000MS(:)];
end

nanmean(allCorrs100),nanmean(allCorrs250),nanmean(allCorrs1000)
nanstd(allCorrs100),nanstd(allCorrs250),nanstd(allCorrs1000)



%% lagged corrs
dataFolders = {...
    %'C:\Users\Ghosh\Desktop\PhysData\070\070_InspectedSessions',...
    %'C:\Users\Ghosh\Desktop\PhysData\072\072_InspectedSessions',...
    %'C:\Users\Ghosh\Desktop\PhysData\074\074_InspectedSessions',...
    'C:\Users\Ghosh\Desktop\PhysData\284\284_InspectedPhys'};
saveLoc = 'C:\Users\Ghosh\Desktop\PhysAnalysis';
laggedCorrs = [];
h1 = waitbar(0,'Folder count');
for i = 1:length(dataFolders);
    h2 = waitbar(0,'Session Count');
    fprintf('i = %d\n',i);
    d = dir(dataFolders{i});
    d = d(~ismember({d.name},{'.','..'}));
    for j = 1:length(d)
        fprintf('filename = %s\n',d(j).name);
        temp = load(fullfile(dataFolders{i},d(j).name));
        corrs = temp.sess.calcXcorrs;
        save(fullfile(saveLoc,d(j).name),'corrs');
        waitbar(j/length(d),h2);
    end
    waitbar(i/length(dataFolders),h1);
end