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
                %keyboard
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
                %keyboard
            end
        end      
        
        function session = detectSpikes(session)
            for i = 1:length(session.trodes)
                dataPath = fullfile(session.sessionPath,session.sessionFolder);
                try
                    [session.trodes(i), warn] = session.trodes(i).detectSpikes(dataPath, session);
                    det.identifier = ['Session.detectSpikes ' ,datestr(now)];
                    det.message = sprintf('detected on trode %d of %d',i, length(session.trodes));
                    session = session.addToHistory('Completed',det);
                
                    if warn.flag==1
                        det.identifier = ['BAD_TIMESTAMPS'];
                        det.message = warn;
                        session = session.addToHistory('Completed',det);
                    end
                    
                    fName = saveSession(session);
                catch ex
                    session = session.addToHistory('Error',ex);
                    fName = saveSession(session);
                    %keyboard
                end
            end
        end

        function session = sortSpikes(session)
            for i = 1:length(session.trodes)
                try
                    session.trodes(i) = session.trodes(i).sortSpikes();
                    det.identifier = ['Session.sortSpikes ', datestr(now)];
                    det.message = sprintf('sorted on trode %d of %d',i, length(session.trodes));
                    session = session.addToHistory('Completed',det);
                    fName = saveSession(session);          %saves session between each sort just in case fails.
                catch ex
                    session = session.addToHistory('Error',ex);
                    fName = saveSession(session);
                end
            end
        end
        
        function session = inspectSpikes(session,k) % ## added k to start from certain trode if partially complete
            for i = k:length(session.trodes)
                try
                    session.trodes(i) = session.trodes(i).inspectSpikes();
                    det.identifier = ['Session.inspectSpikes ', datestr(now)];
                    det.message = sprintf('inspected on trode %d of %d',i, length(session.trodes));
                    session = session.addToHistory('Completed',det);
                    disp('Saving Session. . .');
                    fName = saveSessionGUI(session);          %saves session between each sort just in case fails.
                catch ex
                    session = session.addToHistory('Error',ex);
                    fName = saveSessionGUI(session);
                end
            end
        end
        
        
        function fileName = saveSession(sess)  % save session as a struct to mat file
            fileName = [sess.sessionFolder,'_',int2str(now),'.mat'];
            save(fileName,'sess', '-v7.3'); %for some reason wouldnt save correctly unless '-v7.3' command added
        end
        
        function fileName = saveSessionGUI(sess)  % save session as a struct to mat file
            fileName = [sess.sessionFolder,'_',int2str(now),'_Inspected.mat'];
            save(fileName,'sess', '-v7.3'); %for some reason wouldnt save correctly unless '-v7.3' command added
        end
        
        function sess = plotSingleUnits(sess, trode)
            tr = sess.trodes(trode);
        
            if isempty(tr.units)
                error('No Single Units');
            else
                for i = 1:length(tr.units)
                    subplot(2,ceil(length(tr.units)/2),i);
                    wv = [];
                    for k = 1:4
                        wv = [wv tr.units(i).waveform(:,:,k)];
                    end
                    plot(wv');
                end
            end
        end
        
        function numUnits = numberUnits(sess)
            numUnits = 0;
            for i = 1:length(sess.trodes)
                numUnits = numUnits + length(sess.trodes(i).units);
            end
        end
        
        function sess = plotAvgSingleUnits(sess)
            numUnits = numberUnits(sess);
            numRows = ceil(numUnits/2);
            k = 1;
            for i = 1:length(sess.trodes)
                for j = 1:length(sess.trodes(i).units)
                    singleUnit = sess.trodes(i).units(j);
                    avgWaveform = getAvgWaveform(singleUnit);
                    [ind,peakInd,bestChan] = getSingleUnitTestData(singleUnit);
                    for z = 1:size(singleUnit.waveform,3)
                        subplot(numRows, 8, k);
                        plot(avgWaveform(:,z));
                        hold on;
                        plot(peakInd, avgWaveform(peakInd,bestChan), '*');
                        plot(ind, avgWaveform(ind,bestChan), '*')
                        k = k+1;
                    end
                end
            end
        end
        
        %% Manipulating the history
        function sess = flushHistory(sess)
            sess.history = {};
        end
        
        function displayHistory(sess)
            if ~isempty(sess.history)
                fprintf('#\tTYPE\tIDENT\t\t\t\t\t\tMESSAGE\n')
            end
            fprintf('%s\n',sess.history{1});
            for i = 2:length(sess.history)
                if isstruct(sess.history{i}{3})
                    fprintf('%d.\t%s\t%s\t\t\t\t\t\tERROR\n',i,sess.history{i}{1},sess.history{i}{2});
                else
                    try
                        fprintf('%d.\t%s\t%s\t\t\t\t\t\t%s\n',i,sess.history{i}{1},sess.history{i}{2},sess.history{i}{3});
                    catch ex
                        fprintf('%d.\t%s\n',i,sess.history{i});
                    end
                end
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