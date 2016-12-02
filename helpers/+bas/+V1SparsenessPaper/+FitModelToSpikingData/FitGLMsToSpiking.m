function FITALL = FitGLMsToSpiking
%% Fit GLM to each data 
if ~exist('DETAILS','var')
    load('Details_SpikeDetails')
end
FITALL = {};
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
    
    numTests = 10;
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
        YTrain = stimToRight(whichTrain);
        fit.YTest = stimToRight(whichTest);
        fit.cTest = c(whichTest);
        fit.dTest = dur(whichTest);
        % individual models
        IndividualModels = cell(1,size(spR,2));
        for k = 1:size(spR,2)
            disp(k);
            mdl = fitglm(XTrain(:,k),YTrain,'Distribution','binomial');
            IndividualModels{k}.Model = mdl;
            IndividualModels{k}.YPred = mdl.feval(XTest(:,k));
            IndividualModels{k}.PredictionAccuracy = sum(fit.YTest==(IndividualModels{k}.YPred>0.5))/length(fit.YTest);
        end
        fit.IndividualModels = IndividualModels;
        
        mdl = stepwiseglm(spR(whichTrain,:),stimToRight(whichTrain),'constant','Upper','linear','Distribution','binomial');
        FullModel.Model = mdl;
        FullModel.SignificantCoeffnames = mdl.CoefficientNames;
        XTestSubset = XTest(:,getSignificantCoeffIndices(FullModel.SignificantCoeffnames));
        FullModel.YPred = mdl.feval(XTestSubset);
        FullModel.PredictionAccuracy = sum(fit.YTest==(FullModel.YPred>0.5))/length(fit.YTest);
        
        fit.FullModel = FullModel;
        
        fitsThisSession{j} = fit;
    end
    fprintf('\n');
    FITALL{i} = fitsThisSession;
end
toc
end

function out = getSignificantCoeffIndices(names)
out = [];
for i = 1:length(names)
    name = names{i};
    if strcmp(name,'(Intercept)')
        continue
    end
    out(end+1) = str2num(name(2:end));
end
end

