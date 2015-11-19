classdef rig
    properties
        rigName
        
        % facts wrt to the animal gaze
        or % angle from perpendicular
        h % height from center of monitor
        d % distance to monitor
        
        % facts wrt to the primary axis of the animal 
        azimuth
        elevation
    end
    methods
        %% constructor
        function s = rig(name, or, h, d, az, ele)
            s.rigName = name;
            
            s.or = or;
            s.h = h; % in mm
            s.d = d; % in mm
            
            s.azimuth = az;
            s.elevation = ele;
        end % rig
        
    end %methods
end % classdef