function PerfByPopSize = RelationshipBetweenNumberNeuronsAndPerformance(Population,WhichContrast,WhichDuration)
PopulationSizes = [1 3 10 30 100];
NumberofResamples = 10;

PerfByPopSize = nan(length(PopulationSizes),NumberofResamples);

warning off;
for i = 1:length(PopulationSizes)
    for j = 1:NumberofResamples
        
        if mod(j,10)==0
            fprintf('%d::%d\n',i,j);
        end
        
        % resamplePopulation
        NumTrials = 100000;
        resampledPop = bas.V1SparsenessPaper.SimulateSession(Population,PopulationSizes(i),NumTrials,WhichContrast,WhichDuration,'SpikeRate'); %c = 0.15; d = 100
        
        XTrain = resampledPop.SessionResponses(1:NumTrials/2,:);
        YTrain = resampledPop.StimulusID(1:NumTrials/2);
        XTest = resampledPop.SessionResponses(NumTrials/2+1:NumTrials,:);
        YTest = resampledPop.StimulusID(NumTrials/2+1:NumTrials);
        
        try
            mdl = mnrfit(XTrain,YTrain);
            [~,choice] = max(mnrval(mdl,XTest),[],2);
            PerfByPopSize(i,j) = sum(choice==YTest)/length(YTest);
        catch ex
            getReport(ex)
            PerfByPopSize(i,j) = NaN;
        end
    end
end

end