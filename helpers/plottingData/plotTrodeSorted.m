function s = plotTrodeSorted(trode, cluster)
%plots the unsorted spike waveforms of all channels for each trodes in a
%subplot

set(gca, 'ylim', [-1000 1000]);
for i = 1:length(trode.chans)
    subplot(1,length(trode.chans),i);
    plot(trode.spikeWaveForms(trode.spikeAssignedCluster==cluster,:,i)');

end