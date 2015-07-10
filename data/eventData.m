classdef eventData
    % eventsData class to store relevant data for event files.
    
    properties
        out
    end
    
    methods
        % ctor just gets all relevant data, complexity of getting data done
        % here.
        function e = eventData(filename)
            
            %opens event file, gets info
            [eventTimes, eventID, eventChannel] = openEvents(filename);
            
            whichChans = unique(eventChannel);

            for i = 1:length(whichChans)
                % find events for that channel
                eventsThatChannel = eventChannel==whichChans(i);
                eventTimesThatChannel = eventTimes(eventsThatChannel);
                eventIDThatChannel = eventID(eventsThatChannel);

                % IMPORTANT CHOOSE UNIQUE ONLY AFTER SELECTING ON CHANNEL
                [eventTimesThatChannelUniq, ia] = unique(eventTimesThatChannel);
                eventIDThatChannelUniq = eventIDThatChannel(ia);

                e.out(i).channelNum = whichChans(i);
                e.out(i).eventTimes = eventTimesThatChannelUniq;
                e.out(i).eventID = eventIDThatChannelUniq;
            end
            
            
        end
    end
    
end

