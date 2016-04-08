function s = plotAllTrodesWaveforms(session)
%plots the unsorted spike waveforms of all channels for each trodes in a
%subplot

numTrodes = length(session.trodes);
set(gca, 'ylim', [-1000 1000]);
for i = 1:numTrodes
    subplot(4,8,i);
    plot(session.trodes(i).spikeWaveForms(:,:,i)');

end

