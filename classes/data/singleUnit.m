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
        
        %% spikeWidth methods
        function out = spikeWidth(u)
            test = false;
            out = u.FWAtZero(test);
        end
        
        function width = getPeakToTrough(u) % how long spike is in ms
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
            width = (peakInd - i)/30;
        end
        
        function width = FWHM(u,test)
            if ~exist('test','var')
                test = false;
            end
            bestWaveform = u.getBestWaveForm;
            switch u.getSpikeDeflection
                case 'downward'
                    fn = @min;
                    parity = 1;
                case 'upward'
                    fn = @max;
                    parity = -1;
            end
            peakInd = find(bestWaveform(10:30)==fn(bestWaveform(10:30)))+9;
            peakVal = bestWaveform(peakInd);
            halfPeakVal = peakVal/2;
            
            % use splines to get better fits
            times = (1:length(bestWaveform))*1000/u.indexSampRate;
            splinedTimes = linspace(min(times),max(times),1000);
            splinedWF = spline(times,bestWaveform,splinedTimes);
            
            whichBelow = (parity*splinedWF)<(parity*halfPeakVal);
            diffWhichBelow = [0 diff(whichBelow)];
            % find largest sequence
            Increments = find(diffWhichBelow==1);
            Decrements = find(diffWhichBelow==-1);
            try
                tBelowStart = splinedTimes(Increments);
                tBelowStop = splinedTimes(Decrements);
                width = tBelowStop - tBelowStart;
            catch ex
                % if Increments and Decrements are of differentSizes???
                keyboard
            end
            
            if test
                figure;
                plot(splinedTimes,splinedWF,'k');hold on;
                plot(tBelowStart,halfPeakVal,'rx');
                plot(tBelowStop,halfPeakVal,'rx');
            end
        end
        
        function width = FWAtZero(u,test)
            if ~exist('test','var')
                test = false;
            end
            bestWaveform = u.getBestWaveForm;
            switch u.getSpikeDeflection
                case 'downward'
                    fn = @min;
                    parity = 1;
                case 'upward'
                    fn = @max;
                    parity = -1;
            end
            peakInd = find(bestWaveform(10:30)==fn(bestWaveform(10:30)))+9;
            peakVal = bestWaveform(peakInd);
            
            % use splines to get better fits
            times = (1:length(bestWaveform))*1000/u.indexSampRate;
            splinedTimes = linspace(min(times),max(times),1000);
            splinedWF = spline(times,bestWaveform,splinedTimes);
            absDiff = abs(splinedWF-peakVal);
            splinedPeakTime = splinedTimes(absDiff==min(absDiff));
            
            whichBelow = (parity*splinedWF)<0;
            diffWhichBelow = [0 diff(whichBelow)];

            try
                tBelowStart = splinedTimes(diffWhichBelow==1);
                tBelowStop = splinedTimes(diffWhichBelow==-1);
                
                tBelowStart = max(tBelowStart(tBelowStart<splinedPeakTime));
                tBelowStop = min(tBelowStop(tBelowStop>splinedPeakTime));
                width = tBelowStop - tBelowStart;
                
                if isempty(width)
                    width = nan;
                end
            catch ex
                % if Increments and Decrements are of differentSizes???
                figure;
                plot(splinedTimes,splinedWF,'k');hold on;
                plot(tBelowStart,0,'rx');
                plot(tBelowStop,0,'gx');
                keyboard
            end
            
            if test
                figure;
                plot(splinedTimes,splinedWF,'k');hold on;
                plot(tBelowStart,0,'rx');
                plot(tBelowStop,0,'rx');
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
            
            [R,P] = corrcoef(binned,binned1);
        end
        
        function [corr, shuffleM ,shuffleS, lag, sig] = xcorr(u, u1, maxLag, binSize)
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
            doShuffle = true;
            if doShuffle
                
                nShuffle = 10;
                corrShuffle = nan(nShuffle,length(corr));
                for i = 1:nShuffle
                    clear shufUnit shufOther
                    tic
                    try
                        shuffleOrder = randperm(length(singUnit));
                        shufUnit = singUnit(uint32(shuffleOrder));
                        shuffleOrder = randperm(length(corrUnit));
                        shufOther = corrUnit(uint32(shuffleOrder));
                    catch ex
                        beep
                        getReport(ex)
                        keyboard
                    end
                    corrShuffle(i,:) = xcorr(shufUnit,shufOther,maxLag);
                    %fprintf('xcorr %d of %d took %2.2f s\n',i,nShuffle,toc);
                end
                shuffleM = mean(corrShuffle,1);
                shuffleS = std(corrShuffle,[],1);
                
                if any(abs(corr)>abs(shuffleM+2*shuffleS))
                    sig = true;
                else
                    sig = false;
                end
            else
                shuffleM = [];
                shuffleS = [];
                sig = nan;
            end
        end
        
        function [corrList, lag] = spikeCorrAll(u, sess, maxLag, binSize)
            corrList = zeros(sess.numberUnits(), maxLag*2+1);
            counter = 1;
            
            for i = 1:length(sess.trodes)
                for j = 1:length(sess.trodes(i).units)
                    [corr, ~ ,~, lag] = xcorr(u, u1, maxLag, binSize);
                    
                    corrList(counter,:) = corr;
                    
                    counter = counter + 1;
                end
            end
        end
        
        function [STA, STD] = spikeTrigAverage(u, scalar, sampSize)
            % remove spikes that cannot provide complete signal in samples
            spikes = u.index;
            spikes(spikes<sampSize+1 | spikes> length(scalar)-sampSize) = [];
            
            sampIndex = repmat(spikes,1,2*sampSize+1)+repmat((-sampSize:sampSize),length(spikes),1);
            
            spikeTrigSamp = spikes(sampIndex);
            
            STA = mean(spikeTrigSamp,1);
            STD  = std(spikeTrigSamp,[],1);
            
        end
        
        function [mWave, stdWave] = getAvgWaveform(u)
            warning('this does not take into consideration how many channels we include in a trode');
            mWave = mean(u.waveform,1);
            stdWave = std(u.waveform,[],1);
        end
        
        function out = getReport(u)
            out.spikeWidth = u.spikeWidth;
            out.ISI = u.ISI;
            out.waveform = u.getAvgWaveform;
            out.firingRate = u.firingRate;
%             out.autocorr = u.xcorr(u,250,2);
        end
        
        function out = getRaster(u, times, window)
            if ~exist('window','var') || isempty(window)
                window = [-Inf,Inf];
            end
            out = cell(size(times));
            for i = 1:length(times)
                temp = u.timestamp-times(i);
                out{i} = temp(temp>window(1) & temp<window(2));
            end
        end
        
        function out = timeToFirstSpike(u,time)
            temp = u.timestamp-time;
            which = find(temp>0,1,'first');
            if isempty(which)
                out = NaN;
            else
                out = temp(which);
            end
        end
        
        function [m,s] = getFlatWaveForm(u)
            [m, s] = u.getAvgWaveform;
            % remove the extra dims first
            m = squeeze(m);
            s = squeeze(s);
            
            numSamps = size(m,1);
            numChans = size(m,2);
            
            m = reshape(m, numSamps*numChans,1);
            s = reshape(s ,numSamps*numChans,1);
        end
        
        %% plotting functions
        
        function plot(u,ax)
            if ~exist('ax','var') || isempty(ax)
                ax = axes;
            end
            
            %kT = ax.UserData.keyText;
            [m, s] = u.getFlatWaveForm;

            plot(ax,m,'k','Linewidth',3); hold on;
            plot(ax,m+s,'--k');
            plot(ax,m-s,'--k');
            %ax.UserData.keyText = [kT, sprintf('u%d',u.unitID)];
        end
    end
    
end
