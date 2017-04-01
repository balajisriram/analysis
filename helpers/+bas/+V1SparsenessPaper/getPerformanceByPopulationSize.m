function out = getPerformanceByPopulationSize(populationSizes, contrasts, durations, numResamples, numTrialsPerResample)
load PerformanceByStimCondition;
AllPerformances(:,:,1) = [];
SignificantPerformances = AllPerformances(:,:,logical(AllSignificance));

durations = intersect(durations,AllUniqueDurations);
contrasts = intersect(contrasts,AllUniqueContrasts);

performanceAll = nan(length(populationSizes),numResamples,length(contrasts),length(durations));
performanceSignificant = performanceAll;

tic;
for I = 1:length(populationSizes)
    
    currPopulationSize = populationSizes(I);
    disp(currPopulationSize);tic;
    for J = 1:numResamples
        currentSample = datasample(1:size(AllPerformances,3),currPopulationSize);
        currentSignificantSample = datasample(1:size(SignificantPerformances,3),currPopulationSize);
        for K = 1:length(contrasts)
            whichC = find(AllUniqueContrasts==contrasts(K));
            for L = 1:length(durations)
                whichD = find(AllUniqueDurations==durations(L));
                
                relevantPerformances = squeeze(AllPerformances(whichC,whichD,currentSample));
                relevantSignificantPerformances = squeeze(SignificantPerformances(whichC,whichD,currentSignificantSample));
                
                % find the nans and replace them
                try
                    bads = find(isnan(relevantPerformances));
                    goods = find(~isnan(relevantPerformances));
                    for i = 1:length(bads)
                        relevantPerformances(bads(i)) = datasample(relevantPerformances(goods),1);
                    end
                    
                    bads = find(isnan(relevantSignificantPerformances));
                    goods = find(~isnan(relevantSignificantPerformances));
                    for i = 1:length(bads)
                        relevantSignificantPerformances(bads(i)) = datasample(relevantSignificantPerformances(goods),1);
                    end
                    
                    currentSession = rand(numTrialsPerResample,currPopulationSize)<repmat(relevantPerformances',numTrialsPerResample,1);
                    currentSignificantSession = rand(numTrialsPerResample,currPopulationSize)<repmat(relevantSignificantPerformances',numTrialsPerResample,1);
                    
                    votes = sum(currentSession,2);
                    votesSignificant = sum(currentSignificantSession,2);
                    minReqdVotes = currPopulationSize/2;
                    
                    numCorrect = sum(votes>minReqdVotes) + (sum(votes==minReqdVotes))/2;
                    numCorrectSignificant = sum(votesSignificant>minReqdVotes) + sum((votesSignificant==minReqdVotes))/2;
                    
                    
                    performanceAll(I,J,K,L) = numCorrect/numTrialsPerResample;
                    performanceSignificant(I,J,K,L) = numCorrectSignificant/numTrialsPerResample;
                catch ex
                    getReport(ex)
                    performanceAll(I,J,K,L) = NaN;
                    performanceSignificant(I,J,K,L) = NaN;
                end
            end
        end
    end
    toc
end
out.performanceAll = performanceAll;
out.performanceSignificant = performanceSignificant;
