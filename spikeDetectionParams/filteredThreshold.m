classdef filteredThreshold < spikeDetectionParam
    
    properties
        freqLowHi = [200 10000]
        minmaxVolts
        thresholdVolts
        thresholdVoltsSTD
        waveformWindowMs = 1.5
        peakWindowMs = 0.6
        alignMethod = 'atPeak'
        peakAlignment = 'filtered'
        returnedSpikes = 'filtered'
        lockoutDurMs = 1
        thresholdMethod = 'std'
        ISIviolationMS = 1
        method = 'filteredThresh'
        samplingFreq = 30000;
    end
    
    methods 
        function out = filteredThreshold(varargin) 
            % filteredthreshold(obj)
            % filteredThreshold('paramName',thrV)
            
            if ischar(varargin{1})
                paramName = varargin{1};
            else
                paramName = 'standard';
            end
            out = out@spikeDetectionParam(paramName);
            
            switch nargin
                case 1
                    if isa(varargin{1},'filteredThreshold')
                        out = varargin{1};
                    end
                case 2
                    out.thresholdVolts = varargin{2};
                case 3
                    out.thresholdMethod = varargin{3};
                    switch upper(out.thresholdMethod)
                        case 'STD'
                            out.thresholdVoltsSTD = varargin{2};
                        case 'RAW'
                            out.thresholdVolts = varargin{2};
                    end
            end
        end
        
        function par = setupAndValidateParams(par,varargin)
            switch upper(par.thresholdMethod)
                case 'RAW'
                    disp('doing nothing')
                case 'STD'
                    if nargin==2
                        % wrong
                        means = varargin{1}(1,:);
                        stds =  varargin{1}(2,:);
                        thrV = par.thresholdVolts;
                        
                        par.thresholdVolts = [means-thrV.*stds;means+thrV.*stds];
                    end
                    
            end
        end
        
        function [loThresh, hiThresh, par] = getThresholds(par,filteredSignal)
            switch upper(par.thresholdMethod)
                case 'STD'
                    mFilt = mean(filteredSignal);
                    sFilt = std(filteredSignal);
                    
                    loThresh = mFilt-sFilt.*par.thresholdVoltsSTD;
                    hiThresh = mFilt+sFilt.*par.thresholdVoltsSTD;
                    
                    par.thresholdVolts = [loThresh; hiThresh];
                case 'RAW'
                    loThresh = par.thresholdVolts(1,:);
                    hiThresh = par.thresholdVolts(2,:);
                    
                    % calculate and populate STD data
                    stdFilt = std(filteredSignal);
                    
                    par.thresholdVoltsSTD = (hiThresh-loThresh)./stdFilt;
                    
            end
            
        end
        
        function [spikes, spikeWaveforms, spikeTimestamps, par] = detectSpikesFromNeuralData(par, neuralData, neuralDataTimes)
            
            N=round(min(par.samplingFreq/200,floor(size(neuralData,1)/3)));
            [b,a]=fir1(N,2*par.freqLowHi/par.samplingFreq);
            if 3*max(length(b),length(a))>size(neuralData,1)
                warning('neuralData is not long enough to filter. going to return empty stuff');
                spikes = [];
                spikeWaveforms = [];
                spikeTimestamps = [];
                return;
            end
            
            
            filteredSignal=filtfilt(b,a,neuralData);
            
            
            [loThresh,hiThresh,par] = getThresholds(par,filteredSignal);
            
            
            spkBeforeAfterMS=[par.peakWindowMs par.waveformWindowMs-par.peakWindowMs];
            spkSampsBeforeAfter=round(par.samplingFreq*spkBeforeAfterMS/1000);
            
            % find spike events
            tops = [];
            bottoms = [];
            topAmountAllChan = [];
            botAmountAllChan = [];
            for i = 1:size(neuralData,2)
                top = find([false; diff(filteredSignal(:,i)>hiThresh(i))>0]);
                bottom = find([false; diff(filteredSignal(:,i)<loThresh(i))>0]);
                topAmountAllChan = [topAmountAllChan makerow(i*ones(size(top)))];
                botAmountAllChan = [botAmountAllChan makerow(i*ones(size(bottom)))];   % ## makes matrix that keeps track of how many times threshold
                tops = [tops;top];                                      %    is crossed per channel.
                bottoms = [bottoms;bottom];
            end
            
            
            try
                [tops,    topTimes]   =filteredThreshold.extractPeakAligned(tops,1,par.samplingFreq,spkSampsBeforeAfter,filteredSignal,neuralData, topAmountAllChan);
                [bottoms, bottomTimes]=filteredThreshold.extractPeakAligned(bottoms,-1,par.samplingFreq,spkSampsBeforeAfter,filteredSignal,neuralData, botAmountAllChan);
            catch ex
                %keyboard
            end
            
            %maybe sort the order...
            spikes=[topTimes;bottomTimes];
            spikeWaveforms=[tops;bottoms];
            [spikes, sortInds]=sort(spikes);
            spikeWaveforms=spikeWaveforms(sortInds,:,:);
            
%             voltageTooExtreme= any(spikeWaveforms(:,:,1)'<par.minmaxVolts(1)) | any(spikeWaveforms(:,:,1)'>par.minmaxVolts(2));
%             spikes(voltageTooExtreme)=[];                     % ## NOTE: only checks first channel for voltageTooExtreme for now because it never happened in any test
%             spikeWaveforms(voltageTooExtreme,:)=[];           %          sets before.
            
            spikeTimestamps=neuralDataTimes(spikes, 1);
            
            % organize the spikes in order of time.
            [spikeTimestamps, reorderedInds]=sort(spikeTimestamps);  % also get the reorderedInds from this
            spikeWaveforms=spikeWaveforms(reorderedInds,:,:);
            spikes = spikes(reorderedInds);

            % support for lockout
            if par.lockoutDurMs>0  % ## NOTE: changing order of channels sometimes can slightly change # of spikes blocked
                blocked=find(diff([0; spikeTimestamps])<par.lockoutDurMs/1000);
                spikes(blocked) = [];
                spikeTimestamps(blocked)=[];
                spikeWaveforms(blocked,:,:)=[]; % check dimensions
            end
            
            if length(spikes)~=length(unique(spikes))
                warning('duplicate spikes detected');
            end
            
            
        end
    end
    
    methods (Static=true)
        function [group groupPts]=extractPeakAligned(group,flip,sampRate,spkSampsBeforeAfter,filt,data, fromChannel)
            maxMSforPeakAfterThreshCrossing=1; %this is equivalent to a lockout, because all peaks closer than this will be called one peak, so you'd miss IFI's smaller than this.
            % we should check for this by checking if we said there were multiple spikes at the same time.
            % but note this is ONLY a consequence of peak alignment!  if aligned on thresh crossings, no lockout necessary (tho high frequency noise riding on the spike can cause it
            % to cross threshold multiple times, causing you to count it multiple times w/timeshift).
            % our remaining problem is if the decaying portion of the spike has high freq noise that causes it to recross thresh and get counted again, so need to look in past to see
            % if we are on the tail of a previous spk -- but this should get clustered away anyway because there's no spike-like peak in the immediate period following the crossing.
            % ie the peak is in the past, so it's a different shape, therefore a different cluster
            
            maxPeakSamps=round(sampRate*maxMSforPeakAfterThreshCrossing/1000);
            
            spkLength=sum(spkSampsBeforeAfter)+1;
            spkPts=[-spkSampsBeforeAfter(1):spkSampsBeforeAfter(2)];
            %spkPts=(1:spkLength)-ceil(spkLength/2); % centered
            
            % make sure that we can always find all the data for spike
            % before extracting it for analysis. spike from the beginning
            % and end are removed
            whichDeleted = (group+spkLength-1)<length(filt) & group-ceil(spkLength/2)>0;
            groupPts=group(whichDeleted);             
            fromChannel(~whichDeleted) = [];
            
            % this is ugly. but works. computationally identical.
            if length(groupPts) ==1
                warning('may not work');
                %keyboard
                group = data(repmat(groupPts,1,maxPeakSamps)+repmat(0:maxPeakSamps-1,length(groupPts),1));
                group = group';
                [junk loc]=max(flip*group,[],2);
                groupPts=((loc-1)+groupPts);
                groupPts=groupPts((groupPts+floor(spkLength/2))<length(filt));
                group= filt(repmat(groupPts,1,spkLength)+repmat(spkPts,length(groupPts),1));group = group';
                uGroup=data(repmat(groupPts,1,spkLength)+repmat(spkPts,length(groupPts),1));uGroup = uGroup';
                uGroup=uGroup-repmat(mean(uGroup,2),1,spkLength);
            elseif length(groupPts) ==0
                group =[];
                uGroup =[];
                groupPts=[];
            else

%                 group=data(repmat(groupPts,1,maxPeakSamps)+repmat(0:maxPeakSamps-1,length(groupPts),1)); %use (sharper) unfiltered peaks!
%                 [junk loc]=max(flip*group,[],2);
%                 groupPts=((loc-1)+groupPts);
%                 groupPts=groupPts((groupPts+floor(spkLength/2))<length(filt));
%                 group= filt(repmat(groupPts,1,spkLength)+repmat(spkPts,length(groupPts),1));
%                 uGroup=data(repmat(groupPts,1,spkLength)+repmat(spkPts,length(groupPts),1));
%                 uGroup=uGroup-repmat(mean(uGroup,2),1,spkLength);

                
                
                % this code does not guarantee against multiple threshold crossings
                % within the same region of interest. specify a
                % par.lockoutDurMS to later filter them out!
                group = [];
                start = 1;
                for i =  1:size(filt,2)   % ## goes through and builds group by iterating through channel data 1 at a time.
                    dat = filt(:,i);
                    g=dat(repmat(groupPts(fromChannel==i),1,maxPeakSamps)+repmat(0:maxPeakSamps-1,length(groupPts(fromChannel==i)),1)); %use (sharper) unfiltered peaks!
                    % finish = (start+fromChannel(i)) - 1;
                    [~, loc]=max(flip*g,[],2); % gets max point in size 15 sample
                    groupPts(fromChannel==i)=((loc-1)+groupPts(fromChannel==i));     % set group points to new peaks found
                    groupPts=groupPts((groupPts+floor(spkLength/2))<length(filt));
                    % start = finish;
                end
                
                %group = nan(numEvents,numSamps,numChans);
                group = nan(length(groupPts),spkLength,size(data,2));
                for i = 1:size(data,2)
                    %error('not sure this works');
                    f = filt(:,i);
                    group(:,:,i) = f(repmat(groupPts,1,spkLength)+repmat(spkPts,length(groupPts),1));
                end
                
%                 for i =  1:size(data,2)     % ## after groupPts is centered on peak for specific channel spike was found cycle through
%                     fil = filt(:,i);        %    all channels again and extract data surrounding peak.
%                     g= fil(repmat(groupPts,1,spkLength)+repmat(spkPts,length(groupPts),1)); % replaces group with new full filtered data (group is what turns into "spikes" must focus on these).
%                     group = cat(3,group,g);
%                     uGroup=data(repmat(groupPts,1,spkLength)+repmat(spkPts,length(groupPts),1)); %ugroup does same but for unfiltered data
%                     uGroup=uGroup-repmat(mean(uGroup,2),1,spkLength);
%                 end
            end
            % just gonna try with the filtered spikes
            % group=filt(repmat(groupPts,1,maxPeakSamps)+repmat(0:maxPeakSamps-1,length(groupPts),1)); %use (sharper) unfiltered peaks!
            
        end
    end
    
end

