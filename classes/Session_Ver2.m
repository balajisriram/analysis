classdef Session_Ver2 <Session
    properties
    end
    
    methods
        function sess = Session_Ver2(subject,sessionPath,sessionFolder,trialDataPath, etrode, mon, rigState)
            sess = sess@Session(subject,sessionPath,sessionFolder,trialDataPath, etrode, mon, rigState);
        end
        
    end
    
end