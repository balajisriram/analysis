classdef Raster
    properties
        trials
        spiketimes
        timerange
    end
    
    properties (Dependent)
        numTrials
    end
    
    methods
        function raster = Raster(trials,spiketimes,timerange)
            raster.trials = trials;
            raster.spiketimes = spiketimes;
            raster.timerange = timerange;
        end
        
        function out = get.numTrials(ras)
            out = length(ras.trials);
        end
        
        function plot(ras,ax)
            if ~exist('ax','var') || isempty(ax)
                ax = axes;
            end
            
            axes(ax); hold on;
            for i = 1:ras.numTrials
                plot(ras.spiketimes{i},i,'k.');
            end
        end
        
        function fr = getFiringRate(ras,range)
            if ~exist('range','var') || isempty(range)
                range = [0 ras.timerange(2)];
            end
            
            temp = ras.spiketimes;
            for i = 1:ras.numTrials
                temp{i} = temp{i}(temp{i}>range(1) & temp{i}<range(2));
            end
            
            spikesEachTrial = cellfun(@length,temp);
            timePeriodEachTrial = diff(range);
            
            fr.m = mean(spikesEachTrial/timePeriodEachTrial);
            fr.sd = std(spikesEachTrial/timePeriodEachTrial);
            fr.sem = fr.sd/sqrt(ras.numTrials);
        end
    end
end