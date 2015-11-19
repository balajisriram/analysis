classdef eventData
    
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
        function e = eventData(foldername)
            assert(isdir(foldername),'events folder unavailable');
            e.eventFolder = foldername;
            
            e = e.getChannelEvents();
            e = e.getTrialEvents();
            e = e.getTrialData();
            e = e.getOtherMessages();
        end
        
            
    end
    
    methods
        
        function e = getChannelEvents(e)
            %opens messages file
            [e.messages] = eventData.openMessages(fullfile(e.eventFolder,'messages.events'));
            
            %tries to fix errors generated when parsing messages.event file
            %[e.messages, e.specialCases] = fixMessageParseErrors(e.messages);
            
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
                
                e.out(i).channelNum = whichChans(i);
                e.out(i).eventTimes = eventTimesThatChannelUniq;
                e.out(i).eventID = eventIDThatChannelUniq;
                e.out(i).eventType = eventTypeThatChannelUniq;
                e.out(i).sampNum = sampNumThatChannelUniq;
            end
        end
        
        function e = getTrialEvents(e)
            trialsEventInd = (e.out(1).eventType==3);
            trialsRisingInd = (e.out(1).eventID==1);          
            
            trialsStart = e.out(1).eventTimes(trialsEventInd & trialsRisingInd);
            trialsStop = e.out(1).eventTimes(trialsEventInd & ~trialsRisingInd);
            
            if (length(trialsStart)*2)>length(e.messages)
                trialsStart(end) = [];
            end
            
            if length(trialsStart) ~= length(trialsStop)
                for i = 1:length(trialsStart)-1
                    e.trials(i).trialNumber = e.messages(i*2).trial;
                    e.trials(i).start = trialsStart(i);
                    e.trials(i).stop = trialsStop(i);
                end
                lastInd = length(trialsStart);
                e.trials(lastInd).trialNumber = e.messages(end).trial;
                e.trials(lastInd).start = trialsStart(lastInd);
                e.trials(lastInd).stop = NaN;  %##if trial end not recorded
            else
                for i = 1:length(trialsStart)
                    e.trials(i).trialNumber = e.messages(i*2).trial;
                    e.trials(i).start = trialsStart(i);
                    e.trials(i).stop = trialsStop(i);
                end
            end
            
            stimRisingInd = (e.out(3).eventID == 1);
            
            stimStart = e.out(3).eventTimes(stimRisingInd);
            stimStop = e.out(3).eventTimes(~stimRisingInd);
            
            if length(stimStart) > length(trialsStart)
                if length(stimStart) == length(stimStop)
                    stimStop(end) = [];
                end
                stimStart(end) = [];
            end
            
            for i = 1:length(stimStart)
                e.stim(i).trialNumber = e.trials(i).trialNumber;
                e.stim(i).start = stimStart(i);
                e.stim(i).stop = stimStop(i);
            end
            
            for i = 1:length(e.trials)
                minTime = e.trials(i).start;
                maxTime = e.trials(i).stop;
                
                frameRisingInd = (e.out(2).eventID == 1);
                frameTimeInd = ((e.out(2).eventTimes >= minTime) & (e.out(2).eventTimes <= maxTime));
                
                e.frame(i).trialNumber = e.trials(i).trialNumber;
                e.frame(i).start = e.out(2).eventTimes(frameRisingInd & frameTimeInd);
            end
        end
        
        function e = getTrialData(e)
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
        
        function e = getOtherMessages(e)
        end
    end
    
    methods(Static)
        function [messages] = openMessages(filename)
            fid = fopen(filename);
            tline = fgets(fid);
            trial = 1;
            k = 1;
            while isempty(strfind(tline,'TrialStart'))
                tline = fgets(fid);
            end
            while ischar(tline)
                index = str2num(tline(1:strfind(tline,' ')-1));
                if isempty(strfind(tline,'TrialEnd')) % if is trial start
                    ind = strfind(tline,'::');
                    i=2;
                    while str2num(tline(ind+i)) >= 0
                        i = i + 1;
                    end
                    trial = str2num(tline(ind+2:ind+i-1));
                    messages(k).index = index;
                    messages(k).status = 1;
                    messages(k).trial = trial;
                else % else is trial end
                    messages(k).index = index;
                    messages(k).status = 0;
                    messages(k).trial = trial;
                end
                k = k+1;
                tline = fgets(fid);
            end
        end
        
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

