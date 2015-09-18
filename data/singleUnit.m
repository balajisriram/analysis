classdef singleUnit
    % singlueUnit class to store information neuron information. 
    
    properties
        groupID %which channels group picked up this neuron?
        unitID %unique ID for this neuron among groupID
        index
        timestamp %list of timestamps where this neuron fired
        waveform %list waveforms of spikes produced by neuron
        indexSampRate
    end
    
    methods
        function unit = singleUnit(group, id, idex, ts, wf, sampRate)
            unit.groupID = group;
            unit.unitID = id;
            unit.index = idex;
            unit.timestamp = ts;
            unit.waveform = wf;
            unit.indexSampRate = sampRate;
        end
        
        function avgFiringRate = getFiringRate(singleUnit) % # of spikes per second.
            avgFiringRate = length(singleUnit.timestamp)/max(singleUnit.timestamp);
        end
        
        function spikeWidth = getSpikeWidth(singleUnit) % how long spike is in ms
            avgWaveform = getAvgWaveform(singleUnit);
            bestChan = max(sum(abs(diff(avgWaveform))))==sum(abs(diff(avgWaveform)));
            bestAvgWaveform = avgWaveform(:,bestChan);
            spikeMin = min(bestAvgWaveform(10:30));
            spikeMax = max(bestAvgWaveform(10:30));
            if abs(spikeMin) >= abs(spikeMax) %downward spike
                peakInd = find(bestAvgWaveform(10:30)==min(bestAvgWaveform(10:30)))+9;
                accelAvg = diff(diff(bestAvgWaveform(1:peakInd)));
                i = find(accelAvg==min(accelAvg));
                spikeWidth = (peakInd - i)/30;
            else %upward spike
                peakInd = find(bestAvgWaveform(10:30)==max(bestAvgWaveform(10:30)))+9;
                accelAvg = diff(diff(bestAvgWaveform(1:peakInd)));
                i = find(accelAvg==max(accelAvg));
                spikeWidth = (peakInd - i)/30;
            end
            set(gca, 'ylim', [-700 700]);
            for j = 1:size(avgWaveform,2)
                subplot(1,size(avgWaveform,2),j);
                plot(avgWaveform(:,j));
                hold on;
                plot(peakInd, avgWaveform(peakInd,bestChan), '*');
                plot(i, avgWaveform(i,bestChan), '*')
            end
        end
        
        function [i,peakInd,bestChan] = getSingleUnitTestData(singleUnit)
            avgWaveform = getAvgWaveform(singleUnit);
            bestChan = max(sum(abs(diff(avgWaveform))))==sum(abs(diff(avgWaveform)));
            bestAvgWaveform = avgWaveform(:,bestChan);
            spikeMin = min(bestAvgWaveform(10:30));
            spikeMax = max(bestAvgWaveform(10:30));
            if abs(spikeMin) >= abs(spikeMax) %downward spike
                peakInd = find(bestAvgWaveform(10:30)==min(bestAvgWaveform(10:30)))+9;
                accelAvg = diff(diff(bestAvgWaveform(1:peakInd)));
                i = find(accelAvg==min(accelAvg));
            else %upward spike
                peakInd = find(bestAvgWaveform(10:30)==max(bestAvgWaveform(10:30)))+9;
                accelAvg = diff(diff(bestAvgWaveform(1:peakInd)));
                i = find(accelAvg==max(accelAvg));
            end
        end
        
        function [corr, lag] = crossCorr(singleUnit, correlatedUnit, maxLag, binSize)
            maxInd = max([singleUnit.index;correlatedUnit.index]);
            singUnit = zeros(1,maxInd);
            corrUnit = zeros(1,maxInd);
            for i = 1:length(singleUnit.index)
                singUnit(singleUnit.index(i)) = 1;
            end
            singUnit(singleUnit.index)=1;
            corrUnit(correlatedUnit.index)=1;
            singUnit = binRaster(singUnit, binSize);
            corrUnit = binRaster(corrUnit, binSize);
            [corr, lag] = xcorr(singUnit, corrUnit, maxLag);
        end
        
        function [corrList, lag] = crossCorrAll(singleUnit, sess, maxLag, binSize)
            corrList = zeros(sess.numberUnits(), maxLag*2+1);
            xVal = ceil(mod(sess.numberUnits(),8));
            yVal = 8; %seems 8 per row is most to still be clear
            counter = 1;
            
            for i = 1:length(sess.trodes)
                for j = 1:length(sess.trodes(i).units)
                    [corr, lag] = crossCorr(singleUnit, sess.trodes(i).units(j), maxLag, binSize);
                    
                    subplot(xVal, yVal, counter);
                    plot(lag,corr);
                    
                    corrList(counter,:) = corr;
                    
                    counter = counter + 1;
                end
            end
        end
        
        function [corrScalar, avgScalar] = SpikeTriggerdFiringRate(singleUnit, scalar, sampSize)
            highestInd = length(scalar);
            
            %finds which indices to block based on length of passed in
            %scalar
            blockedLower = (singleUnit.index-sampSize)<1;
            blockedUpper = (singleUnit.index+sampSize)>highestInd;
            allowedIndices = singleUnit.index;
            allowedIndices(blockedLower) = [];
            allowedIndices(blockedUpper) = [];
            
            %gets shape of scalar at all occurences of spike
            corrScalar = zeros(length(allowedIndices),sampSize*2);
            
            for i = 1:size(corrScalar,1)
                scInd = allowedIndices(i);
                corrScalar(i,:) = scalar((scInd-sampSize):(scInd+sampSize-1));
            end
            
            %gets avg of scalar at all occurences of spike
            avgScalar = zeros(1,sampSize*2);
            
            for i = 1:size(avgScalar,2)
                avgScalar(i) = mean(corrScalar(:,i)); 
            end
            
        end
        
        function avgWaveform = getAvgWaveform(singleUnit)
            avgWaveform = zeros(size(singleUnit.waveform,2),size(singleUnit.waveform,3));
            for i = 1:size(avgWaveform,1)
                for j = 1:size(avgWaveform,2)
                    avgWaveform(i,j) = mean(singleUnit.waveform(:,i,j));
                end
            end
        end
    end
    
end
