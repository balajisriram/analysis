datestr(clock)


r = rand([48,40000]);
a = rand([48,20000]);
c = rand([48,30000]);

plot(r); hold on;
plot(a);
plot(c);

hold off;

plot(r);

plot(c);


plot(a);






datestr(clock)

for i = 1:length(clusterVisibilityValues)
    if clusterVisibilityValues(i)
        thisCluster=find(handles.trode.spikeAssignedCluster==handles.trode.spikeRankedCluster(i));
        if length(thisCluster) > 10000
            r = length(thisCluster).*rand(10000,1);
            r = ceil(r);
            block = 1:length(thisCluster);
            block(r) = [];
            thisCluster(block) = [];
        end
        sizspikeWaveforms = size(handles.trode.spikeWaveForms);
        if length(sizspikeWaveforms)==3
            numChans = sizspikeWaveforms(3);
            numSamps = sizspikeWaveforms(2);
        else
            numChans = 1;
            numSamps = sizspikeWaveforms(2);
        end
        if ~isempty(thisCluster)
            switch numChans
                case 1
                    plot(handles.trode.spikeWaveForms(thisCluster,:)','color',colors(i,:));
                otherwise
                    for j = 1:numChans
                        plot((j-1)*numSamps+(1:numSamps),handles.trode.spikeWaveForms(thisCluster,:,j)','color',colors(i,:));
                    end
            end
        end
    end
end
















for i = 1:length(clusterVisibilityValues)
    if clusterVisibilityValues(i)
        thisCluster=find(handles.trode.spikeAssignedCluster==handles.trode.spikeRankedCluster(i));
        if length(thisCluster) > 10000
            r = length(thisCluster).*rand(10000,1);
            r = ceil(r);
            block = 1:length(thisCluster);
            block(r) = [];
            thisCluster(block) = [];
        end
        sizspikeWaveforms = size(handles.trode.spikeWaveForms);
        if length(sizspikeWaveforms)==3
            numChans = sizspikeWaveforms(3);
            numSamps = sizspikeWaveforms(2);
        else
            numChans = 1;
            numSamps = sizspikeWaveforms(2);
        end
        if ~isempty(thisCluster)
            switch numChans
                case 1
                    plot(handles.trode.spikeWaveForms(thisCluster,:)','color',colors(i,:));
                otherwise
                    if isfield(handles, 'waveAxisPlot') % ##need to figure out how to only add needToGraph
                        swap = [2:length(clusterVisibilityValues) 1];
                        prevGraphed=swap(find(cellfun('isempty', handles.yval)==0));
                        currGraphed=swap(find(clusterVisibilityValues));
                        
                        needToGraph=setdiff(currGraphed,prevGraphed);
                        for j = 1:numChans
                            handles.xval{i} = [handles.xval{i} (j-1)*numSamps+(1:numSamps)];
                            handles.yval{i} = [handles.yval{i};handles.trode.spikeWaveForms(thisCluster,:,j)'];
                        end
                        set(handles.waveAxisPlot, 'xdata', handles.xval{i},'ydata', handles.yval{i},'color',colors(i,:));
                    else
                        handles.xval = cell(1,size(handles.cMap,1));
                        handles.yval = cell(1,size(handles.cMap,1));
                        for j = 1:numChans
                            handles.xval{i} = [handles.xval{i} (j-1)*numSamps+(1:numSamps)];
                            handles.yval{i} = [handles.yval{i};handles.trode.spikeWaveForms(thisCluster,:,j)'];
                        end
                        
                        handles.waveAxisPlot = plot(handles.xval{i},handles.yval{i}','color',colors(i,:));
                    end
            end
        end
    end
end














if sum(clusterVisibilityValues)<length(handles.prevVis) % ## if cluster is supposed to be removed
    clustsToRemove = setdiff(handles.prevVis, find(clusterVisibilityValues));
    for i = 1:length(clustsToRemove)
        set(handles.plotVals{clustsToRemove(i)}, 'visible', 'off');
    end
else % ## add cluster
    for i = 1:length(clusterVisibilityValues)
        if clusterVisibilityValues(i)
            if isempty(handles.plotVals{i})
                thisCluster=find(handles.trode.spikeAssignedCluster==handles.trode.spikeRankedCluster(i));
                if length(thisCluster) > 10000
                    r = length(thisCluster).*rand(10000,1);
                    r = ceil(r);
                    block = 1:length(thisCluster);
                    block(r) = [];
                    thisCluster(block) = [];
                end
                sizspikeWaveforms = size(handles.trode.spikeWaveForms);
                if length(sizspikeWaveforms)==3
                    numChans = sizspikeWaveforms(3);
                    numSamps = sizspikeWaveforms(2);
                else
                    numChans = 1;
                    numSamps = sizspikeWaveforms(2);
                end
                if ~isempty(thisCluster)
                    switch numChans
                        case 1
                            handles.plotVals{i} = plot(handles.trode.spikeWaveForms(thisCluster,:)','color',colors(i,:));
                        otherwise
                            xvals = 1:(numChans*numSamps+numChans);
                            yv = handles.trode.spikeWaveForms(thisCluster,:,:);
                            yvals = zeros(size(yv,1), size(xvals,2));
                            ind = 1;
                            for j = 1:numChans
                                yvals(:,ind:ind+numSamps-1) = yv(:,:,j);
                                yvals(:,j*numSamps+1) = zeros(length(handles.trode.spikeWaveForms(thisCluster,:,j)),1);
                                ind = j*numSamps+2;
                            end
                            handles.plotVals{i} = plot(xvals,yvals,'color',colors(i,:));
                    end
                end
            else
                keyboard
                set(handles.plotVals{i}, 'visible', 'on');
            end
        end
    end
end

handles.prevVis = find(clusterVisibilityValues);
guidata(hObject,handles);

if sum(clusterVisibilityValues) == 0
    sizspikeWaveforms = size(handles.trode.spikeWaveForms);
    if length(sizspikeWaveforms)==3
        numChans = sizspikeWaveforms(3);
        numSamps = sizspikeWaveforms(2);
    else
        numChans = 1;
        numSamps = sizspikeWaveforms(2);
    end
end

title('waveforms');
set(gca,'XTick',[]);
axis([1 numChans*numSamps  1.1*minmax(handles.trode.spikeWaveForms(:)') ])