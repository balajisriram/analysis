function out = shuffleResponses(in)
spikeResponsesByStimConditions = in.spikeResponsesByStimConditions;
for i = size(spikeResponsesByStimConditions,1)
    for j = size(spikeResponsesByStimConditions,2)
        for k = size(spikeResponsesByStimConditions,3)
            givenSpikeRate = spikeResponsesByStimConditions{i,j,k};
            numTrials = size(givenSpikeRate,1);
            numNeurons = size(givenSpikeRate,2);
            for l =1:numNeurons
                temp = givenSpikeRate(:,l);
                givenSpikeRate(:,l) = temp(randperm(numTrials));
            end
            spikeResponsesByStimConditions{i,j,k} = givenSpikeRate;
        end
    end
end
out = in;
out.spikeResponsesByStimConditions = spikeResponsesByStimConditions;
