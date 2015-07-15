classdef trode
    properties 
        trodeName
        chans
        detectParams
        sortingParams
        
        units
        
        spikeEvents
        spikeWaveForms
        spikeTimeStamps
        spikeAssignedCluster
        spikeRankedCluster
        waveformsToCluster  % ## to make it easier to plot clusters across all channels.
        
        Mean
        Std
    end
    
    properties (Constant = true)
        maxAllowableSamplingRateDeviation = 10^-7;
    end
    
    properties (Transient=true)
        NeuralData = [];
        NeuralDataTimes = [];
    end
    
    methods
        %% constructor
        function tr = trode(chans)
            % ## not sure this is correct error check - assert(isnumeric(chans),'chans is not a numeric array')
            tr.chans = chans;
            % this stuff is hard coded. but thats okay.
            tr.detectParams = filteredThreshold('StandardFiteredThresh_7__14_2015',repmat(4,1,length(chans)),'std');
            
            % set standard sorting params here
            tr.sortingParams = sortingParam(); % ## StandardKlustaKwik
            
        end %trode  
        
        function tr = detectSpikes(tr,dataPath)
            tr.NeuralData = [];
            tr.NeuralDataTimes = [];
            tr.Mean = [];
            tr.Std = [];
            for i = 1:length(tr.chans)
                a = dir(fullfile(dataPath,sprintf('*_CH%d.continuous',tr.chans(i))));
                if length(a)>1
                    error('too many records');
                else
                    [rawData, rawTimestamps, ~, dataMean, dataStd] =load_open_ephys_data(a.name);
                    if any(((diff(rawTimestamps)-mean(diff(rawTimestamps)))/mean(diff(rawTimestamps)))> tr.maxAllowableSamplingRateDeviation)
                        error('bad timestamps! why?');
                    end
                    tr.NeuralData = [tr.NeuralData rawData];
                    tr.NeuralDataTimes = rawTimestamps;
                    tr.Mean = [tr.Mean dataMean];
                    tr.Std = [tr.Std dataStd];
                end
            end
            
            meanAndStd = [tr.Mean; tr.Std];
            
            tr.detectParams = tr.detectParams.setupAndValidateParams(meanAndStd);

            [tr.spikeEvents, tr.spikeWaveForms, tr.spikeTimeStamps]= ...
                tr.detectParams.detectSpikesFromNeuralData(tr.NeuralData, tr.NeuralDataTimes);
            
            tr.NeuralData = [];
            tr.NeuralDataTimes = [];
        end
        
        function tr = sortSpikes(tr)
            tr.spikeAssignedCluster = [];
            tr.spikeRankedCluster = [];
            
            %tr.sortingParams = sortingParam(); % ## moved to constructor
            tr.waveformsToCluster = reshape(tr.spikeWaveForms,tr.numSpikes,tr.numSampsPerSpike*length(tr.chans));

            [tr.spikeAssignedCluster, tr.spikeRankedCluster, spikeModel] = tr.sortingParams.sortSpikesDetected(tr.spikeEvents, tr.waveformsToCluster, tr.spikeTimeStamps);
        end
        
        function out = numSpikes(tr)
            out = size(tr.spikeEvents,1);
        end
        
        function out = numSampsPerSpike(tr)
            out = size(tr.spikeWaveForms,2);
        end

    end
end