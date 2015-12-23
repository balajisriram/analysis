function [spikes spikeWaveforms spikeTimestamps]= detectSpikesFromNeuralData(neuralData,...
    neuralDataTimes,spikeDetectionParams)
% Get spikes using some spike detection method - plugin to Osort, WaveClus, KlustaKwik
% Outputs:
%   spikes - a vector of indices into neuralData that indicate where a spike happened
%   spikeWaveforms - a matrix containing a 4x32 waveform for each spike
%   spikeTimestamps - timestamp of each spike


spikes=[];


% default inputs for all methods

if ~isfield(spikeDetectionParams, 'ISIviolationMS')
    spikeDetectionParams.ISIviolationMS=2; % used for plots and reports of violations
end
% =====================================================================================================================
% SPIKE DETECTION

% handle spike detection
% the spikeDetectionParams struct must contain a 'method' field
if isfield(spikeDetectionParams, 'method')
    spikeDetectionMethod = spikeDetectionParams.method;
else
    error('must specify a method for spike detection');
end

% switch on the detection method
switch upper(spikeDetectionMethod)
    case 'OSORT'
        % spikeDetectionParams should look like this:
        %   method - osort
        %   samplingFreq - sampling frequency of raw signal
        %   Hd - (optional) bandpass frequencies
        %   nrNoiseTraces - (optional) number of noise traces as a parameter to osort's extractSpikes
        %   detectionMethod - (optional) spike detection method to use as a parameter to osort's extractSpikes
        %   extractionThreshold - (optional) threshold for extraction as a parameter to osort's extractSpikes
        %   peakAlignMethod - (optional) peak alignment method to use as a parameter to osort's extractSpikes
        %   alignMethod - (optional) align method to use if we are using "find peak" peakAlignMethod
        %   prewhiten - (optional) whether or not to prewhiten
        %   limit - (optional) the maximal absolute valid value (bigger/smaller than this is treated as out of range)
        
        % ============================================================================================================
        % from Osort's extractSpikes
        %extractionThreshold default is 5
        %params.nrNoiseTraces: 0 if no noise should be estimated
        %               >0 : # of noise traces to be used to estimate autocorr of
        %               noise, returned in variable autocorr
        %
        %
        %params.detectionMethod: 1 -> from power signal, 2 threshold positive, 3 threshold negative, 4 threshold abs, 5 wavelet
        %params.detectionParams: depends on detectionMethod.
        %       if detectionmethod==1, detectionParams.kernelSize
        %       if detectionmethod==4, detectionParams.scaleRanges (the range of scales (2 values))
        %                              detectionParams.waveletName (which wavelet to use)
        %
        %params.peakAlignMethod: 1-> find peak, 2->none, 3->peak of power signal, 4->peak of MTEO signal.
        %params.alignMethod: 1=pos, 2=neg, 3=mix (order if both peaks are sig,otherwise max) - only used if peakAlignMethod==1
        % ============================================================================================================
        
        % check params
        if ~isfield(spikeDetectionParams, 'samplingFreq')
            error('samplingFreq must be defined');
        end
        if isfield(spikeDetectionParams, 'Hd')
            Hd = spikeDetectionParams.Hd;
        else
            % default to bandpass 300Hz - 3000Hz
            n = 4;
            Wn = [300 3000]/(spikeDetectionParams.samplingFreq/2);
            [b,a] = butter(n,Wn);
            Hd=[];
            Hd{1}=b;
            Hd{2}=a;
        end
        if ~isfield(spikeDetectionParams, 'nrNoiseTraces')
            warning('nrNoiseTraces not defined - using default value of 0');
        end
        if ~isfield(spikeDetectionParams, 'detectionMethod')
            spikeDetectionParams.detectionMethod=1;
            spikeDetectionParams.kernelSize=25;
            warning('detectionMethod not defined - using default value of 1; also overwriting kernelSize param if set');
        end
        if ~isfield(spikeDetectionParams, 'extractionThreshold')
            spikeDetectionParams.extractionThreshold = 5;
            warning('extractionThreshold not defined - using default value of 5');
        end
        if ~isfield(spikeDetectionParams, 'peakAlignMethod')
            spikeDetectionParams.peakAlignMethod=1;
            warning('peakAlignMethod not defined - using default value of 1');
        end
        if ~isfield(spikeDetectionParams, 'prewhiten')
            spikeDetectionParams.prewhiten = false;
            warning('prewhiten not defined - using default value of false');
        end
        if isfield(spikeDetectionParams, 'limit')
            error('not longer using the param ''limit''; instead use minmaxVolts')
            % this is for consistency between our different methods
            %warning('limit not defined - using default value of 2000');
            %limit was soupposed to work on the raw voltages, but we
            %opperate on the filtered volatages
        else
            %CONSIDERED DOING THIS, but its unnecc, cuz minmaxVolts is
            %supported as is, and limit behaves differently
            %             if length(unique(abs(spikeDetectionParams.minmaxVolts)))~=1
            %                 minmaxVolts=spikeDetectionParams.minmaxVolts
            %                 error('osort only handles +/- a single threshold, not unique ones')
            %             else
            %                 %set the limit based on minmaxVolts
            %                 spikeDetectionParams.limit=unique(abs(spikeDetectionParams.minmaxVolts));
            %             end
            spikeDetectionParams.limit=Inf;
        end
        if ~isfield(spikeDetectionParams, 'minmaxVolts')
            spikeDetectionParams.minmaxVolts = [-Inf Inf];
            warning('minmaxVolts not defined - using default value of [-Inf Inf], which does not remove any high amplitude noise ever');
        end
              
        % check that correct params exist for given detectionMethods
        if spikeDetectionParams.detectionMethod==1
            if ~isfield(spikeDetectionParams, 'kernelSize')
                warning('kernelSize not defined - using default value of 25');
            end
        elseif spikeDetectionParams.detectionMethod==5
            if ~isfield(spikeDetectionParams, 'scaleRanges')
                warning('scaleRanges not defined - using default value of [0.5 1.0]');
                spikeDetectionParams.scaleRanges = [0.5 1.0];
            end
            if ~isfield(spikeDetectionParams, 'waveletName')
                warning('waveletName not defined - using default value of ''haar''');
                spikeDetectionParams.waveletName = 'haar';
            end
        end
        
        if spikeDetectionParams.peakAlignMethod==1
            if ~isfield(spikeDetectionParams, 'alignMethod')
                warning('alignMethod not defined - using default value of 1');
                spikeDetectionParams.alignMethod = 1;
            end
        end
        
        if spikeDetectionParams.peakAlignMethod==1
            if ~isfield(spikeDetectionParams, 'alignMethod')
                warning('alignMethod not defined - using default value of 1');
                spikeDetectionParams.alignMethod = 1;
            end
        end

                
        channelIDUsedForDetection=1;  % the first by default... never used anything besides this so far
        
        % call to Osort spike detection
        [rawMean, filteredSignal, rawTraceSpikes,spikeWaveforms, spikeTimestampIndices, runStd2, upperlim, noiseTraces] = ...
            extractSpikes(neuralData, Hd, spikeDetectionParams );  
        
        spikes=spikeTimestampIndices';
            
    case {'FILTEREDTHRESH','FILTEREDTHRESHSTD'}
        %         spikeDetectionParams.method = 'filteredThresh'
        %         spikeDetectionParams.freqLowHi = [200 10000];
        %         spikeDetectionParams.thresholdVolts = [-1.2 Inf];
        %         spikeDetectionParams.waveformWindowMs= 1.5;
        %         spikeDetectionParams.peakWindowMs= 0.5;
        %         spikeDetectionParams.alignMethod = 'atPeak'; %atCrossing
        %         spikeDetectionParams.peakAlignment = 'filtered' % 'raw'
        %         spikeDetectionParams.returnedSpikes = 'filtered' % 'raw'
        %         spikeDetectionParams.spkBeforeAfterMS=[0.6 0.975];
        %         spikeDetectionParams.bottomTopCrossingRate=[];
        
        %   NOT USED
        %         spikeDetectionParams.maxDbUnmasked = [-1.2 Inf];  % this  is not used
        
        if ~isfield(spikeDetectionParams, 'samplingFreq')
            error('samplingFreq must be a field in spikeDetectionParams');
        end
        if ~isfield(spikeDetectionParams, 'freqLowHi')
            spikeDetectionParams.freqLowHi=[200 10000];
            warning('freqLowHi not defined - using default value of [200 10000]');
        end
        if ~isfield(spikeDetectionParams, 'threshHoldVolts') && ~strcmp(spikeDetectionParams.thresholdMethod,'STD')
            if ~isfield(spikeDetectionParams, 'bottomTopCrossingRate') || isempty(spikeDetectionParams.bottomTopCrossingRate)
                spikeDetectionParams.threshHoldVolts = [-1.2 Inf];
                warning('thresholdVolts not defined - using default value of [-1.2 Inf]');
            else
                spikeDetectionParams.threshHoldVolts = []; % will be determined from rate
            end
        end
        if ~isfield(spikeDetectionParams, 'waveformWindowMs')
            spikeDetectionParams.waveformWindowMs=1.5;
            warning('waveformWindowMs not defined - using default value of 1.5');
        end
        if ~isfield(spikeDetectionParams, 'peakWindowMs')
            spikeDetectionParams.peakWindowMs=0.5;
            warning('peakWindowMs not defined - using default value of 0.5');
        end
        if ~isfield(spikeDetectionParams, 'alignMethod')
            spikeDetectionParams.alignMethod='atPeak';
            warning('alignMethod not defined - using default value of ''atPeak''');
        end
        if ~isfield(spikeDetectionParams, 'peakAlignment')
            spikeDetectionParams.peakAlignment='filtered';
            warning('peakAlignment not defined - using default value of ''filtered''');
        end
        if ~isfield(spikeDetectionParams, 'returnedSpikes')
            spikeDetectionParams.returnedSpikes = 'filtered';
            warning('returnedSpikes not defined - using default value of ''filtered''');
        end
        
        if ~isfield(spikeDetectionParams, 'minmaxVolts')
            if length(spikeDetectionParams.threshHoldVolts) == 3
                spikeDetectionParams.minmaxVolts = [-spikeDetectionParams.threshHoldVolts(3) spikeDetectionParams.threshHoldVolts(3)];
            else
                spikeDetectionParams.minmaxVolts = [-Inf Inf];
                warning('minmaxVolts not defined - using default value of [-Inf Inf], which does not remove any high amplitude noise ever');
            end
        end
        
%         if isfield(spikeDetectionParams, 'bottomTopCrossingRate') && ~isempty(spikeDetectionParams.bottomTopCrossingRate)
%             if ~isempty(spikeDetectionParams.threshHoldVolts)
%                 threshHoldVolts=spikeDetectionParams.threshHoldVolts;
%                 bottomTopCrossingRate=spikeDetectionParams.bottomTopCrossingRate;
%                 error('can''t define threshold and crossing rate at the same time')
%             end
%             doThreshFromRate=true;
%             bottomRate=spikeDetectionParams.bottomTopCrossingRate(1);
%             topRate=spikeDetectionParams.bottomTopCrossingRate(2);
%         else %% ## handles grouping possibility
%             if groupSize > 1

                %gets threshold values for how far from mean data must be
                %to be considered a "spike"
                for i = 1:size(spikeDetectionParams.thresholdVolts,1)
                    loThresh(i) = spikeDetectionParams.thresholdVolts(i,1);
                    hiThresh(i) = spikeDetectionParams.thresholdVolts(i,2);
                    doThreshFromRate=false;
                end
                
                
%             else
%                 loThresh=spikeDetectionParams.thresholdVolts(1);
%                 hiThresh=spikeDetectionParams.thresholdVolts(2);
%                 doThreshFromRate=false;
%             end
%         end
        
        N=round(min(spikeDetectionParams.samplingFreq/200,floor(size(neuralData,1)/3))); %how choose filter orders? one extreme bound: Data must have length more than 3 times filter order.
        [b,a]=fir1(N,2*spikeDetectionParams.freqLowHi/spikeDetectionParams.samplingFreq); %checks if data long enough to filter
        if 3*max(length(b),length(a))>length(neuralData)
            warning('neuralData is not long enough to filter. going to return empty stuff');
            spikes = [];
            spikeWaveforms = [];
            spikeTimestamps = [];
            return;
        end
        filteredSignal=filtfilt(b,a,neuralData); %filters data
        
        if doThreshFromRate
            % get threshold from desired rate of crossing
            [loThresh, hiThresh] = getThreshForDesiredRate(neuralDataTimes,filteredSignal,bottomRate,topRate);
            disp(sprintf('spikeDetectionParams.threshHoldVolts=[%2.3f %2.3f]  %%fit from desired rate',loThresh,hiThresh))
            spikeDetectionParams.threshHoldVolts=[loThresh hiThresh]; % for later display
        end
        
        if strcmp(spikeDetectionParams.thresholdMethod,'STD')
            % the threshold voltages are actually in std units. recalculate
            % thrV
            mFS = mean(filteredSignal,1);
            stdFS = std(filteredSignal,[],1);
            loThresh = mFS+spikeDetectionParams.threshHoldVolts(1)*stdFS;
            hiThresh = mFS+spikeDetectionParams.threshHoldVolts(2)*stdFS;
            
            spikeDetectionParams.minmaxVolts = stdFS*spikeDetectionParams.minmaxVolts;
%             keyboard
        end
        
        spkBeforeAfterMS=[spikeDetectionParams.peakWindowMs spikeDetectionParams.waveformWindowMs-spikeDetectionParams.peakWindowMs];
        spkSampsBeforeAfter=round(spikeDetectionParams.samplingFreq*spkBeforeAfterMS/1000); % ## hard coded value
        %spikeDetectionParams.spkBeforeAfterMS=[0.6 0.975];
        %spkSampsBeforeAfter=[24 39] % at 40000 like default osort:
        %rawTraceLength=64; beforePeak=24; afterPeak=39;
        
        % ## loop through channels
            tops = [];
            bottoms = [];
            topAmountAllChan = [];
            botAmountAllChan = [];
            for i = 1:size(neuralData,2)
                top = find([false; diff(filteredSignal(:,i)>hiThresh(i))>0]);
                bottom = find([false; diff(filteredSignal(:,i)<loThresh(i))>0]);
                topAmountAllChan = [topAmountAllChan length(top)];
                botAmountAllChan = [botAmountAllChan length(bottom)];   % ## makes matrix that keeps track of how many times threshold
                tops = [tops;top];                                      %    is crossed per channel. 
                bottoms = [bottoms;bottom];
            end

        
        [tops,    uTops,    topTimes]   =extractPeakAligned(tops,1,spikeDetectionParams.samplingFreq,spkSampsBeforeAfter,filteredSignal,neuralData, topAmountAllChan);
        [bottoms, uBottoms, bottomTimes]=extractPeakAligned(bottoms,-1,spikeDetectionParams.samplingFreq,spkSampsBeforeAfter,filteredSignal,neuralData, botAmountAllChan);
        
        %maybe sort the order...
        spikes=[topTimes;bottomTimes];
        spikeWaveforms=[tops;bottoms];
        [spikes, sortInds]=sort(spikes);
        spikeWaveforms=spikeWaveforms(sortInds,:,:); 
                
        if doThreshFromRate
            dur=neuralDataTimes(end)-neuralDataTimes(1);
            disp(sprintf('the topRate goal was %2.2fHz but got: %2.2fHz ',topRate,length(topTimes)/dur))
            disp(sprintf('bottomRate  goal was %2.2fHz but got: %2.2fHz ',bottomRate,length(bottomTimes)/dur))
        end
        
        
    otherwise
        error('unsupported spike detection method');
end

%remove extreme spikes
voltageTooExtreme= any(spikeWaveforms(:,:,1)'<spikeDetectionParams.minmaxVolts(1)) | any(spikeWaveforms(:,:,1)'>spikeDetectionParams.minmaxVolts(2));
spikes(voltageTooExtreme)=[];                     % ## NOTE: only checks first channel for voltageTooExtreme for now because it never happened in any test
spikeWaveforms(voltageTooExtreme,:)=[];           %          sets before. 

spikeTimestamps=neuralDataTimes(spikes, 1);      

% organize the spikes in order of time.
[spikeTimestamps, reorderedInds]=sort(spikeTimestamps);  % also get the reorderedInds from this
spikeWaveforms=spikeWaveforms(reorderedInds,:,:);
spikes = spikes(reorderedInds);

% support for lockout
if spikeDetectionParams.lockoutDurMs>0  % ## NOTE: changing order of channels sometimes can slightly change # of spikes blocked
 blocked=find(diff([0; spikeTimestamps])<spikeDetectionParams.lockoutDurMs/1000); % ## hard coded value
 spikes(blocked) = [];
 spikeTimestamps(blocked)=[];
 spikeWaveforms(blocked,:,:)=[]; % check dimentions
end

if length(spikes)~=length(unique(spikes))
    warning('duplicate spikes detected');
end


end % end function

% helper function that takes points where threshold is crossed and builds
% spikes from data around threshold crossings.
function [group uGroup groupPts]=extractPeakAligned(group,flip,sampRate,spkSampsBeforeAfter,filt,data, fromChannel)
maxMSforPeakAfterThreshCrossing=.5; %this is equivalent to a lockout, because all peaks closer than this will be called one peak, so you'd miss IFI's smaller than this.
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

groupPts=group((group+spkLength-1)<length(filt) & group-ceil(spkLength/2)>0);

% this is ugly. but works. computationally identical.
if length(groupPts) ==1
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
    % this code does not guarantee against multiple threshold crossings
    % within the same region of interest. specify a 
    % spikeDetectionParams.lockoutDurMS to later filter them out!
    group = [];
    start = 1;
    for i =  1:size(data,2)   % ## goes through and builds group by iterating through channel data 1 at a time.
        dat = data(:,i);
        g=dat(repmat(groupPts,1,maxPeakSamps)+repmat(0:maxPeakSamps-1,length(groupPts),1)); %use (sharper) unfiltered peaks!
        finish = (start+fromChannel(i)) - 1;
        for k = start:finish
            [junk, loc]=max(flip*g,[],2); % gets max point in size 15 sample
            groupPts(k)=((loc(k)-1)+groupPts(k));     % set group points to new peaks found
            groupPts=groupPts((groupPts+floor(spkLength/2))<length(filt));
        end
        start = finish;
    end
    for i =  1:size(data,2)     % ## after groupPts is centered on peak for specific channel spike was found cycle through
        fil = filt(:,i);        %    all channels again and extract data surrounding peak. 
        g= fil(repmat(groupPts,1,spkLength)+repmat(spkPts,length(groupPts),1)); % replaces group with new full filtered data (group is what turns into "spikes" must focus on these).
        group = cat(3,group,g);
        uGroup=data(repmat(groupPts,1,spkLength)+repmat(spkPts,length(groupPts),1)); %ugroup does same but for unfiltered data
        uGroup=uGroup-repmat(mean(uGroup,2),1,spkLength);
    end
end
% just gonna try with the filtered spikes
% group=filt(repmat(groupPts,1,maxPeakSamps)+repmat(0:maxPeakSamps-1,length(groupPts),1)); %use (sharper) unfiltered peaks!

end

function [loThresh hiThresh] = getThreshForDesiredRate(neuralDataTimes,filtV,bottomRate,topRate)

numSteps=50;
dRate=5000; % down sampled rate
secDur=neuralDataTimes(end)-neuralDataTimes(1);
dTimes=linspace(neuralDataTimes(1),neuralDataTimes(end),secDur*dRate);
whichChan=1;  % only detect off of the first listed chan
dFilt=interp1(neuralDataTimes,filtV(:,whichChan),dTimes,'linear'); %without downsampling, the following line runs out of memory even for singles when > ~15s @40kHz

mm=minmax(filtV);
if any(ismember(mm,[0 -999 999]))
    mm
    error('filtered voltages should always minmax non-zero, and not expected to be -999 or 999')
end

if mm(1)>0
    mm
    error('expected some negative values in filtered min')
end

if mm(2)<0
    mm
    error('expected some posiitve values in filtered max')
end

% loop through: coarse low, coarse high, fine low, fine high
for w=[mm -999 999]
    switch w
        case -999 % 2nd pass fine grain low
            stepSz=abs(mm(1))/numSteps;
            v=linspace(loThresh-stepSz,loThresh+stepSz,numSteps)';
        case 999  % 2nd pass fine grain high
            stepSz=abs(mm(2))/numSteps;
            v=linspace(hiThresh+stepSz,hiThresh-stepSz,numSteps)';
        otherwise % first pass coarse full rage: [min 0] and [max 0]
            v=linspace(w,0,numSteps)';
    end
    
    crossHz=sum(diff((w*repmat(dFilt,numSteps,1))>(w*repmat(single(v),1,length(dFilt))),1,2)>0,2)/secDur;
    if w>0
        hiThresh=v(find(crossHz>topRate,1,'first'));
        if isempty(hiThresh)
            hiThresh=0;
        end
    elseif w<0
        loThresh=v(find(crossHz>bottomRate,1,'first'));
        if isempty(loThresh)
            loThresh=0;
        end
    end
end

end