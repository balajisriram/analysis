classdef Session
    properties
        sessionID % rip From Folder
        timeStamp % get automatically
        
        subject   
        electrode % grouping of electrodes. (single or multi-channel).
        monitor   % all 3 of these object in the 'hardware' folder
        rig
        
        sessionPath   
        sessionFolder  
        trialDataPath 
        trials
        
        trodes
        eventData
                
        history       = {};
    end
    methods
        function sess = Session(subject,sessionPath,sessionFolder,trialDataPath, etrode, mon, rigState)
            assert(ischar(subject),'subject input is not a character')
            sess.subject = subject;
                        
            sess.timeStamp = now;
            
            assert((exist(sessionPath,'dir')==7),'No Access to sessionPath or not correct path');
            sess.sessionPath = sessionPath;
            
            assert((exist(fullfile(sessionPath,sessionFolder),'dir')==7),'No Access to sessionFolder or not correct path');
            sess.sessionFolder = sessionFolder;
            
            assert((exist(trialDataPath,'dir')==7),'No Access to trialDataPath or not Correct path');
            sess.trialDataPath = trialDataPath;
            
            assert(isa(etrode,'electrode'),'etrode is not an electrode');
            sess.electrode = etrode;
            
            assert(isa(mon,'monitor'),'mon is not a monitor');
            sess.monitor = mon;
 
            assert(isa(rigState,'rig'),'rigStat is not a rig');
            sess.rig = rigState;
            
            sess.sessionID = sprintf('%s_%s',upper(subject),datestr(sess.timeStamp,30));
            sess.history{end+1} = sprintf('Initialized session @ %s',datestr(sess.timeStamp,21));
        end
        
        function session = process(session) 
            
            currDir = pwd; 
            if strcmp(currDir, 'C:\Users\Ghosh\Desktop\analysis') ~= 1
                error('Running from wrong folder, must run from analysis base folder');
            end

            
            
            % 1. get events data (##pass in correct file)
            session.eventData = eventData(session.trialDataPath);
            
            % 2. get the trodes for the electrode
            session.trodes = session.electrode.getPotentialTrodes(session.sessionPath,session.sessionFolder);
            
            % 3. detect spikes
            try
                disp('Detecting Spikes ... ');
                session = session.detectSpikes();
            catch ex
                session = session.addToHistory('Error',ex);
                fName = saveSession(session);
                keyboard
            end
            
            %saves session just in case failure before sorting occurs
            fName = saveSession(session);
            
            % 4. sort spikes
            try
                disp('Sorting Spikes ... ');
                session = session.sortSpikes();
            catch ex
                session = session.addToHistory('Error',ex);
                fName = saveSession(session);
                keyboard
            end
        end      
        
        function session = detectSpikes(session)
            for i = 1:length(session.trodes)
                dataPath = fullfile(session.sessionPath,session.sessionFolder);
                try
                    session.trodes(i) = session.trodes(i).detectSpikes(dataPath, session);
                    det.identifier = ['Session.detectSpikes' ,int2str(now)];
                    det.message = sprintf('detected on trode %d of %d',i, length(session.trodes));
                    session = session.addToHistory('Completed',det);
                catch ex
                    session = session.addToHistory('Error',ex);
                    fName = saveSession(session);
                    keyboard
                end
            end
        end

        function session = sortSpikes(session)
            for i = 1:length(session.trodes)
                try
                    session.trodes(i) = session.trodes(i).sortSpikes();
                    det.identifier = ['Session.sortSpikes ', int2str(now)];
                    det.message = sprintf('sorted on trode %d of %d',i, length(session.trodes));
                    session = session.addToHistory('Completed',det);
                    fName = saveSession(session);          %saves session between each sort just in case fails.
                catch ex
                    session = session.addToHistory('Error',ex);
                    fName = saveSession(session);
                end
            end
            fName = saveSession(session);
        end
        
        function fileName = saveSession(sess)  % save session as a struct to mat file
            fileName = [sess.sessionFolder,'_',int2str(now),'.mat'];
            save(fileName,'sess', '-v7.3'); %for some reason wouldnt save correctly unless '-v7.3' command added
        end
        
        %% Manipulating the history
        function sess = flushHistory(sess)
            sess.history = {};
        end
        
        function displayHistory(sess)
            if ~isempty(sess.history)
                fprintf('#\tTYPE\tIDENT\t\t\t\t\t\tMESSAGE\n')
            end
            for i = 1:length(sess.history)
                fprintf('%d.\t%s\t%s\t\t\t\t\t\t%s\n',i,sess.history{i}{1},sess.history{i}{2},sess.history{i}{3});
            end
        end
        
        function sess = addToHistory(sess,type,details)
            switch lower(type)
                case {'err','error'}
                    % details is exception object
                    sess.history{end+1} = {'Err.',details.identifier,details.message,details.stack};
                case 'completed'
                    sess.history{end+1} = {'Comp.',details.identifier,details.message};
                case 'warning'
                    sess.history{end+1} = {'Warning.', details.identifier,details.message,details.data};
            end
        end
                
    end
end