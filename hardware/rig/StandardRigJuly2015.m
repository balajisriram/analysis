classdef StandardRigJuly2015<rig
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
        function s = StandardRigJuly2015()
            s = s@rig('basPhysiologyRig',0, 0, 120, NaN, NaN);
        end % StandardRigJuly2015
        
    end %methods
end % classdef