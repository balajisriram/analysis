function FITS= WhichFeaturePredictsOrientationBetter
if ~exist('DETAILS','var')
    load('Details_SpikeDetails')
end


%% using spike Rates
FIT_LOGISTIC_SPRATE = {};

tic
fprintf('\n');

for i = setdiff(1:length(DETAILS),[7,9,10,11,17,35])
    fprintf('session %d: ',i);
    or = DETAILS{i}{1}.orientations;
    c = DETAILS{i}{1}.contrasts;
    dur = DETAILS{i}{1}.actualStimDurations;
    spR = DETAILS{i}{1}.spikeRatesActual;
    
    stimPresent = double(c>0);
    stimToRight = double(or>0);
    
    whichNonZeroC = c>0;
    
    numTests = 100;
    fitsThisSession = cell(1,numTests);
    fprintf('test:')
    for j = 1:numTests
        fprintf('%d.',j);
        % train 70%, test 30%. train only on c>0
        whichTrain = whichNonZeroC & rand(size(whichNonZeroC))<0.7;
        whichTest = ~whichTrain;
        
        fit.trialsTrain = DETAILS{i}{1}.trNums(whichTrain);
        fit.trialsTest = DETAILS{i}{1}.trNums(whichTest);
        XTrain = spR(whichTrain,:);
        XTest = spR(whichTest,:);
        YTrain = stimToRight(whichTrain) +1; % Left = 1; Right = 2;
        fit.YTest = stimToRight(whichTest)+1;
        fit.cTest = c(whichTest);
        fit.dTest = dur(whichTest);
        % individual models
        IndividualModels = cell(1,size(spR,2));
        for k = 1:size(spR,2)
            disp(k);
            try
                [mdl,dev,stats] = mnrfit(XTrain(:,k),YTrain);%,'Distribution','binomial');
                IndividualModels{k}.Model = mdl;
                IndividualModels{k}.Deviance = dev;
                IndividualModels{k}.Stats = stats;
                pihats = mnrval(mdl,XTest(:,k));
                [~,choice] = max(pihats,[],2);
                IndividualModels{k}.YPred = choice;
                IndividualModels{k}.PredictionAccuracy = sum(fit.YTest==IndividualModels{k}.YPred)/length(fit.YTest);
            catch ex
                IndividualModels{k}.Model = [];
                IndividualModels{k}.Deviance = [];
                IndividualModels{k}.Stats = [];
                IndividualModels{k}.YPred = [];
                IndividualModels{k}.PredictionAccuracy = NaN;
            end
        end
        fit.IndividualModels = IndividualModels;
        
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
        
        fitsThisSession{j} = fit;
    end
    fprintf('\n');
    FIT_LOGISTIC_SPRATE{i} = fitsThisSession;
end


%% using spike Numbers
FIT_LOGISTIC_SPNUMS = {};


fprintf('\n');

for i = setdiff(1:length(DETAILS),[7,9,10,11,17,35])
    fprintf('session %d: ',i);
    or = DETAILS{i}{1}.orientations;
    c = DETAILS{i}{1}.contrasts;
    dur = DETAILS{i}{1}.actualStimDurations;
    spR = DETAILS{i}{1}.spikeNumsActual;
    
    stimPresent = double(c>0);
    stimToRight = double(or>0);
    
    whichNonZeroC = c>0;
    
    numTests = 100;
    fitsThisSession = cell(1,numTests);
    fprintf('test:')
    for j = 1:numTests
        fprintf('%d.',j);
        % train 70%, test 30%. train only on c>0
        whichTrain = whichNonZeroC & rand(size(whichNonZeroC))<0.7;
        whichTest = ~whichTrain;
        
        fit.trialsTrain = DETAILS{i}{1}.trNums(whichTrain);
        fit.trialsTest = DETAILS{i}{1}.trNums(whichTest);
        XTrain = spR(whichTrain,:);
        XTest = spR(whichTest,:);
        YTrain = stimToRight(whichTrain) +1; % Left = 1; Right = 2;
        fit.YTest = stimToRight(whichTest)+1;
        fit.cTest = c(whichTest);
        fit.dTest = dur(whichTest);
        % individual models
        IndividualModels = cell(1,size(spR,2));
        for k = 1:size(spR,2)
            disp(k);
            try
                [mdl,dev,stats] = mnrfit(XTrain(:,k),YTrain);%,'Distribution','binomial');
                IndividualModels{k}.Model = mdl;
                IndividualModels{k}.Deviance = dev;
                IndividualModels{k}.Stats = stats;
                pihats = mnrval(mdl,XTest(:,k));
                [~,choice] = max(pihats,[],2);
                IndividualModels{k}.YPred = choice;
                IndividualModels{k}.PredictionAccuracy = sum(fit.YTest==IndividualModels{k}.YPred)/length(fit.YTest);
            catch ex
                IndividualModels{k}.Model = [];
                IndividualModels{k}.Deviance = [];
                IndividualModels{k}.Stats = [];
                IndividualModels{k}.YPred = [];
                IndividualModels{k}.PredictionAccuracy = NaN;
            end
        end
        fit.IndividualModels = IndividualModels;
        
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
        
        fitsThisSession{j} = fit;
    end
    fprintf('\n');
    FIT_LOGISTIC_SPNUMS{i} = fitsThisSession;
end

%% using firstSpikeTime
FIT_LOGISTIC_SPTIME = {};


fprintf('\n');

for i = setdiff(1:length(DETAILS),[7,9,10,11,17,35])
    fprintf('session %d: ',i);
    or = DETAILS{i}{1}.orientations;
    c = DETAILS{i}{1}.contrasts;
    dur = DETAILS{i}{1}.actualStimDurations;
    spR = DETAILS{i}{1}.timeToFirstSpike;
    
    stimPresent = double(c>0);
    stimToRight = double(or>0);
    
    whichNonZeroC = c>0;
    
    numTests = 100;
    fitsThisSession = cell(1,numTests);
    fprintf('test:')
    for j = 1:numTests
        fprintf('%d.',j);
        % train 70%, test 30%. train only on c>0
        whichTrain = whichNonZeroC & rand(size(whichNonZeroC))<0.7;
        whichTest = ~whichTrain;
        
        fit.trialsTrain = DETAILS{i}{1}.trNums(whichTrain);
        fit.trialsTest = DETAILS{i}{1}.trNums(whichTest);
        XTrain = spR(whichTrain,:);
        XTest = spR(whichTest,:);
        YTrain = stimToRight(whichTrain) +1; % Left = 1; Right = 2;
        fit.YTest = stimToRight(whichTest)+1;
        fit.cTest = c(whichTest);
        fit.dTest = dur(whichTest);
        % individual models
        IndividualModels = cell(1,size(spR,2));
        for k = 1:size(spR,2)
            disp(k);
            try
                [mdl,dev,stats] = mnrfit(XTrain(:,k),YTrain);%,'Distribution','binomial');
                IndividualModels{k}.Model = mdl;
                IndividualModels{k}.Deviance = dev;
                IndividualModels{k}.Stats = stats;
                pihats = mnrval(mdl,XTest(:,k));
                [~,choice] = max(pihats,[],2);
                IndividualModels{k}.YPred = choice;
                IndividualModels{k}.PredictionAccuracy = sum(fit.YTest==IndividualModels{k}.YPred)/length(fit.YTest);
            catch ex
                IndividualModels{k}.Model = [];
                IndividualModels{k}.Deviance = [];
                IndividualModels{k}.Stats = [];
                IndividualModels{k}.YPred = [];
                IndividualModels{k}.PredictionAccuracy = NaN;
            end
        end
        fit.IndividualModels = IndividualModels;
        
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
        
        fitsThisSession{j} = fit;
    end
    fprintf('\n');
    FIT_LOGISTIC_SPTIME{i} = fitsThisSession;
end

toc
%% collate it
FITS.FIT_LOGISTIC_SPRATE = FIT_LOGISTIC_SPRATE;
FITS.FIT_LOGISTIC_SPNUMS = FIT_LOGISTIC_SPNUMS;
FITS.FIT_LOGISTIC_SPTIME = FIT_LOGISTIC_SPTIME;



end