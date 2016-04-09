function [ onset, offset, onsetInd, offsetInd, mLength ] = monitorAnalysis(filePath, ttlEventData)

    [monData, ~, ~] = load_open_ephys_data(filePath);
    
    d1 = designfilt('lowpassiir','FilterOrder',12, 'HalfPowerFrequency',0.01,'DesignMethod','butter');
    filtMonData = filtfilt(d1,monData);
    
    %meanVal = mean(monMatrix);
    %stdVal = std(monMatrix);
    
    onset = diff([filtMonData(1) filtMonData']) > 1*10^-3;
    offset = diff([filtMonData(1) filtMonData']) < -1*10^-3;
    
    blockedOn = diff([onset(1) onset]) == 0;
    blockedOff = diff([offset(1) offset]) == 0;
    
    onset(blockedOn) = 0;
    offset(blockedOff) = 0;
    
    onsetInd = find(onset);
    offsetInd = find(offset);
    
    for i = 1:max(length(onsetInd), length(offsetInd))
        mLength(i) = offsetInd(i) - onsetInd(i);
        %mHeight(i) = mean(monMatrix(onsetInd(i):offsetInd(i)))-meanVal;
    end
    
    %using stim
    ttlOnset = ttlEventData.eventTimes(ttlEventData.eventID==0)*30000;
    ttlOffset = ttlEventData.eventTimes(ttlEventData.eventID==0)*30000;
    
    %only need this if using frame
    diffOnset = diff([ttlOnset(1) ttlOnset']);
    firstFrameTrial = diffOnset>1000;
    blockedTrial = diff([firstFrameTrial(1) firstFrameTrial]) == 0;
    firstFrameTrial(blockedTrial) = 0;
    firstFrameTrial(1) = 1;
    ttlOnset = ttlEventData.eventTimes(firstFrameTrial)*30000;
    
    index = 1;
    for i = 1:2:length(ttlEventData.eventTimes)
        ttlLength(index) = (ttlEventData.eventTimes(i+1)-ttlEventData.eventTimes(i))*30000;
        index = index + 1;
    end

    meanLen = mean(ttlLength);
    timeBefore = 0.5;
    timeAfter = 0.25;
    samplingRate = 30000;
    sampSize = floor(meanLen)+samplingRate*timeBefore+samplingRate*timeAfter; %3000 == 100ms, 7500 == 250ms
    
    lightLevels = nan(length(ttlOffset),sampSize+1);
    
    debug = true;
    if debug
        figure;
        for i = 1:100
%             subplot(6,6,i);
            startInd = ttlOffset(i)-samplingRate*timeBefore;
            endInd = startInd+sampSize;
            plot((-samplingRate*timeBefore:(-samplingRate*timeBefore+sampSize))/samplingRate,filtMonData(startInd:endInd)); hold on;
        end
        
    end
    for i = 1:length(ttlOnset)
        startInd = ttlOnset(i)-3000;
        endInd = startInd+sampSize;
        if endInd<length(filtMonData)
            lightLevels(i,:) = filtMonData(startInd:endInd);
        end
    end
    keyboard
end

