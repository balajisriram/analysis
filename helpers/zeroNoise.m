function sess = zeroNoise(sess)
for i = 1:length(sess.trodes)
    sess.trodes(i).spikeWaveForms(sess.trodes(i).spikeAssignedCluster==1,:,:) = 0;
end
end