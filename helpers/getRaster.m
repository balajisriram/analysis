function [basisIndices, raster] = getRaster(sess, basisEvent, plottedEvent, histSize)
% getRastor function finds correlations of event occurences between two
% data sets

% Parameters:
%   -basisEvent:   struct with fields: specifier, filter, (optional) and
%                  type (mandatory) 
%                  Finds what events occur in plotted Events at correlating
%                  times in basisEvents
%   -plottedEvent: struct with two required fields, type, specifier
%                  raw data such as single unit or event data etc. Goes to
%                  specific indices in plottedEvent based on basisEvent to
%                  look for correlations.
%   -histSize:     [x y] where x is samples before event and y is after


%% checks basisEvent to make sure fields set correctly grab relevant basis data
if ~isfield(basisEvent,'type')
    error('no basisEvent.type');
elseif (strcmpi(basisEvent.type,'EVENTDATA'))
    if ~isfield(basisEvent,'specifier')
        error('Need to include basisEvent.specifier');
    elseif length(basisEvent.specifier) < 2
        error('basisEvent.specifier must be structured [channel# onOff]');
    elseif (basisEvent.specifier(1) > length(sess.eventData.out))
        error('channel# too high');
    elseif (basisEvent.specifier(2) ~= 0 && basisEvent.specifier(2) ~= 1) 
        error('onOff must be 1 or 0');
    end
    
    basisData = sess.eventData.out(basisEvent.specifier(1)).eventID;
    basisTimes = sess.eventData.out(basisEvent.specifier(1)).eventTimes(basisData == basisEvent.specifier(2));
    
elseif (strcmpi(basisEvent.type, 'CLUSTER'))
    if ~isfield(basisEvent,'specifier')
        error('Need to include basisEvent.specifier');
    elseif length(basisEvent.specifier) < 2
        error('basisEvent.specifier must be structed [trode# cluster#]');
    elseif (basisEvent.specifier(1) > length(sess.trodes))
        error('trode# too high');
    elseif (basisEvent.specifier(2) > length(sess.trodes(basisEvent.specifier(1)).spikeRankedCluster))
        error('cluster# too high');
    end
    
    trodeNum = basisEvent.specifier(1);
    clustNum = basisEvent.specifier(2);
    
    basisTimes = sess.trodes(trodeNum).spikeTimeStamps(sess.trodes(trodeNum).spikeAssignedCluster == clustNum);
    
    
elseif(strcmpi(basisEvent.type, 'SINGLEUNIT')) % ## need to implement still based on how we save singleUnit
    if ~isfield(basisEvent,'specifier')
        error('Need to include basisEvent.specifier');
    elseif length(basisEvent.specifier) < 2
        error('basisEvent.specifier must be structed [trode# singleUnit#]');
    elseif (basisEvent.specifier(1) > length(sess.trodes))
        error('trode# too high');
    elseif (basisEvent.specifier(2) > length(sess.trodes(basisEvent.specifier(1)).units))
        error('singleUnit# too high');
    end
    
    trodeNum = basisEvent.specifier(1);
    unitNum = basisEvent.specifier(2);
    
    basisTimes = sess.trodes(trodeNum).units(unitNum).timestamp;
    
else
    error('basisEvent.type must be EVENTDATA, CLUSTER, or SINGLEUNIT');
end
if ~isfield(basisEvent,'filter')
    disp('no basisEvent.filter, going with default: None.');
    basisEvent.filter = -1;
end

%% checks plottedEvent to make sure fields set correctly
if ~isfield(plottedEvent,'type')
    error('no plottedEvent.type');
elseif (strcmpi(plottedEvent.type,'EVENTDATA'))
    if ~isfield(plottedEvent,'specifier')
        error('Need to include plottedEvent.specifier');
    elseif length(plottedEvent.specifier) < 2
        error('plottedEvent.specifier must be structed [channel# onOff]');
    elseif (plottedEvent.specifier(1) > length(sess.eventData.out))
        error('channel# too high');
    elseif (plottedEvent.specifier(2) ~= 0 && plottedEvent.specifier(2) ~= 1) 
        error('onOff must be 1 or 0');
    end
    
    plottedData = sess.eventData.out(plottedEvent.specifier(1)).eventID;
    plottedTimes = sess.eventData.out(plottedEvent.specifier(1)).eventTimes(plottedData == plottedEvent.specifier);
    
elseif (strcmpi(plottedEvent.type, 'CLUSTER'))
    if ~isfield(plottedEvent,'specifier')
        error('Need to include plottedEvent.specifier');
    elseif length(plottedEvent.specifier) < 2
        error('plottedEvent.specifier must be structed [trode# cluster#]');
    elseif (plottedEvent.specifier(1) > length(sess.trodes))
        error('trode# too high');
    elseif (plottedEvent.specifier(2) > length(sess.trodes(plottedEvent.specifier(1)).spikeRankedCluster))
        error('cluster# too high');
    end
    
    trodeNum = plottedEvent.specifier(1);
    clustNum = plottedEvent.specifier(2);
    
    plottedTimes = sess.trodes(trodeNum).spikeTimeStamps(sess.trodes(trodeNum).spikeAssignedCluster == clustNum);    
    
elseif(strcmpi(plottedEvent.type, 'SINGLEUNIT')) % ## need to implement still based on how we save singleUnit
    if ~isfield(plottedEvent,'specifier')
        error('Need to include basisEvent.specifier');
    elseif length(plottedEvent.specifier) < 2
        error('basisEvent.specifier must be structed [trode# singleUnit#]');
    elseif (plottedEvent.specifier(1) > length(sess.trodes))
        error('trode# too high');
    elseif (plottedEvent.specifier(2) > length(sess.trodes(plottedEvent.specifier(1)).units))
        error('singleUnit# too high');
    end
    
    trodeNum = plottedEvent.specifier(1);
    unitNum = plottedEvent.specifier(2);
    
    plottedTimes = sess.trodes(trodeNum).units(unitNum).timestamp;
else
    error('plottedEvent.type must be EVENTDATA, CLUSTER, or SINGLEUNIT');
end

%% get bad timestamps if any
badTS = [];
for i = 2:length(sess.history) %skips first trivial history
    if strcmp(sess.history{i}{2},'BAD_TIMESTAMPS')==1
        if isempty(badTS)
            badTS = sess.history{i}{3}.data*30000;
        else
            badTS = [badTS;sess.history{i}{3}.data*30000];
        end
    end
end

%% use filter if set to narrow down points of interest from basisEvent
if basisEvent.filter ~= -1
    blockedInd = 1:length(basisTimes);
    for i = 1:size(a,1)
        filtRange = basisEvent.filter(1,:);
        blocked = find(basisTimes<filtRange(1)&basisTimes>filtRange(2));
        blockedInd = intersect(blockedInd, blocked);
    end
    basisTimes(blockedInd) = [];
end

%% convert timestamps to indices
basisIndices = sort(basisTimes*30000);
plottedIndices = sort(plottedTimes*30000);

%% find corresponding points in plottedEvent using histSize
percentComplete = 0;
modNumber = ceil(size(basisIndices,1)/10);
raster = sparse(size(basisIndices,1),histSize(1)+histSize(2)+1);
for i = 1:size(basisIndices,1)
     if mod(i,modNumber)==1
         disp([num2str(percentComplete), '% Complete']);
         percentComplete=percentComplete+10;
     end
    found = plottedIndices(plottedIndices>=(basisIndices(i)-histSize(1))&plottedIndices<=(basisIndices(i)+histSize(2)));
    if ~isempty(found)
        try
            firstInd = basisIndices(i) - histSize(1);
            found = found-firstInd+1;
            raster(i,ceil(found)) = 1;
        catch ex
            warning(['Index ', num2str(firstInd), ' out of range']);
        end
    end
end

%warn if any assumptions were made using bad timestamps
for i = 1:size(badTS,1)
    if (any(basisIndices-histSize(1)>badTS(i,1)) & any(basisIndices-histSize(1)<badTS(i,2)))
        warning('Making False Assumptions About Time Where Data Is Lost');
    end
    if (any(basisIndices+histSize(2)>badTS(i,1)) & any(basisIndices+histSize(2)<badTS(i,2)))
        warning('Making False Assumptions About Time Where Data Is Lost');
    end   
end

%return list of correlations as rastor

end

