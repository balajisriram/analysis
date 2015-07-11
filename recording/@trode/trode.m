classdef trode
    properties 
        trodeName
        chans
        detectionParams
        sortingParams
    end
    
    properties (Constant = true)
        maxAllowableSamplingRateDeviation = 10^-7;
    end
    
    properties (Transient=true)
        neuralData
        neuralDataTimes
    end
    
    methods
        %% constructor
        function tr = trode(chans)
            assert(isnumeric(chans),'chans is not a numeric array')
            tr.chans = chans;            
        end %trode        
        %% createTrodeName
        function trodeName = createTrodeName(s)
            trodeName = mat2str(getChansInTrode(s));
            trodeName = regexprep(regexprep(regexprep(trodeName,' ','_'),'[',''),']','');
            trodeName = sprintf('trode_%s',trodeName);
        end        
        %% getChansInTrode
        function chans = getChansInTrode(s)
            chans = [s.chans(:).chanID];
        end
    end
end