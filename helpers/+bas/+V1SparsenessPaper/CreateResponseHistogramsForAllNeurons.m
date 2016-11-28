function ResponseHist = CreateResponseHistogramsForAllNeurons
if ~exist('DETAILS','var')
    load('Details_SpikeDetails')
end

%% details on durations
durs = [];
ctrs = [];
for i = setdiff(1:length(DETAILS),[7,9,10,11,17,35])
    durs = [durs;DETAILS{i}{1}.actualStimDurations];
    ctrs = [ctrs;DETAILS{i}{1}.contrasts];
end
%% get the response histogram

% seperate durations from 0-0.05;0.05-0.11;0.11-0.21;0.21-0.5;; 4 durations
% separate contrasts 0-0.1,0.11-0.2,0.8-1.1; 3 contrasts

AllNeurons = {};
durationLimits = [-0.01,0.051;...
                    0.051,0.11;...
                    0.11,0.21;...
                    0.21,0.5];
contrastLimits = [-0.1,0.1;...
                    0.11,0.2;...
                    0.8,1.1];
for i = setdiff(1:length(DETAILS),[7,9,10,11,17,35])
    fprintf('session %d: ',i);
    or = DETAILS{i}{1}.orientations;
    c = DETAILS{i}{1}.contrasts;
    dur = DETAILS{i}{1}.actualStimDurations;
    spR = DETAILS{i}{1}.spikeRatesActual;
    
    
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

end