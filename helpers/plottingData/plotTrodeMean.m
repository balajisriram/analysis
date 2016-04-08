function s = plotTrodeMean(trode)
%plots the unsorted spike waveforms of all channels for each trodes in a
%subplot

set(gca, 'ylim', [-1000 1000]);
cmap = colormap(lines);
divisor = floor(size(cmap,1)/length(trode.spikeRankedCluster));
for i = 1:4
    for j = 1:length(trode.spikeRankedCluster)
        spikes = trode.spikeWaveForms(trode.spikeAssignedCluster==trode.spikeRankedCluster(j),:,i)';
        meanVals = [];
        stdVals = [];
        clusters = length(trode.spikeRankedCluster);
        for k = 1:size(spikes,1)
            m = mean(spikes(k,:));
            s = std(spikes(k,:));
            meanVals = [meanVals m];
            stdVals = [stdVals s];
        end
        
        h = subplot(1,4,i);
        color = cmap(j*divisor,:);
        %p = plot([1:length(meanVals)],meanVals,[1:length(stdVals)],meanVals - stdVals,'--',[1:length(stdVals)],meanVals + stdVals,'--');
        p = plot([1:length(meanVals)],meanVals);
        set(p,'Color', color);
        hold on;
    end

end