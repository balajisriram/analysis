function FITS = ShuffleAndFitResponses
if ~exist('SPIKEDETAILS','var')
    load('DetailsAt500')
end
tempSeed = rng;
rng(736775);
FIT_LOGISTIC = {};


for i = 1:length(SPIKEDETAILS)
    fitsThisSession = {};
    separatedResponses = bas.V1SparsenessPaper.CorrelationAnalyses.separateResponsesByStimulus(SPIKEDETAILS{i});
    numShuffles = 100;
    for j = 1:numShuffles
        fitsThisShuffle.shuffledSession = bas.V1SparsenessPaper.CorrelationAnalyses.createSessionFromShuffledResponses(bas.V1SparsenessPaper.CorrelationAnalyses.shuffleResponses(separatedResponses));
        fitsThisShuffle.LogisticRegression = bas.V1SparsenessPaper.CorrelationAnalyses.FitLogisticRegressionToGivenSession(fitsThisShuffle.shuffledSession);
        fitsThisSession{end+1} = fitsThisShuffle;
    end
    FitDataName = sprintf('FitThisSession%d_Shuffle.mat',i);
        save(FitDataName,'fitsThisSession')
        
    
end
end