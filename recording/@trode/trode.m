classdef trode
    properties 
        trodeName
        chans
        detectionParams
        sortingParams
        
        units
        
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
            assert(isnumeric(chans),'chans is not a numeric array')
            tr.chans = chans;
        end %trode  
        
        function tr = detectSpikes(tr,dataPath)
            tr.NeuralData = [];
            tr.NeuralDatatimes = [];
            tr.Mean = [];
            tr.Std = [];
            for i = 1:length(tr.chans)
                a = dir(dataPath,sprintf('*_CH%d.continuous',tr.chans(i)));
                if length(a)>1
                    error('too many records');
                else
                    [rawData, rawTimestamps, ~, dataMean, dataStd] =load_open_ephys_data(contFile);
                    if any(diff(rawTimestamps)>tr.maxAllowableSamplingRateDeviation)
                        error('bad timestamps! why?');
                    end
                    tr.NeuralData = [tr.neuralData rawData];
                    tr.NeuralDataTimes = rawTimestamps;
                    tr.Mean = [tr.Mean dataMean];
                    tr.Std = [tr.Std dataStd];
                end
            end
        end
        
        function tr = sortSpikes(tr)
        end

    end
end