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
%                i = peakInd-2;
%                slopeAvg = diff(bestAvgWaveform(1:peakInd));
                accelAvg = diff(diff(bestAvgWaveform(1:peakInd)));
                i = find(accelAvg==min(accelAvg));
%                 while i > 0 && slopeAvg(i) < 0
%                     i = i - 1;
%                 end
%                 if i == 0
%                     i = 1;
%                 end
%                 while i < peakInd-2 && accelAvg(i) < 0
%                     i = i + 1;
%                 end
            else %upward spike
                peakInd = find(bestAvgWaveform(10:30)==max(bestAvgWaveform(10:30)))+9;
%                 i = peakInd-2;
%                 slopeAvg = diff(bestAvgWaveform(1:peakInd));
                accelAvg = diff(diff(bestAvgWaveform(1:peakInd)));
                i = find(accelAvg==max(accelAvg));
%                 while i > 0 && slopeAvg(i) > 0
%                     i = i - 1;
%                 end
%                 if i == 0
%                     i = 1;
%                 end
%                 while i < peakInd-2 && accelAvg(i) > 0
%                     i = i + 1;
%                 end
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
