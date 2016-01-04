function [ onset, offset, onsetInd, offsetInd, ledLength, ledHeight ] = LEDAnalysis(filePath)

    [ledMatrix, ~, ~] = load_open_ephys_data(filePath);
    
    meanVal = mean(ledMatrix);
    stdVal = std(ledMatrix);
    
    onset = diff([ledMatrix(1) ledMatrix']) > stdVal;
    offset = diff([ledMatrix(1) ledMatrix']) < -stdVal;
    
    blockedOn = diff([onset(1) onset]) == 0;
    blockedOff = diff([offset(1) offset]) == 0;
    
    onset(blockedOn) = 0;
    offset(blockedOff) = 0;
    
    onsetInd = find(onset);
    offsetInd = find(offset);
    
    for i = 1:max(length(onsetInd), length(offsetInd))
        ledLength(i) = offsetInd(i) - onsetInd(i);
        ledHeight(i) = mean(ledMatrix(onsetInd(i):offsetInd(i)))-meanVal;
    end
    
    

end

