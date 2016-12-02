NumTrials = 10000;
PotentialNumNeurons = round(logspace(0,3,30));
% PotentialNumNeurons = [2,4,6,8,12,18,24,36,54,79,118,175,260,386,574,854,1269,1888,2808,4176,6211,9237,13739,20434];
NumAttempts = 10;
PerformancePerNeuron = 0.55;
CorrectChoice = ones(1,NumTrials);
OverallPerformance = nan(length(PotentialNumNeurons),NumAttempts);
for i = 1:length(PotentialNumNeurons)
    NumNeurons = PotentialNumNeurons(i);
    for j = 1:NumAttempts
        NeuronChoices = rand(NumNeurons,length(CorrectChoice))<Performance;
        TotalChoice = sum(NeuronChoices)>((PotentialNumNeurons(i)/2)-eps);
        
        OverallPerformance(i,j) = sum(TotalChoice)/NumTrials;
    end
end