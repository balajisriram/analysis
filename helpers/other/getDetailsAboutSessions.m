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
HasComplexTrialNumbers = nan(size(d));
HasEventData = nan(size(d));
TrialNumbersAreInOrder = nan(size(d));
Reason = cell(size(d));
EventTrialNumbersInSequence = nan(size(d));

for i = 1:length(d)
    disp(i)
    load(fullfile(locStart,d(i).name));
    SessionName{i} = d(i).name;
    HasStimRecords(i) = ~isempty(sess.trialDetails);
    HadErrorWithStimLoad(i) = strcmp(sess.history{3}{2},'BAD_TIMESTAMPS');
    NumUnits(i) = sess.numUnits;
    MinTrialNumber(i) = sess.minTrialNum;
    MaxTrialNumber(i) = sess.maxTrialNum;
    
    HasEventData(i) = sess.containsEventData();
    
    if HasEventData(i)
        HasComplexTrialNumbers(i) = ~all(isreal([sess.eventData.stim.trialNumber]));
        if HasComplexTrialNumbers(i)
            sess = sess.fixComplexTrialNumbers();
            save(fullfile(locStart,d(i).name),'sess');
        end
        EventTrialNumbersInSequence(i) = sess.eventTrialNumbersAreInSequence();
        if ~EventTrialNumbersInSequence(i)
            sess = sess.fixNonSequentialTrialNumbers();
            save(fullfile(locStart,d(i).name),'sess');
        end
    end
%     [TrialNumbersAreInOrder(i), Reason{i}] = sess.trialNumbersAreInOrder;
%     EventTrialNumbersInSequence(i) = sess.eventTrialNumbersAreInSequence();
%     if ~TrialNumbersAreInOrder(i)
%         sess = sess.fixTrialNumbers();
%         save(fullfile(locStart,d(i).name),'sess');
%     end
    clear sess;    
end
Details = table(SessionName,HasStimRecords,HadErrorWithStimLoad,NumUnits,MinTrialNumber,MaxTrialNumber,HasEventData,HasComplexTrialNumbers,EventTrialNumbersInSequence)