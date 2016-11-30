% Establish the relationship between Stim and Frames (this is to fill in
% the details for latter sessions when the data isnt available any longer

clear all;
loc = 'F:\workingSessionsnoWaveform';
d = dir(fullfile(loc,'*.mat'));

ORTUNINGS = {};
ORVECTORS = {};
OSIS = {};

for j = 1:length(d)
    disp(j)
    clear sess
    load(fullfile(loc,d(j).name));
    disp(d(j).name)
    try
        orTuning = sess.getAllORTuning;
    catch ex
        getReport(ex);
        orTuning = [];
    end
    ORTUNINGS{end+1} = orTuning;
    
    try
        orVector = sess.getAllOrVectors;
    catch ex
        getReport(ex);
        orVector = [];
    end
    ORVECTORS{end+1} = orVector;
    
    try
        OSI = sess.getAllOSI;
    catch ex
        getReport(ex);
        OSI = [];
    end
    OSIS{end+1} = OSI;
    
end

%% 

f = figure;
ax = axes;
OSIs = [];
for j = 1:length(OSIS)
    if ~isempty(OSIS{j})
    OSIs = [OSIs OSIS{j}.OSI];
    end
end

OSIs = OSIs(OSIs>0 & OSIs<1);
hist(OSIs,100);

