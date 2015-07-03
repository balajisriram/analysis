classdef Session
    properties
        sessionID
        subject
        dataPath
        sessionFolder
        singleUnits
        trials
        history
    end
    methods
        function process(session)
            % loop through the channels, detect spikes, sort and then
            % output singleUnits
        end        
    end
end