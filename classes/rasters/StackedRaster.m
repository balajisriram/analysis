classdef StackedRaster
    properties
        rasters
        colors
    end
    
    methods
        function sR = StackedRaster(rasters,colors)
            sR.rasters = rasters;
            
            if ~exist('color','var')
                sR.colors = brewermap(length(sR.raster),'pubugn');
            else
                if size(colors)
            end
        end
        
        function plot(sR,axes)
            
        end
        
    end
end