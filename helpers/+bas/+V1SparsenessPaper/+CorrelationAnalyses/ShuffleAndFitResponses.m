function FITS = ShuffleAndFitResponses
if ~exist('SPIKEDETAILS','var')
    load('DetailsAt500MS')
end
tempSeed = rng;
rng(736774);
FIT_LOGISTIC = {};


for i = 1:length(SPIKEDETAILS)
    try
        fprintf('%d\n',i)
        fitsThisSession = {};
        separatedResponses = bas.V1SparsenessPaper.CorrelationAnalyses.separateResponsesByStimulus(SPIKEDETAILS{i});
        numShuffles = 100;
        for j = 1:numShuffles
            fprintf('%d.',j)
            fitsThisShuffle.shuffledSession = bas.V1SparsenessPaper.CorrelationAnalyses.createSessionFromShuffledResponses(...
                bas.V1SparsenessPaper.CorrelationAnalyses.shuffleResponses(separatedResponses));
            fitsThisShuffle.LogisticRegression = bas.V1SparsenessPaper.CorrelationAnalyses.FitLogisticRegressionToGivenSession(fitsThisShuffle.shuffledSession);
            fitsThisSession{end+1} = fitsThisShuffle;
        end
        fprintf('\n');
        FitDataName = sprintf('FitThisSession%d_Shuffle.mat',i);
        save(FitDataName,'fitsThisSession')
    catch ex
        getReport(ex)
    end
    
end
end