classdef Session
    properties
        sessionID
        timeStamp
        
        subject
        
        sessionPath
        sessionFolder
        trialDataPath
        
        trials
        
        history
    end
    methods
        function sess = Session()
            
        end
        
        function process(session)
            % loop through the channels, detect spikes, sort and then
            % output singleUnits
        end        
    end
end