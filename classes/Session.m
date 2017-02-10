classdef Session
    properties
        sessionID % rip From Folder
        timeStamp % get automatically
        
        subject   
        electrode % grouping of electrodes. (single or multi-channel).
        monitor   % all 3 of these object in the 'hardware' folder
        rig
        trials
        trialDetails
        
        sessionPath   
        sessionFolder  
        trialDataPath 
        
        trodes
        eventData
                
        history       = {};
        
        IsInspected = false;
        refreshRate = NaN;
        samplingFreq = NaN;
    end
    methods % constructors and basic analysis
        function sess = Session(subject,sessionPath,sessionFolder,trialDataPath, etrode, mon, rigState)
            if nargin==0
                return
            elseif nargin==1 && isa(subject,'Session')
                sess = subject;
                return
            end
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
        
        % detects and sorts spikes, as well as gets event data for a
        % session. The root method call.
        function session = process(session, mappings) 
            
            currDir = pwd; 
            
            % 1. get events data (##pass in correct file)
            session.eventData = eventData(session.trialDataPath, mappings);
            
            % 2. get the trodes for the electrode
            session.trodes = session.electrode.getPotentialTrodes(session.sessionPath,session.sessionFolder);
            
            % 3. detect spikes
            try
                disp('Detecting Spikes ... ');
                session = session.detectSpikes();
            catch ex
                session = session.addToHistory('Error',ex);
                fName = saveSession(session);
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
            end
        end      
        
        % takes raw neural data and goes through it in order to detect
        % spikes.
        function session = detectSpikes(session)
            for i = 1:length(session.trodes)
                dataPath = fullfile(session.sessionPath,session.sessionFolder); %finds corresponding .continuous file
                try
                    [session.trodes(i), warn] = session.trodes(i).detectSpikes(dataPath, session); %detects spikes
                    det.identifier = ['Session.detectSpikes ' ,datestr(now)];          
                    det.message = sprintf('detected on trode %d of %d',i, length(session.trodes));
                    session = session.addToHistory('Completed',det);
                
                    if warn.flag==1 % if bad timestamps found while detecting
                        det.identifier = ['BAD_TIMESTAMPS'];
                        det.message = warn;
                        session = session.addToHistory('Completed',det); %saves any bad timestamps to history
                    end
                    
                    fName = saveSession(session); %save after each trode in case failure
                catch ex
                    session = session.addToHistory('Error',ex);
                    fName = saveSession(session);
                end
            end
        end

        % once spikes detected, using klustakwik algorithm to sort spikes
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
        
        % once spikes sorted, use inspect spikes to pull up GUI to further
        % cluster the spikes.
        function session = inspectSpikes(session,k)
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
            session.IsInspected = true;
        end
        
        function sess = populateTrialDetails(sess, stimRecordsFolder)
            % getTrialDetails - Gets more in depth trial information stored in the
            %                   stim records folder in all data folders.
            %                   Stored in sess.eventData.
            %
            % parameters - sess: session to be added to
            %            - stimRecordedFolder: folder where stim data is held.
            %
            % return - sess: session should now contain correct stim data.
            
            % first identify the trials in sess. needs to be cleaned
            if ~isempty(sess.trialDetails)
                fprintf('PREV.DONE\t')
                return
            end
            try
                trialsUnclean = real([sess.eventData.trials.trialNumber]);
            catch
                trialsUnclean = real([sess.eventData.trialData.trialNum]);
            end
            trials = nan(size(trialsUnclean));
            which = diff([trialsUnclean(1)-1 trialsUnclean])~=1;
            trials(~which) = trialsUnclean(~which);
            if (length(trialsUnclean(which))/length(trialsUnclean)>0.01)
                fprintf('fracUnclean = %2.2f\t',length(trialsUnclean(which))/length(trialsUnclean));
                %warning('Session:populateTrialDetails:problematicData','too many failed trials - why is that?');
            end
            sess.trials = trials;
            
            % now find the data in stimRecordFolder and fill'er up
            fPath = [stimRecordsFolder,'\stim*'];
            
            for i = 1:length(sess.trials)
                if isnan(sess.trials(i))
                    continue
                end
                stimRecName = sprintf('stimRecords_%d-*.mat',sess.trials(i));
                files = dir(fullfile(stimRecordsFolder,stimRecName));
                if length(files)>1 
                    error('Session:populateTrialDetails:problematicData','too many stim records trial number %d',sess.trials(i));
                elseif length(files)<1
                    fprintf('\nno record for tr: %d\t',sess.trials(i));
                    continue
                end
                temp = load(fullfile(stimRecordsFolder,files.name));
                sess.trialDetails(i).trialNum = temp.trialNum;
                sess.trialDetails(i).refreshRate = temp.refreshRate;
                sess.trialDetails(i).trialStartTime = datetime(temp.trialStartTime);
                sess.trialDetails(i).stepName = temp.stepName;
                sess.trialDetails(i).stimManagerClass = temp.stimManagerClass;
                switch sess.trialDetails(i).stimManagerClass
                    case 'afcGratings'
                        sess.trialDetails(i).stimDetails.pixPerCycs        = temp.stimulusDetails.pixPerCycs; 
                        sess.trialDetails(i).stimDetails.driftfrequencies  = temp.stimulusDetails.driftfrequencies; 
                        sess.trialDetails(i).stimDetails.orientations      = temp.stimulusDetails.orientations; 
                        sess.trialDetails(i).stimDetails.phases            = temp.stimulusDetails.phases; 
                        sess.trialDetails(i).stimDetails.contrasts         = temp.stimulusDetails.contrasts; 
                        sess.trialDetails(i).stimDetails.maxDuration       = temp.stimulusDetails.maxDuration; 
                        sess.trialDetails(i).stimDetails.radii             = temp.stimulusDetails.radii; 
                        sess.trialDetails(i).stimDetails.LEDON             = temp.stimulusDetails.LEDON; 
                    otherwise
                        keyboard
                end
            end 
        end
        
        %to add more information to eventData class
        function sess = addToEventData(sess)
            sess.eventData = eventData(['D:\FullRecordedData\',sess.sessionFolder]);
            %sess.eventData = eventData();
            
            fname = saveSession(sess);
            %fname = saveSessionGUI(sess);
        end
        
        function sess = addToEventDataGUI(sess)
            sess.eventData = eventData(['D:\FullRecordedData\',sess.sessionFolder]);
            %sess.eventData = eventData();
            
            %fname = saveSession(sess);
            fname = saveSessionGUI(sess);
        end
        
        function fileName = saveSession(sess)  % save session as a struct to mat file
            fileName = [sess.sessionFolder,'_',int2str(now),'.mat'];
            save(fileName,'sess', '-v7.3'); %for some reason wouldnt save correctly unless '-v7.3' command added
        end
        
        function fileName = saveSessionGUI(sess)  % save session as a struct to mat file
            fileName = [sess.sessionFolder,'_',int2str(now),'_Inspected.mat'];
            save(fileName,'sess', '-v7.3'); %for some reason wouldnt save correctly unless '-v7.3' command added
        end        
    end
    methods % collect important facts about session
        % gets smallest trial number
        function minTrial = minTrialNum(sess)
            if length(sess.eventData.messages) == 1 % cases where we dont have Messages Events
                minTrial = Nan; 
            else
                minTrial = sess.eventData.messages(1).trial;    
            end
        end
        
        % gets largest trial number
        function maxTrial = maxTrialNum(sess)
            if length(sess.eventData.messages) == 1 % cases where we dont have Messages Events
                maxTrial = Nan;
            else
                maxTrial = sess.eventData.messages(end).trial;
            end            
        end
        
        % gets start and end index for a trial
        function [startInd,stopInd] = getIndexForTrial(sess, trial) 
            [startTime, endTime] =  getTrialStartStopTime(sess, trial); 
            samplingFreq = sess.trodes(1).detectParams.samplingFreq;
            
            startInd = startTime*samplingFreq;
            stopInd = endTime*samplingFreq;
        end
        
        % getIndexForTrialFromEventData
        function out = getIndexForTrialFromEventData(sess,trial)
            if trial > sess.maxTrialNum || trial < sess.minTrialNum
                error('ERROR: trial out of range of session');
            end
            allEventTrialnumbers = {sess.eventData.trials.trialNumber};
            temp = cellfun(@(x) x==trial,allEventTrialnumbers,'UniformOutput',false);
            temp(cellfun(@isempty,temp)) = {false}; % make the missing values to zero
            
            out = cell2mat(temp);
        end
        
        % getIndexForTrialFromTrialDetails
        function out = getIndexForTrialFromTrialDetails(sess,trial)
            if trial > sess.maxTrialNum || trial < sess.minTrialNum
                error('ERROR: trial out of range of session');
            end
            allTrialNumbers = {sess.trialDetails.trialNum};
            temp = cellfun(@(x) x==trial,allTrialNumbers,'UniformOutput',false);
            temp(cellfun(@isempty,temp)) = {false}; % make the missing values to zero
            
            out = cell2mat(temp);
        end
        
        % gets start and end time for a trial
        function [startTime, endTime] =  getTrialStartStopTime(sess, trial)
            which = sess.getIndexForTrialFromEventData(trial);
            if any(which)
                startTime = sess.eventData.trials(which).start;
                endTime = sess.eventData.trials(which).stop;
            else
                startTime = NaN;
                endTime = NaN;
            end
        end
        
        % gets all the events for a passed in trial
        function trialEvents = getTrialEvents(sess, trial)
            [startTime, endTime] =  getTrialStartStopTime(sess, trial);
            
            eData = sess.eventData.out;
            for i = 1:length(eData)
                ind = (eData(i).eventTimes <= endTime & eData(i).eventTimes >= startTime);
                trialEvents(i).channelNum = eData(i).channelNum;
                trialEvents(i).eventTimes = eData(i).eventTimes(ind);
                trialEvents(i).eventID = eData(i).eventID(ind);
                trialEvents(i).eventType = eData(i).eventType(ind);
                trialEvents(i).sampNum = eData(i).sampNum(ind);
            end
        end
        
        % plots the events for a passed in trial
        function success = plotTrialEvents(sess, trial)
            success = true;
            samplingFreq = sess.trodes(1).detectParams.samplingFreq;
            
            [start,stop] = sess.getIndexForTrial(trial);

            xAxis = (start-1000:stop+1000);
            numChans = length(sess.eventData.out);
            
            trialEvents = getTrialEvents(sess, trial);
            
            figure; hold on;
            for i = 1:numChans %for each channel in out data

                eventID = trialEvents(i).eventID;
                eventTimes = trialEvents(i).eventTimes;
                
                yAxis = zeros(1, length(xAxis));
                if isempty(eventID)
                    return
                end

                eventInd = 1;
                eventVal = ~eventID(eventInd);
                for k = 1:length(xAxis)
                    if eventInd > length(eventTimes)
                        yAxis(k) = eventVal;
                    elseif xAxis(k) < (eventTimes(eventInd)*samplingFreq)
                        yAxis(k) = eventVal;
                    else
                        eventInd = eventInd+1;
                        eventVal = ~eventVal;
                        yAxis(k) = eventVal;
                    end
                end
                xVal = (xAxis-min(xAxis))/samplingFreq*1000;
                plot(xVal, yAxis+2*(i-1));
                axis([xVal(1), xVal(end), -.5, 2*numChans]);
                hold on;
            end
        end
        
        % gets the duration of frame and stim for all trials of a session.
        function [trialNumber, frameDuration, stimDuration] = getFrameStimDuration(sess)
            maxTrial = maxTrialNum(sess);  
            minTrial = minTrialNum(sess);
            
            numTrials = maxTrial-minTrial;
            frameStart = zeros(1, numTrials);
            frameStop = zeros(1,numTrials);
            
            stimStart = zeros(1, numTrials);
            stimStop = zeros(1, numTrials);
            
            j = 1;
            for i = minTrial:maxTrial %for each trial
                trialEvents = getTrialEvents(sess, i);
                if isempty(trialEvents(2).eventTimes) %if no frame data
                    frameStart(j) = 0;
                    frameStop(j) = 0;
                else
                    frameStart(j) = trialEvents(2).eventTimes(1);
                    frameStop(j) = trialEvents(2).eventTimes(end);
                end
                if isempty(trialEvents(3).eventTimes)  % if no stim data
                    stimStart(j) = 0;
                    stimStop(j) = 0;
                else
                    stimStart(j) = trialEvents(3).eventTimes(1);
                    stimStop(j) = trialEvents(3).eventTimes(end);
                end
                j = j+1;
            end
            frameDuration = frameStop-frameStart;
            stimDuration = stimStop-stimStart;
            trialNumber = minTrial:maxTrial;
            
            plotOn = false;
            if plotOn
                figure;
                plot((stimStop-stimStart),(frameStop-frameStart),'k.');
                hold on;
                plot([0 max((frameStop-frameStart),(stimStop-stimStart))],[0 max((frameStop-frameStart),(stimStop-stimStart))],'k');
                axis square;
                
            end
        end
        
        % numTrials
        function out = numTrials(sess)
            out = sum(~isnan(sess.trials));
        end
        
        function out = misAlignmentInTrialNums(sess)
            deets = [sess.trialDetails];
            tNumDeets = [deets.trialNum];
            tNum = sess.trials;
            if length(tNum)~=length(tNumDeets)
                out.trialNumbersDifferentSizes = true;
            else
                out.trialNumbersDifferentSizes = false;
            end
            
            if ~out.trialNumbersDifferentSizes
                if all(tNumDeets(~isnan(tNumDeets))==tNum(~isnan(tNum)))
                    out.tNumsDifferent = false;
                else
                    out.tNumsDifferent = true;
                end
            else
                out.tNumsDifferent = true;
            end
        end
        
        % printStimDetails for trial
        function printStimDetails(sess,trial)
            ind = sess.getIndexForTrialFromTrialDetails(trial);
            trialDetail = sess.trialDetails(ind);
            
            fprintf('\n TRIAL NUMBER : %d',trialDetail.trialNum);
            fprintf('\n STEPNAME : %s',trialDetail.stepName);
            fprintf('\n DURATION : %2.2f',trialDetail.stimDetails.maxDuration*1/60);
            fprintf('\n CONTRAST : %2.2f',trialDetail.stimDetails.contrasts);
            fprintf('\n OR : %2.2f\n',rad2deg(trialDetail.stimDetails.orientations));
        end
        
        % getStimDetails for trial
        function out = getStimDetailsForTrial(sess,trials)
            ind = sess.getIndexForTrialFromTrialDetails(trials);
            trialDetail = sess.trialDetails(ind);
            if ~isempty(trialDetail)
            out = [trialDetail.trialNum trialDetail.stimDetails.orientations trialDetail.stimDetails.contrasts trialDetail.stimDetails.maxDuration];
            else
                out = [trials NaN NaN NaN];
            end
        end
        
        function out = getStimDetails(sess)
            out = nan(sess.numTrials, 4);
            trs = sess.minTrialNum:sess.maxTrialNum;
            for i = 1:length(trs);
                out(i,:) = sess.getStimDetailsForTrial(trs(i));
            end
        end
        
        function out = getStimAndSpikeNumberDetails(sess,durationAfterStimEndInMS)
            stimDeets = sess.getStimDetails;
            out = nan(size(stimDeets,1),4+sess.numUnits);
            out(:,1:4) = stimDeets;
            allUnits = sess.collateUnits;
            trs = sess.minTrialNum:sess.maxTrialNum;
            for i = 1:length(trs)
                for j = 1:length(allUnits)
                    temp = sess.trialRaster(trs(i),allUnits(j),[0 out(i,4)/60*1000+durationAfterStimEndInMS]);
                    out(i,4+j) = sum(temp{1});
                end
            end
            
        end
        
        function printDetailsAboutSession(sess)
            if isempty(sess.trialDetails)
                fprintf('\nTRIAL DETAILS NOT AVAILABLE\n');
                return
            end
            fprintf('\n NUM TRIALS: %d',length(sess.trials));
            fprintf('\n NUM GOOD: %d',sess.numTrials);
            fprintf('\n NUM NAN: %d',sum(isnan(sess.trials)));
            fprintf('\n\n MIN TRIAL NUM: %d',sess.minTrialNum);
            fprintf('\n MAX TRIAL NUM: %d',sess.maxTrialNum);
            
            out = sess.misAlignmentInTrialNums;
            
            fprintf('\n TRIAL NUMBERS LENGTHS MATCH IN DETAILS IS %d',~out.trialNumbersDifferentSizes)
            fprintf('\n TRIAL NUMBERS MATCH IN DETAILS IS %d',~out.tNumsDifferent)
            fprintf('\n\n')
        end
                
    end
    
    methods % methods to deal with the craziness of adding eventData
        function out = DetailsAndEventDataAreCongruous(sess)
            out = false;
            sess = sess.fixTrialNumbers();
            % there are different ways in which we represent the trial data
            if ~isempty(sess.eventData.trialData)
            else
                dets = [sess.trialDetails];
                TrialNumInStimDetails = [dets.trialNum];
                stimDets = [dets.stimDetails];
                StimDurationFromStimulusDetails = [stimDets.maxDuration]/60;
                
                TrialNumInStimEventData = [sess.eventData.stim.trialNumber];
                StimStartTimes = [sess.eventData.stim.start];
                StimStopTimes = [sess.eventData.stim.stop];
                StimDurationsFromEventData = StimStopTimes-StimStartTimes;
                
                TrialsInDetailsNotInEvents = double(setdiff(TrialNumInStimDetails,TrialNumInStimEventData));
                TrialsInEventsNotInDetails = double(setdiff(TrialNumInStimEventData,TrialNumInStimDetails));
                if length(TrialNumInStimEventData>TrialNumInStimDetails)
                else
                    extraTrials
                end
                
                keyboard
            end
        end
        
        function out = containsStimInEventData(sess)
            out = ~isempty(sess.eventData.stim);
        end
        
        function out = containsFramesInEventData(sess)
            out = ~isempty(sess.eventData.frame);
        end
        
        function sess = fixComplexTrialNumbers(sess)
            for i = 1:length(sess.eventData.trials)
                if ~isreal(sess.eventData.trials(i).trialNumber)
                    keyboard
                end
            end
        end
        
        function sess = fixNonSequentialTrialNumbers(sess)
            fprintf('\n\n');
            minTrialNum = sess.minTrialNum;
            for i = 1:length(sess.eventData.stim)-1
                try
                    if isempty(sess.eventData.stim(i).trialNumber) || sess.eventData.stim(i).trialNumber ~= (i-1) + minTrialNum
                        fprintf('(i-2):\t%d, (i-1):\t%d, (i):\t%d, (i+1):\t%d, (i+1):\t%d\n',...
                            sess.eventData.stim(i-2).trialNumber,...
                            sess.eventData.stim(i-1).trialNumber,...
                            sess.eventData.stim(i).trialNumber,...
                            sess.eventData.stim(i+1).trialNumber,...
                            sess.eventData.stim(i+2).trialNumber)
                        sess.eventData.stim(i).trialNumber = input('trialNumber:');
                        sess.eventData.trials(i).trialNumber = sess.eventData.stim(i).trialNumber;
                        sess.eventData.frame(i).trialNumber = sess.eventData.stim(i).trialNumber;
                    end
                catch ex
                    getReport(ex)
                    keyboard
                end
            end
        end
        
        function sess = fixTrialNumbers(sess)
            fprintf('\n\n');
            minTrialNum = sess.minTrialNum;
            if sess.eventData.stim(1).trialNumber ~=minTrialNum
                return
            end
            try
                for i = 1:length(sess.eventData.stim)-1
                    if sess.eventData.stim(i).trialNumber ~= (i-1) + minTrialNum
                        fprintf('previous:\t%d, current:\t%d, next:\t%d\n',sess.eventData.stim(i-1).trialNumber,sess.eventData.stim(i).trialNumber,sess.eventData.stim(i+1).trialNumber)
                        % skip one and see if that fits
                        if sess.eventData.stim(i+1).trialNumber == i + minTrialNum;
                            sess.eventData.stim(i).trialNumber = (i-1) + minTrialNum;
                        else
                            keyboard
                        end
                    end
                    
                    if sess.eventData.trials(i).trialNumber ~= (i-1) + minTrialNum
                        % skip one and see if that fits
                        if sess.eventData.trials(i+1).trialNumber == i + minTrialNum;
                            sess.eventData.trials(i).trialNumber = (i-1) + minTrialNum;
                        else
                            keyboard
                        end
                    end
                    
                    if sess.eventData.frame(i).trialNumber ~= (i-1) + minTrialNum
                        % skip one and see if that fits
                        if sess.eventData.frame(i+1).trialNumber == i + minTrialNum;
                            sess.eventData.frame(i).trialNumber = (i-1) + minTrialNum;
                        else
                            keyboard
                        end
                    end
                end
            catch ex
                getReport(ex)
            end
        end
        
        % eventTrialNumbersAreInSequence
        function [inOrder]= eventTrialNumbersAreInSequence(sess)
            inOrder = false;
            try
                trialsInStim = [sess.eventData.stim.trialNumber];
                trialSequence = sess.minTrialNum:sess.maxTrialNum;
                if length(setdiff(trialSequence,trialsInStim))==1 && setdiff(trialSequence,trialsInStim)==sess.maxTrialNum
                    inOrder = true; % sometimes the last trial is missing
                elseif isempty(setdiff(trialSequence,trialsInStim))
                    inOrder = true;
                else
                    inOrder = false;
                end
            catch ex
                getReport(ex)
            end
        end
        
        % trialNumbersAreInOrder
        function [inOrder, reason]= trialNumbersAreInOrder(sess)
            inOrder = true;
            reason = ' ';
            if length(sess.trials) ~= length([sess.eventData.stim.trialNumber])
                inOrder = inOrder && false;
                reason = [reason 'unequaltrialNumbers; '];
            elseif any(sess.trials~=[sess.eventData.stim.trialNumber])
                inOrder = inOrder && false;
                reason = [reason 'some unequal trialValues; '];
            end
            if any(~isreal([sess.eventData.stim.trialNumber]))
                inOrder = inOrder && false;
                reason = [reason 'some values are complex; '];
            end
            
            
        end
    end
    methods % manipulate data within trodes
        % Manipulating and plotting data in the session
        function [corrList, lag] = getXCorr(sess, unitIdent, lag, bin, plotOn)
            if ~exist('plotOn','var') || isempty(plotOn)
                plotOn = false;
            end
            
            corrList = zeros(sess.numUnits, lag*2+1);
            counter = 1;
            
            refUnit = sess.trodes(unitIdent(1)).units(unitIdent(2));
            
            for i = 1:length(sess.trodes)
                for j = 1:length(sess.trodes(i).units)
                    [corr, lag] = crossCorr(refUnit, sess.trodes(i).units(j), lag, bin);
                    
                    corrList(counter,:) = corr;
                    
                    counter = counter + 1;
                end
            end
            
            if plotOn
                [xx, yy] = getGoodArrangement(sess.numUnits);
                for i = 1:sess.numUnits
                    subplot(xx,yy,i);
                    hold on;
                    plot(corrList(i,:));
                end
            end
        end

        function sess = plotSingleUnits(sess, trode)
            tr = sess.trodes(trode);
        
            if isempty(tr.units)
                error('No Single Units');
            else
                numUnits = length(tr.units);
                [xx,yy] = getGoodArrangement(numUnits);
                for i = 1:numUnits
                    ax = subplot(xx,yy,i);
                    ax.UserData.keyText = sprintf('t%d',trode);
                    tr.units(i).plot(ax);
                    text(1,1,ax.UserData.keyText,'units','normalized','horizontalalignment','right','verticalalignment','top');
                end
            end
        end
        
        function plotAllClusters(sess)
            for i = 1:length(sess.trodes)
                f = sess.plotAllClustersInTrode(i);
                pause
                try
                    close(f);
                end
            end
        end
        
        function f = plotAllClustersInTrode(sess,tr)
            nClusts = unique(sess.trodes(tr).spikeAssignedCluster);
            arrParam.mode = 'maxAxesPerFig';
            arrParam.maxAxesPerFig = 30;
            [nx, ny, nFigs] = getGoodArrangement(length(nClusts),arrParam);
            clust = 1;
            axNum = 1;
            trodenum = 1;
            f = figure;
            for i = 1:length(nClusts)
                ax = subplot(nx, ny, axNum);
                
                which = sess.trodes(tr).spikeAssignedCluster==clust;
                spikes = mean(sess.trodes(tr).spikeWaveForms(which,:));
                spikeErr = std(sess.trodes(tr).spikeWaveForms(which,:))/sqrt(size(sess.trodes(tr).spikeWaveForms(which,:),1));
                f_err = fill([1:length(spikes) fliplr(1:length(spikes))],[spikes+spikeErr fliplr(spikes-spikeErr)],'b');
                set(f_err,'FaceAlpha',0.5);
                hold on; plot(1:length(spikes),spikes,'b');
                title(i);
                clust = clust+1;
                axNum = axNum+1;
                
                if axNum >arrParam.maxAxesPerFig
                    % make new figure
                    f(end+1) = figure;
                    axNum = 1;
                end
            end
        end
        
        %note, combines but does not sort after combination.
        function sess = combineSingleUnits(sess, trodeNum, unitNum1, unitNum2)
        
            if unitNum1 < 1 || unitNum2 < 1
                error('unit number must be positive');
            end
            if unitNum1 == unitNum2
                error('must refer to different units');
            end
            maxLen = length(sess.trodes(trodeNum).units);
            if unitNum1 > maxLen || unitNum2 > maxLen
                error('index out of bounds');
            end  
            
            unit1 = sess.trodes(trodeNum).units(unitNum1);
            unit2 = sess.trodes(trodeNum).units(unitNum2);
            
            unit1.index = [unit1.index; unit2.index];
            unit1.timestamp = [unit1.timestamp; unit2.timestamp];
            unit1.waveform = [unit1.waveform; unit2.waveform];
            
            %change order of timestamps, index, waveform of unit1 here. (or
            %maybe keep unordered for easier seperation in the future).
            
            %find(diff(sess.trodes(trodeNum).units(unit1).index) < 0)
            %this finds index of start of unit2's data.
            
            sess.trodes(trodeNum).units(unitNum1) = unit1;
            sess.trodes(trodeNum).units(unitNum2) = [];
        
        end
        
        function out = numTrodes(sess)
            out = length(sess.trodes);
        end
        
        function numUnits = numUnits(sess)
            numUnits = 0;
            for i = 1:length(sess.trodes)
                numUnits = numUnits + sess.trodes(i).numUnits;
            end
        end
        
        function [allUnits, ident, uid] = collateUnits(sess)
            uid = {};
            numUnits = sess.numUnits();
            ident.unitNum = [];
            ident.trodeNum = [];
            %allUnits(numUnits) = singleUnit(NaN,NaN,NaN,NaN,NaN,NaN);
            k = 0;
            for i = 1:length(sess.trodes)
                for j = 1:sess.trodes(i).numUnits
                    allUnits(k+1) = sess.trodes(i).units(j);
                    ident.trodeNum(end+1) = i;
                    ident.unitNum(end+1) = j;
                    k = k+1;
                end
            end
            
            ts = [ident.trodeNum];
            us = [ident.unitNum];
            
            if ~exist('allUnits','var')
                allUnits = [];
            end
            
            for i = 1:length(allUnits)
                uid{end+1} = sprintf('t%du%d',ts(i),us(i));
            end
            
            if ~exist('allUnits','var')
                allUnits = [];
                ident = [];
            end
            
            
        end
        
        function plotWaveforms(sess)
            numUnits = sess.numUnits();
            [xx, yy, numFigs] = getGoodArrangement(numUnits);
            k = 1;
            for i = 1:length(sess.trodes)
                for j = 1:length(sess.trodes(i).units)
                    singleUnit = sess.trodes(i).units(j);
                    [waveFormAvg, ~]  = getAvgWaveform(singleUnit);
                    subplot(xx, yy, k); hold on;
                    waveFormLength = size(waveFormAvg,1);
                    for z = 1:size(singleUnit.waveform,3)
                        plot((z-1)*waveFormLength+(1:waveFormLength),waveFormAvg(:,z));
                    end
                    k = k+1;
                    set(gca,'xtick',[]);
                end
            end
        end
        
        function out = getAllWaveforms(sess)
            numUnits = sess.numUnits;
            [allUnits,ident,uid] = sess.collateUnits;
            out.waveformM = cell(1,numUnits);
            out.waveformSD = out.waveformM;
            for i = 1:length(allUnits)
                [out.waveformM{i}, out.waveformSD{i}]= allUnits(i).getAvgWaveform;
            end
            out.ident = ident;
            out.uid = uid;
        end
        
        function out = getAllISIs(sess)
            numUnits = sess.numUnits;
            [allUnits,ident,uid] = sess.collateUnits;
            out.ISIs = cell(1,numUnits);
            
            for i = 1:length(allUnits)
                out.ISIs{i} = allUnits(i).ISI;
            end
            out.ident = ident;
            out.uid = uid;
        end
        
        function out = getAllFWAtZeros(sess)
            numUnits = sess.numUnits;
            [allUnits,ident,uid] = sess.collateUnits;
            out.FWAt0s = cell(1,numUnits);
            
            for i = 1:length(allUnits)
                out.FWAt0s{i} = allUnits(i).FWAtZero;
            end
            out.ident = ident;
            out.uid = uid;
        end
        
        function out = getAllFWHMs(sess)
            numUnits = sess.numUnits;
            [allUnits,ident,uid] = sess.collateUnits;
            out.FWHMs = cell(1,numUnits);
            
            for i = 1:length(allUnits)
                out.FWHMs{i} = allUnits(i).FWHM;
            end
            out.ident = ident;
            out.uid = uid;
        end
        
        function out = getAllPeakToTroughs(sess)
            numUnits = sess.numUnits;
            [allUnits,ident,uid] = sess.collateUnits;
            out.PeakToTroughs = cell(1,numUnits);
            
            for i = 1:length(allUnits)
                out.PeakToTroughs{i} = allUnits(i).getPeakToTrough;
            end
            out.ident = ident;
            out.uid = uid;
        end
        
        function out = getAllNumChans(sess)
            numUnits = sess.numUnits;
            [allUnits,ident,uid] = sess.collateUnits;
            out.NumChans = cell(1,numUnits);
            
            for i = 1:length(allUnits)
                out.NumChans{i} = allUnits(i).numChans;
            end
            out.ident = ident;
            out.uid = uid;
        end
        
        function out = getReport(sess)
            numTrodes = sess.numTrodes();
            % get the autonomous details for each trode
            for i = 1:numTrodes
                fprintf('trode %d of %d\n',i,numTrodes);
                out.trodeDetails{i}.chans = sess.trodes(i).chans;
                out.trodeDetails{i}.report = sess.trodes(i).getReport();
            end
        end
        
        function raster = getRaster(sess, what, wrt)
        end
        
        function raster = trialRaster(sess, trials, unit, range)
            % trialRaster - takes a list of trials, a single unit, and a range, and
            %               returns a raster indicating the how many times the unit
            %               appears in each trial.
            %
            % Parameters: trials - list of which trials to check for correspondance.
            %             unit - which unit to count for in each trial.
            %             range - [before, after] in number of milliseconds to give a
            %                     buffer of time in which how close a spike can occur
            %                     to be considered due to that trial.
            %
            % Return: raster - cell array of length(trials) where each cell contains
            %                  indices of all spikes that occur within range of of
            %                  stimOnset of trial
            
            raster = cell(1,length(trials));
            freq = sess.trodes(1).detectParams.samplingFreq;
            rangeInSamps = (range/1000)*freq; %ms to samples
            
            
            ind = sess.getIndexForTrialFromEventData(trials);
            stimOnsetInd = [sess.eventData.stim(ind).start]*freq;
            minInd = stimOnsetInd-rangeInSamps(1);
            maxInd = stimOnsetInd+rangeInSamps(2);
            
            for i = 1:length(maxInd)
                sampInd = minInd(i):maxInd(i);
                which = intersect(unit.index, sampInd)-minInd(i)+1;
                inds = zeros(1,length(sampInd));
                inds(uint16(which)) = 1;
                raster{i} = inds;
            end
        end
        
        function plotFailureRates(sess,u)
            fA = sess.getFailureAnalysis(u);
            
            figure;
            ax = subplot(1,2);
            DURS = fA.DURS;
            CTRS = fA.CTRS;
            
            % For Left
%             whichOR = 
        end
        
        function failureAnalysis = getFailureAnalysis(sess,unit)
            temp = {sess.trialDetails.stepName};
            temp = temp(~cellfun(@isempty,temp));
            stepsHere = unique(temp);
            if ismember('gratings_LED',stepsHere)
                whichStepName = 'gratings_LED';
            else
                whichStepName = 'gratings';
            end
            whichStep = strcmp({sess.trialDetails.stepName},whichStepName);
            
            temp1 = {sess.trialDetails.trialNum};
            temp1(find(cellfun(@isempty,temp1))) = {nan(size(find(cellfun(@isempty,temp1))))};
            trNum = cell2mat(temp1); trNumThatStep = trNum(whichStep);
            
            tD = sess.trialDetails; 
            temp2 = {tD.trialNum};
            temp2(find(cellfun(@isempty,temp2))) = {nan(size(find(cellfun(@isempty,temp2))))};
            goodTrNumInTD = temp2(whichStep);
            sD = [tD(whichStep).stimDetails];
            
            orientations = [sD.orientations];
            maxDurations = [sD.maxDuration];
            contrasts = [sD.contrasts];
            
            ORS = unique(orientations);
            DURS = unique(maxDurations);
            CTRS = unique(contrasts);
            
            failureAnalysis.ORS = ORS;
            failureAnalysis.DURS = DURS;
            failureAnalysis.CTRS = CTRS;
            
            failureAnalysis.trials = cell(length(ORS),length(DURS),length(CTRS));
            for i = 1:length(ORS)
                for j = 1:length(DURS)
                    for k = 1:length(CTRS)
                        whichThatOR_DUR_CTR = orientations==ORS(i) & maxDurations==DURS(j) & contrasts==CTRS(k);
                        failureAnalysis.trials{i,j,k}= cell2mat(goodTrNumInTD(whichThatOR_DUR_CTR));
                    end
                end
            end
            
            failureAnalysis.spiking = cell(length(ORS),length(DURS),length(CTRS));
            for i = 1:length(ORS)
                for j = 1:length(DURS)
                    timerange = [-0.1 DURS(j)/60+0.1]; %unit in frames
                    for k = 1:length(CTRS)
                        failureAnalysis.spiking{i,j,k}= unit.getRaster(sess.getStimStartTime(failureAnalysis.trials{i,j,k}),timerange);
                    end
                end
            end
            
            failureAnalysis.rasters = cell(length(ORS),length(DURS),length(CTRS));
            for i = 1:length(ORS)
                for j = 1:length(DURS)
                    timerange = [-0.1 DURS(j)/60+0.1]; %unit in frames
                    for k = 1:length(CTRS)
                        failureAnalysis.rasters{i,j,k}= Raster(failureAnalysis.trials{i,j,k},failureAnalysis.spiking{i,j,k},timerange);
                    end
                end
            end
        end
        
        function tuning = getORTuning(sess,unit)
            % need to get the data for 'gratings'
            whichStep = strcmp({sess.trialDetails.stepName},'gratings');
            
            trNum = [sess.trialDetails.trialNum];trNumThatStep = trNum(whichStep);
            tD = sess.trialDetails; sD = [tD.stimDetails];

            orientations = [sD.orientations];
            orsThatStep = orientations(whichStep);
            ORs = unique(orsThatStep);
            
            durs = [sD.maxDuration];
            dursThatStep = durs(whichStep);
            DursUniq = unique(dursThatStep);
            
            if length(DursUniq)>1
                keyboard
                error('hmm whats the issue here');
            end
            
            tuning.ors = ORs;
            tuning.trials = cell(size(ORs));
            for i = 1:length(ORs)
                whichThatOR = orsThatStep==ORs(i);
                tuning.trials{i} = trNumThatStep(whichThatOR);
            end
            
            tuning.spiking = cell(size(ORs));
            timerange = [-0.1 DursUniq/60+0.2];
            for i = 1:length(ORs)
                tuning.spiking{i} = unit.getRaster(sess.getFrameStartTime(tuning.trials{i}),timerange);
            end
            
            for i = 1:length(ORs)
                tuning.rasters(i) = Raster(tuning.trials{i},tuning.spiking{i},timerange);
                tuning.frs(i) = tuning.rasters(i).getFiringRate;
            end
            
            plotRaster = false;
            
            if plotRaster
                [xx,yy] = getGoodArrangement(length(ORs));
                figure;
                for i = 1:length(ORs)
                    ax = subplot(xx,yy,i);
                    tuning.rasters(i).plot(ax);
                    title(sprintf('%2.1f',rad2deg(ORs(i))));
                    ax.XLim = tuning.rasters(i).timerange;
                end
            end
            
            
        end
        
        function tuning = getSubsampleORTuning(sess,unit)
            % need to get the data for 'gratings'
            whichStep = strcmp({sess.trialDetails.stepName},'gratings');
            
            trNum = [sess.trialDetails.trialNum];trNumThatStep = trNum(whichStep);
            tD = sess.trialDetails; sD = [tD.stimDetails];

            orientations = [sD.orientations];
            orsThatStep = orientations(whichStep);
            ORs = unique(orsThatStep);
            
            durs = [sD.maxDuration];
            dursThatStep = durs(whichStep);
            DursUniq = unique(dursThatStep);
            
            if length(DursUniq)>1
                error('hmm whats the issue here');
            end
            
            tuning.subsamples = cell(size(trNumThatStep));
            for j = 1:length(trNumThatStep)
                fprintf('%d.',j);
                tuning.subsamples{j}.ors = ORs;
                trNumThatStepThatSubsample = setdiff(trNumThatStep,trNumThatStep(j)); % remove one trial at a time
                whichTrialsIncluded = ismember(trNumThatStep,trNumThatStepThatSubsample);
                orsThatStepThatSubsample = orsThatStep(whichTrialsIncluded);
                
                tuning.subsamples{j}.trials = cell(size(ORs));
                for i = 1:length(ORs)
                    whichThatOR = orsThatStepThatSubsample==ORs(i);
                    tuning.subsamples{j}.trials{i} = trNumThatStepThatSubsample(whichThatOR);
                end 
                
                tuning.subsamples{j}.spiking = cell(size(ORs));
                timerange = [-0.1 DursUniq/60+0.2];
                for i = 1:length(ORs)
                    tuning.subsamples{j}.spiking{i} = unit.getRaster(sess.getFrameStartTime(tuning.subsamples{j}.trials{i}),timerange);
                end
%                 tuning.subsamples{j}.rasters = cell(size(ORs));
%                 tuning.subsamples{j}.frs = cell(size(ORs));
                for i = 1:length(ORs)
                    tuning.subsamples{j}.rasters(i) = Raster(tuning.subsamples{j}.trials{i},tuning.subsamples{j}.spiking{i},timerange);
                    tuning.subsamples{j}.frs(i) = tuning.subsamples{j}.rasters(i).getFiringRate;
                end
            end
            fprintf('\n')
        end
        
        function plotORTuning(sess,unit,ax)
            if ~exist('ax','var') || isempty(ax)
                ax = axes;
            end
            tuning = sess.getORTuning(unit);
            
            axes(ax);
            ors = tuning.ors;
            m = fliplr([tuning.frs.m]);
            sem = fliplr([tuning.frs.sem]);
            p = polar(ors+pi/2,m); hold on;
            p.LineWidth = 3;
            for i = 1:length(ors)
                polar([ors(i)+pi/2 ors(i)+pi/2],[m(i)+sem(i),m(i)-sem(i)],'b');
            end
            %ax.YLim = [0 ax.YLim(2)];
            
        end
        
        function f = plotAllORTuning(sess)
            numUnits = sess.numUnits;
            params.mode = 'maxAxesPerFig';
            params.maxAxesPerFig = 30;
            [xx,yy] = getGoodArrangement(numUnits,params);
            allUnits = sess.collateUnits;
            currFig = 1;
            f = [];
            for i = 1:numUnits
                if currFig ==1
                    f(end+1) = figure;
                end
                ax = subplot(xx,yy,currFig);
                sess.plotORTuning(allUnits(i),ax);
                currFig = currFig+1;
                if currFig>params.maxAxesPerFig
                    currFig = 1;
                end
            end
        end
        
        function out = getAllORTuning(sess)
            numUnits = sess.numUnits;
            [allUnits,ident,uid] = sess.collateUnits;
            out.tuning = cell(1,numUnits);
            for i = 1:numUnits
                out.tuning{i}= sess.getORTuning(allUnits(i)); 
            end
            out.ident = ident;
            out.uid = uid;
        end
        
        function out = getStimStartTime(sess,trials)
            trialsInEventDataStim = [sess.eventData.stim.trialNumber];
            startTimeInEventDataStim = [sess.eventData.stim.stop]; %actually stop because RR fucked up hmmmm
            out = nan(size(trials));
            for i = 1:length(trials)
                startTime = startTimeInEventDataStim(trialsInEventDataStim==trials(i));
                if ~isempty(startTime)
                    out(i) = startTime;
                end
            end
        end
        
        function out = getFrameStartTime(sess,trials)
            trialsInEventDataFrame = [sess.eventData.frame.trialNumber];
            startTimeInEventDataFrame = {sess.eventData.frame.start};
            out = nan(size(trials));
            for i = 1:length(trials)
                startTime = startTimeInEventDataFrame{trialsInEventDataFrame==trials(i)};
                if ~isempty(startTime)
                    out(i) = startTime(2); % first frame is always empty
                end
            end
        end
        
        function raster = subsetTrialRasterAllUnits(sess, unitNum, range, subset)
            % subsetTrialRasterAllUnits = runs trial raster for all units of a session on a
            %                       specified subset of the trial data.
            %
            % parameters = sess: session to analyze
            %              range: range in m/s to check before/after frame onset (see
            %                     trialRaster function)
            %              subset: special string to specify subset of trials that are
            %                      going to be tested on.
            %              unitNum: unit in session where units are in order of trode
            %                       in which they are contained
            %
            
            % Current subsets implemented %%
            %
            % Orientation = takes all trials with stim length of ~100ms and creates
            %               raster for every single unit of the session. Then plots to
            %               user in subplot with orientations as rows and units as
            %               columns.
            %
            %%
            
            
            
            switch upper(subset)
                case 'ORIENTATION'
                    trialsThisSession = [sess.eventData.trials.trialNumber];
                    stimLength = [sess.eventData.stim.stop]-[sess.eventData.stim.start];
                    %gets all trials of around >300 and less than 800 ms
                    which = stimLength >0.3 & stimLength <0.8;
                    trialSubset = trialsThisSession(which);
                    
                    %further splits this new trial subset up by graphics orientation
                    stimDetailsAll = [sess.eventData.trialData.stimulusDetails];
                    orsAll = [stimDetailsAll.orientations];
                    
                    orientations = orsAll(which);
                    
                    orientations = unique(orientations); % gets all unique orientations
                    
                    oriTrials = cell(1,length(orientations));
                    for i = 1:length(orientations)  %puts each orientation's trials into its own
                        for j = 1:length(trialSubset)  %cell of cell array
                            if(sess.eventData.trialData(trialSubset(j)).stimulusDetails.orientations == orientations(i))
                                oriTrials{i} = [oriTrials{i} trialSubset(j)];
                            end
                        end
                    end
                    
                    %now run trialRaster on each unit for each orientation
                    ind = 1;
                    raster = cell(1,sess.numUnits*length(orientations));
                    for i = 1:length(sess.trodes)
                        for j = 1:length(sess.trodes(i).units)
                            for k = 1:length(oriTrials)
                                [raster{ind}] = trialRaster(sess, oriTrials{k}, sess.trodes(i).units(j), range);
                                ind = ind+1;
                            end
                        end
                    end
                    
                    %now plot out raster using plotTrialRaster function and correct
                    %figure sizes.
                    
                    allUnits = [sess.trodes.units];
                    targetUnit = allUnits(unitNum);
                    numRows = 2;
                    numColumns = ceil(length(orientations)/numRows);
                    startingInd = (unitNum-1)*length(orientations)+1;
                    rasterInd = startingInd:startingInd+length(orientations);
                    for i = 1:length(orientations)
                        subplot(numRows, numColumns, i);
                        plotTrialRaster(raster{rasterInd(i)}, orientations, i, range, sess);
                    end
                    
                    
                    
                otherwise
                    error('subset not recognized');
            end
            
            
        end
        
        function sess = zeroNoise(sess)
            for i = 1:length(sess.trodes)
                sess.trodes(i).spikeWaveForms(sess.trodes(i).spikeAssignedCluster==1,:,:) = 0;
            end
        end
        
        function [out, outsubs] = getOSI(sess,u,subsample)
            if ~exist('subsample','var')||isempty(subsample)
                subsample = false;
            end
            tuning = sess.getORTuning(u);
            out = Session.calculateOSI(tuning);
            outsubs = [];
            if subsample
                subsTuning = sess.getSubsampleORTuning(u);
                for j = 1:length(subsTuning.subsamples)
                    outsubs(j) = Session.calculateOSI(subsTuning.subsamples{j});
                end
            end
        end
        
        function out = getAllOSI(sess)
            numUnits = sess.numUnits;
            [allUnits, ident,uid] = sess.collateUnits;
            out.OSI = nan(1,numUnits);
            out.ident = ident;
            out.uid = uid;
            for i = 1:numUnits
                out.OSI(i) = sess.getOSI(allUnits(i));
            end
        end
        
        function out = getAllOSIWithJackKnife(sess)
            numUnits = sess.numUnits;
            [allUnits, ident,uid] = sess.collateUnits;
            out.OSI = nan(1,numUnits);
            out.OSISubsample = cell(1,numUnits);
            out.ident = ident;
            out.uid = uid;
            for i = 1:numUnits
                fprintf('%d/%d::',i,numUnits);
                subsample = true;
                [out.OSI(i), out.OSISubsample{i}] = sess.getOSI(allUnits(i),subsample);
            end
        end
        
        function [out, outsubs] = getOrVector(sess,u,subsample)
            if ~exist('subsample','var')||isempty(subsample)
                subsample = false;
            end
            tuning = sess.getORTuning(u);
            ors = pi/2-tuning.ors;
            m = [tuning.frs.m];
            [out.str, out.ang] = sess.getVectorSum(ors,m);
            outsubs = [];
            if subsample
                subsTuning = sess.getSubsampleORTuning(u); 
                for j = 1:length(subsTuning.subsamples)
                    ors = pi/2-subsTuning.subsamples{j}.ors;
                    m = [subsTuning.subsamples{j}.frs.m];
                    [outsubs(j).str, outsubs(j).ang] = Session.getVectorSum(ors,m);
                end
            end
        end
        
        function out = getAllOrVectors(sess)
            numUnits = sess.numUnits;
            [allUnits, ident,uid] = sess.collateUnits;
            out.ident = ident;
            out.uid = uid;
            out.vectors(numUnits) = [];
            for i = 1:numUnits
                out.vectors(i) = sess.getOrVector(allUnits(i));
            end
        end
        
        function out = getAllOrVectorsWithJackKnife(sess)
            numUnits = sess.numUnits;
            [allUnits, ident,uid] = sess.collateUnits;
            out.vectors = cell(1,numUnits);
            out.vectorsJackKnife = cell(1,numUnits);
            out.ident = ident;
            out.uid = uid;
            for i = 1:numUnits
                fprintf('%d/%d::',i,numUnits);
                subsample = true;
                [out.vectors{i}, out.vectorsJackKnife{i}]= sess.getOrVector(allUnits(i),subsample);
            end
        end
        
        
        % units
        function spikeShapeCorr(sess)
            numUnits = sess.numUnits;
            allUnits = sess.collateUnits;
            corrs = nan(numUnits,numUnits);
            for i = 1:numUnits
                disp(i);pause(1)
                for j = i+1:numUnits
                    wf1 = allUnits(i).getFlatWaveForm;
                    wf2 = allUnits(j).getFlatWaveForm;
                    try
                        r = corrcoef(wf1,wf2);
                    catch ex
                        switch ex.identifier
                            case 'MATLAB:corrcoef:XYmismatch'
                                % happens when we have different number of
                                % channels in each trode
                                
                                % pass
                            otherwise
                                keyboard
                        end
                    end
                    corrs(i,j) = r(1,2);
                end
            end
            
            figure;
            imagesc(corrs);
            axis equal;
            colormap grey;
            colorbar
        end
        
        % getAllFiringRates
        function fr = getAllFiringRates(sess)
            [allUnits, ident, uid] = sess.collateUnits;
            fr.ident = ident;
            fr.uid = uid;
            fr.firingRates(sess.numUnits) = nan;
            for i = 1:length(allUnits)
                fr.firingRates(i) = allUnits(i).firingRate;
            end
        end
        
        function sw = spikeWidths(sess)
            [allUnits,ident,uid]= sess.collateUnits;
            
            sw.sw(sess.numUnits) = nan;
            sw.ident = ident;
            sw.uid = uid;
            for i = 1:sess.numUnits
                sw.sw(i) = allUnits(i).spikeWidth;
            end
        end
        
        function out = calcXcorrs(sess)
            
            allUnits = sess.collateUnits;
            numUnits = sess.numUnits;
            out.xcorrs = nan(numUnits,numUnits,501);
            out.shuffM = nan(numUnits,numUnits,501);
            out.shuffS = nan(numUnits,numUnits,501);
            out.sigs = false(numUnits,numUnits);
            totalCrossCorrs = sess.numUnits*sess.numUnits/2;
            h = waitbar(0,sprintf('CrossCorr 0 of %d',totalCrossCorrs));
            k = 0;
            for i = 1:sess.numUnits
                for j = i+1:sess.numUnits
                    [xCorr,shuffM,shuffS,~,sig] = allUnits(i).xcorr(allUnits(j));
                    out.xcorrs(i,j,:) = xCorr;
                    out.shuffM(i,j,:) = shuffM;
                    out.shuffS(i,j,:) = shuffS;
                    out.sigs(i,j) = sig;
                    k = k+1;
                    waitbar(min(k,totalCrossCorrs)/totalCrossCorrs,h,sprintf('CrossCorr %d of %d',k,totalCrossCorrs));
                end
            end
            close(h);
        end
        
        function out = getSpikeCorrelation(sess,resolution)% resolution in ms
            allUnits = sess.collateUnits;
            out = nan(sess.numUnits,sess.numUnits);
            for i = 1:sess.numUnits
                for j = i+1:sess.numUnits
                    r = allUnits(i).calcCorr(allUnits(j),resolution);
                    out(i,j) = r(1,2);
                end
            end
        end
        
        function out = getCovariance(sess,dT)
            
            
        end
        
        function out = getSpikeAndStimDetails(sess,interval)
            if ~exist('interval','var')||isempty(interval)
                interval = 0.1;
            end
            trNums = [];
            nominalStimDurations = [];
            actualStimDurations = [];
            contrasts = [];
            orientations = [];
            
            spikeNumsNominal = [];
            spikeNumsActual = [];
            
            spikeRatesNominal = [];
            spikeRatesActual = [];
            
            timeToFirstSpike = [];            
            
            [units,ident,uid] = sess.collateUnits();
            
            %check if it has gratings_LED
            tD = sess.trialDetails;
            temp = {tD.stepName};
            whichEmpty = find(cellfun(@isempty, temp));
            for i = 1:length(whichEmpty)
                temp{whichEmpty(i)} = 'none';
            end
            
            hasGratingsLED = ismember('gratings_LED',unique(temp));
            if hasGratingsLED
                stepNameToLookFor = 'gratings_LED';
            else
                stepNameToLookFor = 'gratings';
            end
            
            % loop through the trials
            for i = sess.minTrialNum:sess.maxTrialNum
                % look for the stepName
                which = [tD.trialNum]==i;
                dets = tD(which);
                if isempty(dets) || ~strcmp(dets.stepName,stepNameToLookFor)
                    continue;
                end
                
                trNums = [trNums;i];
                
                whichTrialInFrame = [sess.eventData.frame.trialNumber]==i;
                frameRecord = sess.eventData.frame(whichTrialInFrame);
                
                if length(frameRecord) ~=1 || isempty(frameRecord.start)
                    nominalStimDurations = [nominalStimDurations;NaN];
                    actualStimDurations = [actualStimDurations;NaN];
                    contrasts = [contrasts;NaN];
                    orientations = [orientations;NaN];
                    spikeNumsNominal = [spikeNumsNominal;nan(1,sess.numUnits)];
                    spikeNumsActual = [spikeNumsActual;nan(1,sess.numUnits)];
%                     spikeRatesNominal = [spikeRatesNominal;nan(1,sess.numUnits)];
%                     spikeRatesActual = [spikeRatesActual;nan(1,sess.numUnits)];
                    timeToFirstSpike = [timeToFirstSpike;nan(1,sess.numUnits)];
                    fprintf('issue with trial:%d\n',i);
                    continue
                end
                
                nominalStimDurations = [nominalStimDurations; dets.stimDetails.maxDuration];
                actualStimDurations = [actualStimDurations;frameRecord.start(end)-frameRecord.start(2)];
                contrasts = [contrasts;dets.stimDetails.contrasts];
                orientations = [orientations;dets.stimDetails.orientations];
                
                stimStartTime = frameRecord.start(2);
                windowNominal = [0 (dets.stimDetails.maxDuration/60)+interval];
                windowActual = [0 frameRecord.start(end)-frameRecord.start(2)+interval]; % adding 100 ms to stimulus
                
                unitSpikesNominal = cell(1,sess.numUnits);
                unitSpikesActual = cell(1,sess.numUnits);
                timeToFirstSpikeThisTrial = nan(1,sess.numUnits);
                for j = 1:sess.numUnits
                    unitSpikesNominal(j) = units(j).getRaster(stimStartTime,windowNominal);
                    unitSpikesActual(j) = units(j).getRaster(stimStartTime,windowActual);
                    timeToFirstSpikeThisTrial(j) = units(j).timeToFirstSpike(stimStartTime);
                end
                spikeNumsNominal = [spikeNumsNominal; cellfun(@length,unitSpikesNominal)];
                spikeNumsActual = [spikeNumsActual; cellfun(@length,unitSpikesActual)];    
                
                timeToFirstSpike = [timeToFirstSpike;timeToFirstSpikeThisTrial];
            end
%             try
                spikeRatesNominal = spikeNumsNominal./repmat(nominalStimDurations/60,1,sess.numUnits);
                spikeRatesActual = spikeNumsActual./repmat(actualStimDurations,1,sess.numUnits);
% %             catch
% %                 keyboard
% %             end
            out.trNums = trNums;
            out.nominalStimDurations = nominalStimDurations;
            out.actualStimDurations = actualStimDurations;
            out.contrasts = contrasts;
            out.orientations = orientations;
            out.spikeNumsNominal = spikeNumsNominal;
            out.spikeNumsActual = spikeNumsActual;
            out.spikeRatesNominal = spikeRatesNominal;
            out.spikeRatesActual = spikeRatesActual;
            out.timeToFirstSpike = timeToFirstSpike;
            out.uid = uid;
%              keyboard
        end
        
        function out = getFeature(sess,feature)
            switch feature
                case 'FiringRate'
                    out = sess.getAllFiringRates();
                case 'Waveforms'
                    out = sess.getAllWaveforms();
                case 'ISIs'
                    out = sess.getAllISIs();
                case 'FWAt0s'
                    out = sess.getAllFWAtZeros();
                case 'FWHMs'
                    out = sess.getAllFWHMs();
                case 'PeakToTroughs'
                    out = sess.getAllPeakToTroughs();
                case 'NumChans'
                    out = sess.getAllNumChans();
                case 'OSIs'
                    out = sess.getAllOSI();
                case 'OSIsWithJackKnife'
                    out = sess.getAllOSIWithJackKnife();
                case 'OrientedVectorWithJackKnife'
                    out = sess.getAllOrVectorsWithJackKnife();
                case 'SpikeAndStimDetails'
                    out = sess.getSpikeAndStimDetails();
                case 'SpikeAndStimDetails0'
                    out = sess.getSpikeAndStimDetails(0);
                case 'SpikeAndStimDetails50'
                    out = sess.getSpikeAndStimDetails(0.05);
                case 'SpikeAndStimDetails100'
                    out = sess.getSpikeAndStimDetails(0.1);
                case 'SpikeAndStimDetails200'
                    out = sess.getSpikeAndStimDetails(0.2);
                case 'SpikeAndStimDetails500'
                    out = sess.getSpikeAndStimDetails(0.5);
                case 'SpikeAndStimDetails1000'
                    out = sess.getSpikeAndStimDetails(1);
                case 'SpikeQualityMahal'
                    out = sess.getAllSpikeQualitiesMahal();
                case 'SpikeQualityISI'
                    out = sess.getAllSpikeQualitiesISI();
            end
        end
    end
    
    methods % methods for spike quality metrics
        
        function out = getAllSpikeQualitiesMahal(sess)
            out.uID = {};
            out.quality = [];
            out.contaminationRate =[];
            % number of trodes
            for i = 1:length(sess.trodes)
                swAll = [];
                spikeID = [];
                % lets get the waveforms together
                sWExtra = sess.trodes(i).spikeWaveForms;
                numChans = length(sess.trodes(i).chans);
                if numChans>1
                    sWExtra = reshape(sWExtra,size(sWExtra,1),size(sWExtra,2)*size(sWExtra,3));
                end
                numSpikes = size(sWExtra,1);
                swAll = [swAll;sWExtra];
                spikeID = [spikeID;zeros(numSpikes,1)];
                for j = 1:length(sess.trodes(i).units)
                    thatUnitSpikeWaveform = sess.trodes(i).units(j).waveform;
                    if numChans>1
                        thatUnitSpikeWaveform = reshape(thatUnitSpikeWaveform,...
                            size(thatUnitSpikeWaveform,1),size(thatUnitSpikeWaveform,2)*size(thatUnitSpikeWaveform,3));
                    end
                    numSpikes = size(thatUnitSpikeWaveform,1);
                    swAll = [swAll;thatUnitSpikeWaveform];
                    spikeID = [spikeID;j*ones(numSpikes,1)];
                end
                
%                 keyboard
                for j = 1:length(sess.trodes(i).units)
                    disp(j);
                    % make a version that makes for only that unit 
                    which = spikeID==j;
                    [q,r] = Session.mahalQualityCore(swAll(which,:),swAll(~which,:));
                    out.uID{end+1} = sprintf('t%du%d',i,j);
                    out.quality(end+1) = q;
                    out.contaminationRate(end+1) = r;
                end
            end
        end

    end
    
    
    methods % Manipulating the history
        
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
    
    methods % sanity checks
        function summarizeTrialDetails(sess)
            if isempty(sess.trialDetails)
                fprintf('DETAILS UNAVAILABLE...EXITING\n')
                return
            end
            
            fprintf('NUM TRIALS: %d\n',sess.numTrials);
            fprintf('MIN TRIAL NUM: %d\n',sess.minTrialNum);
            fprintf('MAX TRIAL NUM: %d\n\n',sess.maxTrialNum);
            
            tD = sess.trialDetails; 
            
            fprintf('AVAILABLE STIM CLASSES\n');
            fprintf('----------------------\n');
            stimClass = {tD.stimManagerClass};
            stimClass = stimClass(~cellfun(@isempty,stimClass));
            availClasses = unique(stimClass);
            for i = 1:length(availClasses)
                fprintf('%s\n',availClasses{i});
            end
            
            fprintf('\nAVAILABLE STEPS\n');
            fprintf('---------------\n');
            stepNames = {tD.stepName};
            stepNames = stepNames(~cellfun(@isempty,stepNames));
            availSteps = unique(stepNames);
            for i = 1:length(availSteps)
                which = ismember(stepNames,availSteps{i});
                fprintf('\n%s : %d trials\n',availSteps{i},sum(which));
                
                % find the things that got varied in these trials
                sDThis = [tD(which).stimDetails];
                
                % loop through stuff
                variedPPC = length(unique([sDThis.pixPerCycs]))>1;
                variedFreq = length(unique([sDThis.driftfrequencies]))>1;
                variedCtr = length(unique([sDThis.contrasts]))>1;
                variedOr = length(unique([sDThis.orientations]))>2;
                variedDur = length(unique([sDThis.maxDuration]))>1;
                
                variedStuff = {'ppc','freq','ctr','or','dur'};
                variedHere = variedStuff([variedPPC,variedFreq,variedCtr,variedOr,variedDur]);
                fprintf('Varied: ');
                for j = 1:length(variedHere)
                    fprintf('%s ',variedHere{j});
                    if j ~=length(variedHere)
                        fprintf('X ');
                    else
                        fprintf('\n');
                    end
                end
                
                % now make some statements about the number of trials
                switch availSteps{i}
                    case 'gratings'
                        ORs = unique([sDThis.orientations]);
                        numOrs = length(ORs);
                        fprintf('Number of Orientations: %d\n',numOrs);
                        for j = 1:numOrs
                            numTrialsThatOR = sum([sDThis.orientations]==ORs(j));
                            fprintf('%2.0f : %d trials\n',rad2deg(ORs(j)),numTrialsThatOR);
                        end
                        
                    case 'gratings_LED'
                        ors = [sDThis.orientations];ORs = unique(ors);
                        ctrs = [sDThis.contrasts];Ctrs = unique(ctrs);
                        durs = [sDThis.maxDuration]; Durs = unique(durs);
                        
                        fprintf('FOR LEFT OR\n');
                        numTrialsLeft = nan(length(Ctrs),length(Durs));
                        fprintf('CONTRASTS');disp(Ctrs);
                        fprintf('DURATIONS');disp(Durs/60); % assuming 60Hz
                        
                        for j = 1:length(Ctrs)
                            for k = 1:length(Durs)
                                numTrialsLeft(j,k) = sum(ors==min(ors) & ctrs==Ctrs(j) & durs==Durs(k));
                            end
                        end
                        disp(numTrialsLeft);
                        
                        fprintf('FOR RIGHT OR\n');
                        numTrialsRight = nan(length(Ctrs),length(Durs));
                        fprintf('CONTRASTS');disp(Ctrs);
                        fprintf('DURATIONS');disp(Durs/60); % assuming 60Hz
                        
                        for j = 1:length(Ctrs)
                            for k = 1:length(Durs)
                                numTrialsRight(j,k) = sum(ors==max(ors) & ctrs==Ctrs(j) & durs==Durs(k));
                            end
                        end
                        disp(numTrialsRight);
                        
                    otherwise
                        keyboard
                end
                
            end
            
            
            
        end
        function verifyAllTrialsHaveStimEvents(sess)
            %trialsInDetails = [sess.trialDetails.trialNum];
            trialsInEventDataTrials = [sess.eventData.trials.trialNumber];
            trialsInEventDataStim = [sess.eventData.stim.trialNumber];
            diffTr = setdiff(trialsInEventDataTrials,trialsInEventDataStim);
            if isempty(diffTr) || length(diffTr)==1
                fprintf('Seems OK\n');
            else
                fprintf('Found an issue\n');
            end
        end
    end
    
    methods(Static)
        
        function [str,ang] = getVectorSum(ors,m)
            % check if replicated data exists
            if all(ismember([pi,0],ors))
                which1 = ors==pi;
                which2 = ors==0;
                m(which2) = mean([m(which1) m(which2)]);
                m(which1) = [];
                ors(which1) = []; 
            end            
            if isempty(m) || all(m==0)
                str = nan;
                ang = nan;
                return
            end
            try
                % replicate
                %ORS = [ors+pi ors];
                %M = [m m];
                ORS = 2*ors;
                M = m;
                M = M/max(m);
                
                vecs = M.*exp(sqrt(-1)*ORS);
                summedVec = sum(vecs);
                str = abs(summedVec);
                ang = angle(summedVec)/2;
            catch ex
                keyboard
            end
        end
        
        function checkOrientationTuningModel(f,f0,tMax,dt,ax,col)
            theta = 0:pi/8:pi;
            fr = f0+f*exp(-((theta-tMax)/dt).^2);
            if ~exist('ax','var')
                ax = axes;
            else
                axes(ax);
            end
            pol = polar(theta,fr);
            pol.Color = [0.5 0.5 0.5]; hold on;
%             ax.YLim = [0 ax.YLim(2)];
            [str,ang] = Session.getVectorSum(theta,fr);
            
            if ~exist('col','var')
                col = 'r';
            end            
            polar([ang ang],[0 str],col);
        end
        
        function compareOrientationTuningModel()
            
            f = 10; f0 = 0; tMax = pi/4; dt = pi/6;ax = axes;
            Session.checkOrientationTuningModel(f,f0,tMax,dt,ax,'r');
            
            f = 10; f0 = 0; tMax = pi/2; dt = 2*pi;
            Session.checkOrientationTuningModel(f,f0,tMax,dt,ax,'b');
        end
        
        function osi = calculateOSI(tuning)
            ors = pi/2-tuning.ors; % bacuse 0 is vertical and pi/2 is right horizontal
            m = [tuning.frs.m];
            which1 = abs(ors-pi)<pi/100; % arbitrary amount!
            which2 = abs(ors-0)<pi/100; % arbitrary amount xxx
            m(which2) = mean([m(which1) m(which2)]);
            m(which1) = [];
            ors(which1) = [];
            if isempty(m) || all(m==0)
                osi = nan;
                return
            end
            try
                % replicate
                ORS = [ors+pi ors];
                M = [m m];
                
                % get the OSI of this transformed data
                % get the max of m and corr OR
                whichMax = m==max(m);
                if length(find(whichMax))>1
                    temp = find(whichMax);
                    whichMax(temp(2:end)) = 0;
                end
                maxm = max(m);
                orForMax = ors(whichMax);
                orForOrth = orForMax+pi/2;
                
                whichOrth = abs(ORS-orForOrth)<pi/20;
                orthm = M(whichOrth);
                
                osi = (maxm-orthm)/(maxm+orthm);
            catch ex
                getReport(ex)
                keyboard
            end
        end
        
        function [unitQuality, contaminationRate] = mahalQualityCore(fetThisCluster, fetOtherClusters)
            % fetThisCluster and fetOtherClusters are size [nSpikes, nFeatures]
            
            
            n = size(fetThisCluster,1);
            nOther = size(fetOtherClusters,1);
            nFet = size(fetThisCluster,2);
            
            if nOther > n && n>nFet
                % Mahalanobis distance of each of the spikes from present cluster,
                % using only the best fetN dimensions:
                md = mahal(fetOtherClusters, fetThisCluster);
                md = sort(md);
                
                mdSelf = mahal(fetThisCluster, fetThisCluster);
                mdSelf = sort(mdSelf);
                
                unitQuality = md(n);
                contaminationRate = 1-Session.tippingPoint(mdSelf, md)/numel(mdSelf);
            else
                unitQuality = 0;
                contaminationRate = NaN;
            end
            
        end
        
        function pos = tippingPoint(x,y)
            % Input: x, y  are sorted ascending arrays of positive numbers
            % Output: minimal pos s.t. sum(x > x(pos)) <= sum(y < x(pos))
            
            % algorithm here is to sort x and y together, and determine the indices of
            % x in this sorted list (call this xInds). Then, xInds-(1:length(xInds))
            % will be the number of y's that are less than that value of x.
            
            nX = numel(x);
            [~, inds] = sort([x;y]);
            [~, inds] = sort(inds);
            xInds = inds(1:nX);
            
            pos = find(nX:-1:1 < xInds'-(1:nX), 1)-1;
            
            if isempty(pos)
                % not a single "other" spike was nearer the cluster than the furthest
                % in-cluster spike
                pos = nX; % will give contaminationRate = 0;
            end
            
        end
    end
end