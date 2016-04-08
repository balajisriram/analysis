function [ specialCase, sess ] = fixEventDataTrials( sess )
    maxTrial = getMaxTrial(sess);
    minTrial = getMinTrial(sess);

    numTrials = maxTrial-minTrial;

    trialNums = [];

    for i = 1:numTrials
        trialNums = [trialNums sess.eventData.messages(i).trial];
    end

    specialCase = [];

    for i = 1:2:numTrials-4
        currTrial = sess.eventData.messages(i).trial;
        nextTrial = sess.eventData.messages(i+2).trial;
        nextNextTrial = sess.eventData.messages(i+4).trial;

        if (nextTrial - currTrial) ~= 1
            if (nextNextTrial - currTrial) ~= 2
                specialCase = [specialCase i];
            else
                sess.eventData.messages(i+2).trial = currTrial+1;
            end
        end
    end
    sess.eventData.specialCases = specialCase;
end

