% Re make session by adding details to session instead of in eventData

locStart = 'E:\workingSessionsnoWaveform';
d = dir(locStart);
d = d(~ismember({d.name},{'.','..'}));

SessionName = cell(size(d));
HasStimRecords = false(size(d));

for i = 1:length(d)
    disp(i)
    SessionName{i} = d(i).name;
    load(fullfile(locStart,d(i).name));
    HasStimRecords(i) = ~isempty(sess.trialDetails);
    sess.samplingFreq = sess.trodes(1).detectParams.samplingFreq;
    
%     if ~HasStimRecords(i)
%         
%     else
%         sess = sess.MakeNewStypeTrialDetails();
%         
%     end
end
Details = table(SessionName,HasStimRecords)