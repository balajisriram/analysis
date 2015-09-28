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
        
        function avgFiringRate = firingRate(u) % # of spikes per second.
            avgFiringRate = length(u.timestamp)/max(u.timestamp);
        end
        
        function out = spikeWidth(u)
            out = u.getPeakToTrough;
        end
        
        function out = ISI(u)
            out = diff(u.timestamp);
        end
        
        function numChans = numChans(u)
            if length(size(u.waveform))==2
                numChans = 1;
            else
                numChans = size(u.waveform,3);
            end
        end
        
        function bestChan = getBestChan(u)
            numChans = u.numChans;
            if numChans ==1
                bestChan = 1;
                return
            end
            
            method = 'maxSTD'; % 'maxSlope', 'maxSTD'
            switch method
                case 'maxAmplitude'
                    error('not yet');
                case 'maxSlope'
                    bestChan = squeeze(max(sum(abs(diff(u.getAvgWaveform))))==sum(abs(diff(u.getAvgWaveform))));
                case 'maxSTD'
                    bestChan = squeeze(std(u.getAvgWaveform,[],2)==max(std(u.getAvgWaveform,[],2)));
            end
        end
        
        function bestWaveForm = getBestWaveForm(u)
            avgWaveForm = u.getAvgWaveform;
            bestWaveForm = squeeze(avgWaveForm(:,:,u.getBestChan));
        end
        
        function out = getSpikeDeflection(u)
            bestWaveForm = u.getBestWaveForm;
            spikeMin = min(bestWaveForm(10:30));
            spikeMax = max(bestWaveForm(10:30));
            if abs(spikeMin) >= abs(spikeMax)
                out = 'downward';
            else
                out = 'upward';
            end
        end
        
        function spikeWidth = getPeakToTrough(u) % how long spike is in ms
            bestWaveform = u.getBestWaveForm;
            switch u.getSpikeDeflection
                case 'downward'
                    fn = @min;
                case 'upward'
                    fn = @max;
            end
            peakInd = find(bestWaveform(10:30)==fn(bestWaveform(10:30)))+9;
            accelAvg = diff(diff(bestWaveform(1:peakInd)));
            i = find(accelAvg==fn(accelAvg));
            spikeWidth = (peakInd - i)/30;
        end
        
        function width = FWHM(u)
            width = 0;
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
            
            [R,P] = corrcoef(binned,binned1);
        end
        
        function [corr, shuffleM ,shuffleS, lag] = xcorr(u, u1, maxLag, binSize)
            if ~exist('maxLag','var') || isempty(maxLag)
                maxLag = 250; %in ms
            end
            
            if ~exist('binSize','var') || isempty(binSize)
                binSize = 1; %in ms
            end
            
            maxInd = max([u.index;u1.index]);
            singUnit = zeros(1,maxInd);
            corrUnit = zeros(1,maxInd);

            singUnit(u.index)=1;
            corrUnit(u1.index)=1;
            
            singUnit = binRaster(singUnit, binSize);
            corrUnit = binRaster(corrUnit, binSize);
            
            [corr, lag] = xcorr(singUnit, corrUnit, maxLag);
            
            nShuffle = 10;
            corrShuffle = nan(nShuffle,length(corr));
            for i = 1:nShuffle
                tic
                shufUnit = singUnit(randperm(length(singUnit)));
                shufOther = corrUnit(randperm(length(corrUnit)));
                corrShuffle(i,:) = xcorr(shufUnit,shufOther,maxLag);
                fprintf('xcorr %d of %d took %2.2f s\n',i,nShuffle,toc);
            end
            shuffleM = mean(corrShuffle,1);
            shuffleS = std(corrShuffle,[],1);
        end
        
        function [corrList, lag] = crossCorrAll(u, sess, maxLag, binSize)
            corrList = zeros(sess.numberUnits(), maxLag*2+1);
            counter = 1;
            
            for i = 1:length(sess.trodes)
                for j = 1:length(sess.trodes(i).units)
                    [corr, lag] = crossCorr(u, sess.trodes(i).units(j), maxLag, binSize);
                    
                    corrList(counter,:) = corr;
                    
                    counter = counter + 1;
                end
            end
        end
        
        function [STA STD] = spikeTrigAverage(u, scalar, sampSize)
            % remove spikes that cannot provide complete signal in samples
            spikes = u.index;
            spikes(spikes<sampSize+1 | spikes> length(scalar)-sampSize) = [];
            
            sampIndex = repmat(spikes,1,2*sampSize+1)+repmat((-sampSize:sampSize),length(spikes),1);
            
            spikeTrigSamp = spikes(sampIndex);
            
            STA = mean(spikeTrigSamp,1);
            STD  = std(spikeTrigSamp,[],1);
            
        end
        
        function [mWave, stdWave] = getAvgWaveform(u)
            mWave = mean(u.waveform,1);
            stdWave = std(u.waveform,[],1);
        end
        
        function out = getReport(u)
            out.spikeWidth = u.spikeWidth();
            out.ISI = u.ISI();
            out.waveform = u.getAvgWaveform();
            out.autocorr = u.xcorr(u,250,1);
            
        end
    end
    
end
