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
        
        function avgFiringRate = getFiringRate(u) % # of spikes per second.
            avgFiringRate = length(u.timestamp)/max(u.timestamp);
        end
        
        function spikeWidth = getSpikeWidth(u) % how long spike is in ms
            avgWaveform = getAvgWaveform(u);
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
        
        function [i,peakInd,bestChan] = getSingleUnitTestData(u)
            avgWaveform = getAvgWaveform(u);
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
        
        function [R, P] = calcCorr(u, u1, dt) % dt in ms
            maxInd = max([u.index;u1.index]);
            numSamps = dt*(u.indexSampRate/1000);
            edges = 1:numSamps:maxInd;
                       
            binned = histc(u.index,edges);
            binned1 = histc(u1.index,edges);
            
            scatter(binned,binned1,'jitter','on','jitterAmount',0.5);
            scatter(binned1,binned,'jitter','on','jitterAmount',0.5);
            
            [R,P] = corrcoef(binned,binned1);
        end
        
        function [corr, lag] = spikeCorr(u, u1, maxLag, binSize)
            maxInd = max([u.index;u1.index]);
            singUnit = zeros(1,maxInd);
            corrUnit = zeros(1,maxInd);
            for i = 1:length(u.index)
                singUnit(u.index(i)) = 1;
            end
            singUnit(u.index)=1;
            corrUnit(u1.index)=1;
            singUnit = binRaster(singUnit, binSize);
            corrUnit = binRaster(corrUnit, binSize);
            [corr, lag] = xcorr(singUnit, corrUnit, maxLag);
        end
        
        function [corrList, lag] = crossCorrAll(u, sess, maxLag, binSize)
            corrList = zeros(sess.numberUnits(), maxLag*2+1);
            xVal = ceil(mod(sess.numberUnits(),8));
            yVal = 8; %seems 8 per row is most to still be clear
            counter = 1;
            
            for i = 1:length(sess.trodes)
                for j = 1:length(sess.trodes(i).units)
                    [corr, lag] = crossCorr(u, sess.trodes(i).units(j), maxLag, binSize);
                    
                    subplot(xVal, yVal, counter);
                    plot(lag,corr);
                    
                    corrList(counter,:) = corr;
                    
                    counter = counter + 1;
                end
            end
        end
        
        function [corrScalar, avgScalar] = SpikeTriggerdFiringRate(u, scalar, sampSize)
            highestInd = length(scalar);
            
            %finds which indices to block based on length of passed in
            %scalar
            blockedLower = (u.index-sampSize)<1;
            blockedUpper = (u.index+sampSize)>highestInd;
            allowedIndices = u.index;
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
        
        function avgWaveform = getAvgWaveform(u)
            avgWaveform = zeros(size(u.waveform,2),size(u.waveform,3));
            for i = 1:size(avgWaveform,1)
                for j = 1:size(avgWaveform,2)
                    avgWaveform(i,j) = mean(u.waveform(:,i,j));
                end
            end
        end
    end
    
end
