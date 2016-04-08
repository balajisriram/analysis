% PLAN:
%
% Record data and ground channels in order from 1-32 on hardware. Data
% folder will contain continuous files ch1-ch32.continuous corresponding to
% each of these channels. Load each ch1.cont-32.cont file using load open
% ephys and see at what time the data becomes 0 for an extended period of
% time. Use these times to decide how hardware channels map to .continuous
% file channels. 
%



function [ outcome ] = testChannelMappings( testFolder )

    outcome = [];
    fPath = [testFolder,'\*.continuous'];
    files = dir(fPath);
    
    channelTimes = zeros(1,32);
    
    for file = files'
    
        if ~strncmpi(file.name, '100_CH', 6)
           continue;
        end
        currChannel = str2num( file.name(find(file.name=='H')+1:find(file.name=='.')-1));
        
        [data, timestamps, info] = load_open_ephys_data([testFolder,'\',file.name]);
        
        % not sure exactly what grounded sections will look like yet will
        % change this when have actual data
        keyboard
        
        allTimesZero = [];
        allTimesZero = timestamps(data == 0);
        %here find grounded section start and put into channelTimes
        %channelTimes(currChannel) = groundedStart
    end

    
    [~, previousOrder] = sort(channelTimes);
    outcome = previousOrder;


end

