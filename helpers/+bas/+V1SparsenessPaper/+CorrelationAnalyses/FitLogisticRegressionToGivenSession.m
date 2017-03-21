function out = FitLogisticRegressionToGivenSession(in)
or = in.orientations;
c = in.contrasts;
dur = in.actualStimDurations;
spR = in.spikeRatesActual;

stimToRight = double(or>0);

whichNonZeroC = c>0;

numTests=100;
perfs = [];
for i = 1:numTests
    whichTrain = whichNonZeroC & rand(size(whichNonZeroC))<0.7;
    whichTest = ~whichTrain;

    XTrain = spR(whichTrain,:);
    XTest = spR(whichTest,:);
    YTrain = stimToRight(whichTrain) +1; % Left = 1; Right = 2;
    fit.YTest = stimToRight(whichTest)+1;
    fit.cTest = c(whichTest);
    fit.dTest = dur(whichTest);
    
    try
        [mdl,dev,stats] = mnrfit(XTrain,YTrain);%,'constant','Upper','linear','Distribution','binomial');
        FullModel.Model = mdl;
        FullModel.Deviance = dev;
        FullModel.Stats = stats;
        
        pihats = mnrval(mdl,XTest);
        [~,choice] = max(pihats,[],2);
        
        FullModel.YPred = choice;
        FullModel.PredictionAccuracy = sum(fit.YTest==choice)/length(fit.YTest);
    catch ex
        FullModel.Model = [];
        FullModel.Deviance = [];
        FullModel.Stats = [];
        FullModel.YPred = [];
        FullModel.PredictionAccuracy = NaN;
    end
    fit.FullModel = FullModel;
    out.fits(i) = fit;
    perfs = [perfs fit.FullModel.PredictionAccuracy];
end
out.perfs = perfs;

end