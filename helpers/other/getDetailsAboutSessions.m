locStart = 'E:\workingSessionsnoWaveform';
d = dir(locStart);
d = d(~ismember({d.name},{'.','..'}));
SessionName = cell(size(d));
HasStimRecords = false(size(d));
HadErrorWithStimLoad = HasStimRecords;
NumUnits = nan(size(d));
DetailsAndEventDataAreCongruous = nan(size(d));
MinTrialNumber = nan(size(d));
MaxTrialNumber = nan(size(d));
for i = 1:length(d)
    load(fullfile(locStart,d(i).name));
    SessionName{i} = d(i).name;
    HasStimRecords(i) = ~isempty(sess.trialDetails);
    HadErrorWithStimLoad(i) = strcmp(sess.history{3}{2},'BAD_TIMESTAMPS');
    NumUnits(i) = sess.numUnits;
    MinTrialNumber(i) = sess.minTrialNum;
    MaxTrialNumber(i) = sess.maxTrialNum;
%     if HasStimRecords(i)
%         DetailsAndEventDataAreCongruous(i) = sess.DetailsAndEventDataAreCongruous();
%     end
    clear sess;    
end
Details = table(SessionName,HasStimRecords,HadErrorWithStimLoad,NumUnits,MinTrialNumber,MaxTrialNumber);