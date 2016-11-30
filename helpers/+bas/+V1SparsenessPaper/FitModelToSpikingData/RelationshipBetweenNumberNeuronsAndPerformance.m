function PerfByPopSize = RelationshipBetweenNumberNeuronsAndPerformance(Population)
PopulationSizes = [200];
NumberofResamples = 100;

PerfByPopSize = nan(length(PopulationSizes),NumberofResamples);

for i = 1:length(PopulationSizes)
    for j = 1:NumberofResamples
        
        % resamplePopulation
        resampledPop = bas.V1SparsenessPaper.SimulateSession(Population,PopulationSizes(i),1000,2,2,'SpikeRate'); %c = 0.15; d = 100
        
        XTrain = resampledPop.SessionResponses(1:500,:);
        YTrain = resampledPop.StimulusID(1:500);
        XTest = resampledPop.SessionResponses(501:1000,:);
        YTest = resampledPop.StimulusID(501:1000);
        
        mdl = mnrfit(XTrain,YTrain);
        [~,choice] = max(mnrval(mdl,XTest),[],2);
        PerfByPopSize(i,j) = sum(choice==YTest)/length(YTest);
    end
end

end