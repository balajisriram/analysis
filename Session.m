classdef Session
    properties
        sessionID
        timeStamp
        
        subject
        electrode
        monitor
        rig
        
        sessionPath
        sessionFolder
        trialDataPath
        trials
        
        history
    end
    methods
        function sess = Session(sessionPath,sessionFolder,trialDataPath, electrodeName, monitorName, rigName)
            sess.timeStamp = now;
            
            assert((exist(sessionPath,'dir')==7),'No Access to sessionPath or not correct path');
            sess.sessionPath = sessionPath;
            
            assert((exist(fullfile(sessionPath,sessionFolder),'dir')==7),'No Access to sessionFolder or not correct path');
            sess.sessionFolder = sessionFolder;
            
            assert((exist(trialDataPath,'dir')==7),'No Access to trialDataPath or not Correct path');
            sess.trialDataPath = trialDataPath;
            
            assert(ischar(electrodeName),'electrodeName is not a string');
            sess.electrode = hardware.electrode(electrodeName);
            
            assert(ischar(monitorName),'monitorName is not a string');
            sess.monitor = hardware.monitor(monitorName);
            
            assert(ischar(rigName),'rigName is not a string');
            sess.rig = hardware.rig(rigName);
            
        end
        
        function process(session)
            % loop through the channels, detect spikes, sort and then
            % output singleUnits
        end        
    end
end