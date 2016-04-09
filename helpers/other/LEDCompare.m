function [ flashLength, onsetInd, ttlEventData ] = LEDCompare( flashLength, onsetInd, ttlEventData )

    keyboard
    
    ttlOnset = ttlEventData.eventTimes(ttlEventData.eventID==1)*30000;
    
    index = 1;
    for i = 1:2:length(ttlEventData.eventTimes)
        ttlLength(index) = (ttlEventData.eventTimes(i+1)-ttlEventData.eventTimes(i))*30000;
        index = index + 1;
    end
        
    
    plot(ttlLength-flashLength);
    plot(ttlOnset-onsetInd');
    plot(ttlOnset-7017600-onsetInd);
    

    ttlLength = ttlLength/30;
    flashLength = flashLength/30;
    ttlOnset = (ttlOnset-7017600)/30;
    onsetInd = onsetInd'/30;
    
    % Scatter
    sc1 = scatter(ttlLength, flashLength, 50, 'filled','o'); hold on;
    plot(75:275, 75:275);
    xlabel('TTL duration (ms)');
    ylabel('Light duration (ms)');
    set(sc1,'MarkerFaceColor','k')
    axis square
    
    % Jitter
    hist(onsetInd-ttlOnset);
    xlabel('Jitter (ms)');
    ylabel('Number of trials');
    
    
    
    
end

