classdef monitor
    properties
        monitorName
        monitorType

        width
        height
        xPix
        yPix
        
        calibration
    end
    methods
        %% constructor
        function s = monitor(name,varargin)
            s.monitorName = name;
            switch nargin
                case 2
                    monProp = varargin{1};
                    s.monitorType = monProp.monitorType;
                    s.width = monProp.width;
                    s.height = monProp.height;
                    s.xPix = monProp.xPix;
                    s.yPix = monProp.yPix;
                otherwise
                    error('no idea how you are calling the monitor');
            end
        end % electrode
        
        function out = getDims(s,which)
            if ~exist('which','var')||isempty(which)
                which = 1:2;
            elseif any(which>2|which<1)
                error('only length and width are available');
            end
            out = [s.width s.height];
            out = out(which);
        end
        
        function out = getPixs(s,which)
            if ~exist('which','var')||isempty(which)
                which = 1:2;
            elseif any(which>2|which<1)
                error('only length and width are available');
            end
            out = [s.xPix s.yPix];
            out = out(which);
        end
        
        function mon = setCalibration(mon, calib)
            mon.calibration = calib;
        end
        
    end %methods
end % classdef