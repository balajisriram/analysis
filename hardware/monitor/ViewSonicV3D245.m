classdef ViewSonicV3D245 <monitor

    methods
        %% constructor
        function s = ViewSonicV3D245(name)
            monProp.monitorType = 'LCD';
            monProp.width = 522.9453;
            monProp.height = 294.1567;
            monProp.xPix = 1920;
            monProp.yPix = 1080;
            
            s = s@monitor(name, monProp);
        end % electrode
        
    end %methods
end % classdef