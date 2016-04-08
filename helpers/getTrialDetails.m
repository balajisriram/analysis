function [ sess ] = getTrialDetails( sess, stimRecordsFolder )
% getTrialDetails - Gets more in depth trial information stored in the
%                   stim records folder in all data folders.
%                   Stored in sess.eventData.
%
% parameters - sess: session to be added to
%            - stimRecordedFolder: folder where stim data is held.
%
% return - sess: session should now contain correct stim data. 

fPath = [stimRecordsFolder,'\stim*'];
files = dir(fPath);
for i = 1:length(files)
    load([stimRecordsFolder,'\',files(i).name]);
    sess.eventData.trialData(trialNum).trialNum = trialNum;
    sess.eventData.trialData(trialNum).refreshRate = refreshRate;
    sess.eventData.trialData(trialNum).stepName = stepName;
    sess.eventData.trialData(trialNum).stimManagerClass = stimManagerClass;
    sess.eventData.trialData(trialNum).stimulusDetails = stimulusDetails;
end


end

