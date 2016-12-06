function OutputSession = SimulateSession(NeuralResponses,NumNeurons,NumTrials,WhichContrast,WhichDuration,WhatFeature)

if iscell(NeuralResponses)
    NeuralResponses = cell2mat(NeuralResponses);
end

% Sample Neurons should have WhichContrast and WhichDuration
HasContrasts = reshape([NeuralResponses.HasContrasts],3,length(NeuralResponses))';
HasDurations = reshape([NeuralResponses.HasDurations],4,length(NeuralResponses))';

whichOK = HasContrasts(:,WhichContrast) & HasDurations(:,WhichDuration);
NeuralResponses = NeuralResponses(whichOK);

whichNeurons = datasample(1:length(NeuralResponses),NumNeurons);

ChosenSubPopulation = NeuralResponses(whichNeurons);

SessionResponses = nan(NumTrials,NumNeurons);

StimulusID = (rand(NumTrials,1)>0.5)+1;
for i = 1:NumNeurons
    for j = 1:NumTrials
        switch WhatFeature
            case 'SpikeRate'
                temp = ChosenSubPopulation(i).SpikeRateHistogram{StimulusID(j),WhichDuration,WhichContrast};
            case 'SpikeNum'
                temp = ChosenSubPopulation(i).SpikeNumHistogram{StimulusID(j),WhichDuration,WhichContrast};
            case 'Spiketime'
                temp = ChosenSubPopulation(i).SpikeTimeHistogram{StimulusID(j),WhichDuration,WhichContrast};
        end
        temp = temp(~isnan(temp));
        SessionResponses(j,i) = chooseFrom(temp);
    end    
end

OutputSession.ChosenSubPopulation = ChosenSubPopulation;
OutputSession.StimulusID = StimulusID;
OutputSession.SessionResponses = SessionResponses;


end

function out = chooseFrom(in)
out = NaN;
temp = randperm(length(in));
try
    out = in(temp(1));
end
end