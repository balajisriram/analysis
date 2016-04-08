classdef eventData
    % 
    % out format: (phys) 
    % mapped to channels on hardware:
    %   channel 0: trial start/stop
    %   channel 1: frames onset
    %   channel 2: stim onset
    %   channel 7: LED ?
    %
    % out format: (behavior)
    % mapped to channels on hardware:
    %   channel 0 = stim
    %   channel 3 = right lick (inverted)
    %   channel 4 = frames (inverted)
    %   channel 6 = center lick (inverted)
    %
    % has following fields:
    %   channelNum = channel this index is mapped to
    %   eventTimes = time which event occurs
    %   eventID = 1 for rising edge 0 for falling edge
    %   eventType = 3 for TTL, 5 for network
    %   sampNum = index of start time
    %
    %
    
    properties
        eventFolder
        
        trials
        stim
        frame
        LED1
        LED2
        LickL
        LickC
        LickR
        RewL
        RewC
        RewR
        trialData
        
        messages
        specialCases
        out
    end
    
    properties (Constant=true)
        portAssociations = ...
            {1,'';...
            2,'';...
            3,'';...
            4,'';...
            5,'';...
            6,'';...
            7,'';...
            8,'';...
            };
    end
    
    methods
        function e = eventData(foldername, mappings)
            assert(isdir(foldername),'events folder unavailable');
            e.eventFolder = foldername;
            
            e = e.openMessages(fullfile(e.eventFolder,'messages.events')); %reads messages.events text file
            e = e.getChannelEvents();         %builds e.out from openEphys .event method
            e = e.getTrialEvents(mappings);   %gets info from e.out section
            e = e.getTrialInfo();             %gets info from stim folder
            %e = e.getOtherMessages(); currently unused
        end
        
            
    end
    
    methods
        
        %gets trial eventData
        function e = getTrialData(e, ind)
            trialsEventInd = (e.out(ind).eventType==3); %only want TTL trials
            trialsRisingInd = (e.out(ind).eventID==1);     
            
            trialsStart = e.out(ind).eventTimes(trialsEventInd & trialsRisingInd);
            trialsStop = e.out(ind).eventTimes(trialsEventInd & ~trialsRisingInd);
            
%             if (length(trialsStart)*2)>length(e.messages) %if we dont have data for last trial
%                 trialsStart(end) = [];
%             end

            %if last trial does not have an end in messages
            if (length(trialsStart) ~= length(trialsStop) || ((length(trialsStart)*2)>length(e.messages)))
                for i = 1:length(trialsStart)-1
                    e.trials(i).trialNumber = e.messages(i*2).trial;
                    e.trials(i).start = trialsStart(i);
                    e.trials(i).stop = trialsStop(i);
                end
                lastInd = length(trialsStart);  %special case for that trial
                e.trials(lastInd).trialNumber = e.messages(end).trial;
                e.trials(lastInd).start = trialsStart(lastInd);
                e.trials(lastInd).stop = NaN;  %set end to NaN
            else
                for i = 1:length(trialsStart) % normal case
                    e.trials(i).trialNumber = e.messages(i*2).trial;
                    e.trials(i).start = trialsStart(i);
                    e.trials(i).stop = trialsStop(i);
                end
            end
        end
        
        %gets frame event data
        function e = getFrameData(e, ind)
           for i = 1:2:length(e.messages)
               minTime = e.messages(i).index/30000; % ## hard coded samp rate
               if i == length(e.messages)           %if no end in messages
                   frameRisingInd = (e.out(ind).eventID == 1);
                   frameTimeInd = ((e.out(ind).eventTimes >= minTime));

                   index = ceil(i/2);
                   e.frame(index).trialNumber = e.messages(i).trial;
                   e.frame(index).start = e.out(ind).eventTimes(frameRisingInd & frameTimeInd);
               else
                   maxTime = e.messages(i+1).index/30000; % ## hard coded samp rate
                   frameRisingInd = (e.out(ind).eventID == 1);
                   frameTimeInd = ((e.out(ind).eventTimes >= minTime) & (e.out(ind).eventTimes <= maxTime));

                   index = ceil(i/2);
                   e.frame(index).trialNumber = e.messages(i).trial;
                   e.frame(index).start = e.out(ind).eventTimes(frameRisingInd & frameTimeInd);
               end
            end
        end
        
        %gets stim event data
        function e = getStimData(e, ind)
            stimRisingInd = (e.out(ind).eventID == 1);
            
            stimStart = e.out(ind).eventTimes(stimRisingInd);
            stimStop = e.out(ind).eventTimes(~stimRisingInd);

            for i = 1:length(stimStart)
                e.stim(i).trialNumber = e.messages(i*2-1).trial;
                e.stim(i).start = stimStart(i);
                e.stim(i).stop = stimStop(i);
            end
        end
        
        
        %gets led data
        function e = getLEDData(e, ind)
            ledRisingInd = e.out(ind).eventID == 1;
            
            ledRisingTimes = e.out(ind).eventTimes(ledRisingInd);
            ledFallingTimes = e.out(ind).eventTimes(~ledRisingInd);
            
            for i = 1:length(ledRisingTimes)
                e.LED1(i).trialNumber = eventData.getTrialByTime(e.messages, ledRisingTimes(i));
                e.LED1(i).start = ledRisingTimes(i);
                e.LED1(i).stop = ledFallingTimes(i);
            end
        end
        
        %gets data for center licks
        function e = getCenterLickData(e, ind)
            lickRisingInd = (e.out(ind).eventID == 1);
            
            lickOn = e.out(ind).eventTimes(lickRisingInd);
            lickOff = e.out(ind).eventTimes(~lickRisingInd);
            
            for i = 1:length(lickOn)
                e.LickC(i).trialNumber = eventData.getTrialByTime(e.messages, lickOn(i));
                e.LickC(i).start = lickOn(i);
                e.LickC(i).stop = lickOff(i);
            end
        end
        
        %gets data for right licks
        function e = getRightLickData(e, ind)
            lickRisingInd = (e.out(ind).eventID == 1);
            
            lickOn = e.out(ind).eventTimes(lickRisingInd);
            lickOff = e.out(ind).eventTimes(~lickRisingInd);
            
            for i = 1:length(lickOn)
                e.LickR(i).trialNumber = eventData.getTrialByTime(e.messages, lickOn(i));
                e.LickR(i).start = lickOn(i);
                e.LickR(i).stop = lickOff(i);
            end
        end
        
        
        % uses provided OpenEphys method to get event data from
        % all_channels.events file.
        function e = getChannelEvents(e)
                      
            %opens event file, gets info
            [eventTimes, eventID, eventChannel, eventType, sampNum] = eventData.openEvents(fullfile(e.eventFolder,'all_channels.events'));
            
            whichChans = unique(eventChannel);
            
            for i = 1:length(whichChans)
                % find events for that channel
                eventsThatChannel = eventChannel==whichChans(i);
                eventTimesThatChannel = eventTimes(eventsThatChannel);
                eventIDThatChannel = eventID(eventsThatChannel);
                eventTypeThatChannel = eventType(eventsThatChannel);
                sampNumThatChannel = sampNum(eventsThatChannel);
                
                % IMPORTANT CHOOSE UNIQUE ONLY AFTER SELECTING ON CHANNEL
                [eventTimesThatChannelUniq, ia] = unique(eventTimesThatChannel);
                eventIDThatChannelUniq = eventIDThatChannel(ia);
                eventTypeThatChannelUniq = eventTypeThatChannel(ia);
                sampNumThatChannelUniq = sampNumThatChannel(ia);
                
                %stores data in e.out field
                e.out(i).channelNum = whichChans(i);
                e.out(i).eventTimes = eventTimesThatChannelUniq;
                e.out(i).eventID = eventIDThatChannelUniq;
                e.out(i).eventType = eventTypeThatChannelUniq;
                e.out(i).sampNum = sampNumThatChannelUniq;
            end
        end

        % Extracts trial data from out for easier access and cleaner
        % organization. Uses mappings to decide how to map channels to
        % corresponding events
        function e = getTrialEvents(e, mappings)
            if strcmpi(mappings,'PHYS')  %maps to physiology channel setup
                for i = 1:length(e.out)
                    switch e.out(i).channelNum
                        case 0 
                            e = e.getTrialData(i);
                            e.out(i).eventMapping = 'Trial';
                        case 1 
                            e = e.getFrameData(i);
                            e.out(i).eventMapping = 'Frame';
                        case 2 
                            e = e.getStimData(i);
                            e.out(i).eventMapping = 'Stim';
                        case 7  
                            e = e.getLEDData(i);
                            e.out(i).eventMapping = 'LED';
                        otherwise %otherwise do nothing
                            continue;
                    end
                end
            elseif strcmpi(mappings,'BEHAVIOR') %maps to behavior channel setup
                for i = 1:length(e.out)
                    switch e.out(i).channelNum
                        case 0
                            e = e.getStimData(i);
                            e.out(i).eventMapping = 'Stim';
                        case 3
                            e = e.getRightLickData(i);
                            e.out(i).eventMapping = 'Right Lick';
                        case 4
                            e = e.getFrameData(i);
                            e.out(i).eventMapping = 'Frame';
                        case 6
                            e = e.getCenterLickData(i);
                            e.out(i).eventMapping = 'Center Lick';
                        otherwise
                            continue;
                    end
                end
            end
        end
        
        % Grabs trialInfo from stim records stored in data folder
        function e = getTrialInfo(e)
            fPath = [e.eventFolder,'\stimRecords\stim*'];
            files = dir(fPath);
            for i = 1:length(files)
                load([e.eventFolder,'\stimRecords\',files(i).name]);
                e.trialData(trialNum).trialNum = trialNum;
                e.trialData(trialNum).refreshRate = refreshRate;
                e.trialData(trialNum).stepName = stepName;
                e.trialData(trialNum).stimManagerClass = stimManagerClass;
                e.trialData(trialNum).stimulusDetails = stimulusDetails;
            end
        end
        
        % Opens messages.events text file to extract trial start/end data
        % from it.
        % Assumes a strict structure of messages text file:
        %   TrialStart::TrialNumber    (TrialStart is constant, TrialNumber
        %                               is whatever trial number currently
        %                               is)
        %   TrialEnd
        %
        % Messages files goes back and forth from a TrialStart line to a
        % TrialEnd line. 
        function e = openMessages(e, filename)
            fid = fopen(filename);
            tline = fgets(fid);
            trial = 1;
            k = 1;
            while isempty(strfind(tline,'TrialStart')) %go to first line containing trialStart
                tline = fgets(fid);
            end
            while ischar(tline)  %while not the end of file
                index = str2num(tline(1:strfind(tline,' ')-1));
                if isempty(strfind(tline,'TrialEnd')) % if is trial start
                    ind = strfind(tline,'::');
                    i=2;
                    while str2num(tline(ind+i)) >= 0 %gets number of digits in trial number
                        i = i + 1;
                    end
                    trial = str2num(tline(ind+2:ind+i-1));
                    e.messages(k).index = index;
                    e.messages(k).status = 1;
                    e.messages(k).trial = trial;
                else % else is trial end
                    e.messages(k).index = index;
                    e.messages(k).status = 0;
                    e.messages(k).trial = trial;
                end
                k = k+1;
                tline = fgets(fid);
            end
        end
        
        function e = getOtherMessages(e)
        end
    end
    
    methods(Static)
        
        %uses messages file to get return which trial corresponds to a
        %given time
        function trial = getTrialByTime(messages, time)
            if time < messages(1).index/30000 % ## samp rate hard coded
                trial = 0;
                return;
            end
            for i = 1:length(messages)
                trialTime = messages(i).index/30000; % ## samp rate hard coded
                if trialTime >= time
                    trial = messages(i-1).trial;
                    return
                end
            end
        end
        
        % DEPRECATED: used to use this before when messages file were saved
        % incorrectly. openMessages(filename) method now replaces.
        function [messages, specialCase] = openMessagesOld(filename)
            fid = fopen(filename);
            tline = fgets(fid);
            k=1;
            lastStatus = 0;
            lastTrial = 'unknown';
            while ischar(tline)
                spaceInd = strfind(tline, ' ');
                colonInd = strfind(tline,'::');

                index = str2num(tline(1:spaceInd-1));
                if strcmp(tline(spaceInd+1:spaceInd+5),'Trial')
                    if ~isempty(strfind(tline, 'TrialStart'))  %trial start
                        status = 1;
                        i=2;
                        while str2num(tline(colonInd+i)) >= 0
                            i = i + 1;
                        end
                        trial = str2num(tline(colonInd+2:colonInd+i-1));
                        lastTrial = trial;
                        if lastStatus == status
                            tline = fgets(fid);
                        else
                            messages(k).index = index;
                            messages(k).status = status;
                            messages(k).trial = trial;

                            k = k+1;
                            lastStatus = status;
                            tline = fgets(fid);
                            tline = fgets(fid);
                        end   
                    else  %trial end
                        status = 0;
                        trial = lastTrial;
                        if lastStatus == status
                            tline = fgets(fid);
                        else
                            messages(k).index = index;
                            messages(k).status = status;
                            messages(k).trial = trial;

                            k = k+1;
                            lastStatus = status;
                            tline = fgets(fid);
                            tline = fgets(fid);
                        end   
                    end
                else
                    tline = fgets(fid);
                end
            end
            
            specialCase = [];
            if isempty(messages)
                return
            end
            for i = 1:2:length(messages)-4
                currTrial = messages(i).trial;
                nextTrial = messages(i+2).trial;
                nextNextTrial = messages(i+4).trial;
                if (nextTrial - currTrial) ~= 1
                    if (nextNextTrial - currTrial) ~= 2
                        specialCase = [specialCase i];
                    else
                        messages(i+2).trial = currTrial+1;
                        messages(i+3).trial = currTrial+1;
                    end
                end
            end
        end
        
        % OpenEphys provided openEvents method
        function [timestamps eventID eventChannel eventType sampleNum] = openEvents(filename)
            % [uint8 int64 uint8 uint8 uint8] = openEvents(String)
            %  Modified version of OpenEphys's 'load_open_ephys_data' function to store
            %  data in more convenient form for processing.
            %
            %  PARAMETERS:
            %    filename = string path to events file
            %
            %  RETURN VALUES: (as defined on https://open-ephys.atlassian.net/wiki/display/OEW/Data+format)
            %    eventType = all the events that are saved have type TTL = 3 ; Network Event = 5
            %    timestamps = to align with timestamps from the continuous records
            %    processorID = the processor this event originated from
            %    eventID = code associated with this event, 1 for rising edge, 0 for falling edge
            %    eventChannel = the channel this event is associated with
            %
            % link also helps in understanding the format of the EVENT files.
            %  https://groups.google.com/forum/#!topic/open-ephys/ndfHlYxN2dE
            
            filetype = filename(max(strfind(filename,'.'))+1:end); % parse filetype
            
            fid = fopen(filename);
            filesize = eventData.getfilesize(fid);
            
            % constants
            NUM_HEADER_BYTES = 1024;
            SAMPLES_PER_RECORD = 1024;
            RECORD_SIZE = 8 + 16 + SAMPLES_PER_RECORD*2 + 10; % size of each continuous record in bytes
            RECORD_MARKER = [0 1 2 3 4 5 6 7 8 255]';
            RECORD_MARKER_V0 = [0 0 0 0 0 0 0 0 0 255]';
            
            % constants for pre-allocating matrices:
            MAX_NUMBER_OF_SPIKES = 1e6;
            MAX_NUMBER_OF_RECORDS = 1e6;
            MAX_NUMBER_OF_CONTINUOUS_SAMPLES = 1e8;
            MAX_NUMBER_OF_EVENTS = 1e6;
            SPIKE_PREALLOC_INTERVAL = 1e6;
            
            %-----------------------------------------------------------------------
            %------------------------- EVENT DATA ----------------------------------
            %-----------------------------------------------------------------------
            
            if strcmp(filetype, 'events')
                
                disp(['Loading events file...']);
                
                index = 0;
                
                hdr = fread(fid, NUM_HEADER_BYTES, 'char*1');
                eval(char(hdr'));
                info.header = header;
                
                if (isfield(info.header, 'version'))
                    version = info.header.version;
                else
                    version = 0.0;
                end
                
                % pre-allocate space for event data
                data = zeros(MAX_NUMBER_OF_EVENTS, 1);
                timestamps = zeros(MAX_NUMBER_OF_EVENTS, 1);
                info.sampleNum = zeros(MAX_NUMBER_OF_EVENTS, 1);
                info.nodeId = zeros(MAX_NUMBER_OF_EVENTS, 1);
                info.eventType = zeros(MAX_NUMBER_OF_EVENTS, 1);
                info.eventId = zeros(MAX_NUMBER_OF_EVENTS, 1);
                
                if (version >= 0.2)
                    recordOffset = 15;
                else
                    recordOffset = 13;
                end
                
                while ftell(fid) + recordOffset < filesize % at least one record remains
                    
                    index = index + 1;
                    
                    if (version >= 0.1)
                        timestamps(index) = fread(fid, 1, 'int64', 0, 'l');
                    else
                        timestamps(index) = fread(fid, 1, 'uint64', 0, 'l');
                    end
                    
                    
                    info.sampleNum(index) = fread(fid, 1, 'int16'); % implemented after 11/16/12
                    info.eventType(index) = fread(fid, 1, 'uint8');
                    info.nodeId(index) = fread(fid, 1, 'uint8');
                    info.eventId(index) = fread(fid, 1, 'uint8');
                    data(index) = fread(fid, 1, 'uint8'); % save event channel as 'data' (maybe not the best thing to do)
                    
                    if version >= 0.2
                        info.recordingNumber(index) = fread(fid, 1, 'uint16');
                    end
                    
                end
                
                % crop the arrays to the correct size
                eventChannel = data(1:index);
                timestamps = timestamps(1:index);
                sampleNum = info.sampleNum(1:index);
                info.processorID = info.nodeId(1:index);
                eventType = info.eventType(1:index);
                eventID = info.eventId(1:index);
            end
            
            fclose(fid); % close the file
            
            if (isfield(info.header,'sampleRate'))
                if ~ischar(info.header.sampleRate)
                    timestamps = timestamps./info.header.sampleRate; % convert to seconds
                end
            end
            
        end
        
        
        function filesize = getfilesize(fid)
            
            fseek(fid,0,'eof');
            filesize = ftell(fid);
            fseek(fid,0,'bof');
            
        end

    end
end

