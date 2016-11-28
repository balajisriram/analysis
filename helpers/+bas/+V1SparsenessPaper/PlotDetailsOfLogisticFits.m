%%
if ~exist('FIT_LOGISTIC','var')
    load FitsLogistic
end

%% Number of neurons that are significantly predictive of orientation
% neurons that are consistently predictive are predictive no matter what
% the training/testing splits are.
allPerformance = [];
allEstimates = [];
allPVals = [];
allSignificance = [];
whichSession = [];
sessionPerformance = [];
sessionID = [];
for i = 1:length(FIT_LOGISTIC)
    if isempty(FIT_LOGISTIC{i})
        continue
    end
    AllIndividualFits = cell(1,length(FIT_LOGISTIC{i}));
     
    for j = 1:length(FIT_LOGISTIC{i})
        AllIndividualFits{j} = FIT_LOGISTIC{i}{j}.IndividualModels;
    end
    
    numNeurons = length(AllIndividualFits{1});
    numEstimates = length(FIT_LOGISTIC{1});
    Estimates = nan(numNeurons,numEstimates);
    Averages = nan(numNeurons,numEstimates);
    PValues = nan(numNeurons,numEstimates);
    Performance = nan(numNeurons,numEstimates);
    for j = 1:numEstimates
        for k = 1:numNeurons
            if isempty(AllIndividualFits{j}{k}.Model)
                Estimates(k,j) = NaN;
                Averages(k,j) = NaN;
                PValues(k,j) = NaN;
                Performance(k,j) = NaN;
            else
                Estimates(k,j) = AllIndividualFits{j}{k}.Model(2); % first is always intercept
                Averages(k,j) = AllIndividualFits{j}{k}.Model(1); % first is always intercept
                PValues(k,j) = AllIndividualFits{j}{k}.Stats.p(2); % first is always intercept
                Performance(k,j) = AllIndividualFits{j}{k}.PredictionAccuracy;
            end
        end
    end
    
    % find the units with pValues<0.05
    whichSig = PValues<0.05;
    consistency = sum(whichSig,2);
    neurons = find(consistency>numEstimates*0.7);
    neuronIsSignificant = consistency>numEstimates*0.7;
    
    allPerformance = [allPerformance;mean(Performance,2)];
    allEstimates = [allEstimates;mean(Estimates,2)];
    allPVals = [allPVals;geomean(PValues,2)];
    allSignificance = [allSignificance;neuronIsSignificant];
    
    whichSession = [whichSession;i*ones(size(neuronIsSignificant))];
    
    if length(allSignificance) ~=length(whichSession)
        keyboard
    end
    
    % session wide performance
    PerformanceAll = nan(1,length(FIT_LOGISTIC{i}));
    
    for j = 1:length(FIT_LOGISTIC{i})
        PerformanceAll(j) = FIT_LOGISTIC{i}{j}.FullModel.PredictionAccuracy;
    end
    sessionPerformance = [sessionPerformance nanmean(PerformanceAll)];
    sessionID = [sessionID i];
end

%% histogram the performance
ax = axes;
SignificantPerformances =  allPerformance(logical(allSignificance));
[n,centers] = hist(allPerformance,30);
b = bar(centers,n);
b.FaceColor = [0.5 0.5 0.5];
b.EdgeColor = 'none';
hold on;

n1 = histc(SignificantPerformances,centers);
b1 = bar(centers,n1);
b1.FaceColor = 'b';
b1.EdgeColor = 'none';

plot([0.5 0.5],ax.YLim,'k--');
ax.YTick = [100 200 300];
ax.XTick = [100 200 300];
%% compare sessionPerformance with best performing neuron
bestPerformingNeurons = [];
meanPerformingNeurons = [];
numNeuronsThatSession = [];
for i = 1:length(sessionID)
    whichNeurons = whichSession==sessionID(i);
    performances = allPerformance(whichNeurons);
    if isempty(performances)
        keyboard
    end
    bestPerformingNeurons = [bestPerformingNeurons max(performances)];
    meanPerformingNeurons = [meanPerformingNeurons nanmean(performances)];
    numNeuronsThatSession = [numNeuronsThatSession sum(whichNeurons)];
end
figure;
scatter(bestPerformingNeurons,sessionPerformance,'ko'); hold on
axis equal
plot([0.5 0.7],[0.5 0.7])
figure;
for i = 1:length(bestPerformingNeurons)
    plot()
end

%% Performance split by contrast

allPerformance = [];
allSignificance = [];
whichSession = [];
allPerformanceByContrast = [];

for i = 1:length(FIT_LOGISTIC)
    if isempty(FIT_LOGISTIC{i})
        continue
    end
    AllIndividualFits = cell(1,length(FIT_LOGISTIC{1}));
    
    for j = 1:length(FIT_LOGISTIC{i})
        AllIndividualFits{j} = FIT_LOGISTIC{i}{j}.IndividualModels;
    end
    numNeurons = length(AllIndividualFits{1});
    Performance = nan(numNeurons,length(FIT_LOGISTIC{1}));
    for j = 1:length(FIT_LOGISTIC{i})
        for k = 1:numNeurons
            Performance(k,j) = AllIndividualFits{j}{k}.PredictionAccuracy;
        end
    end
    
    % find the units with pValues<0.05
    whichSig = PValues<0.05;
    consistency = sum(whichSig,2);
    neurons = find(consistency>6);
    neuronIsSignificant = consistency>6;
    
    allPerformance = [allPerformance;mean(Performance,2)];
    allSignificance = [allSignificance;neuronIsSignificant];
    
    whichSession = [whichSession;i*ones(size(neuronIsSignificant))];
    
    % now split the performance by contrast
    
    
    for j = 1:length(FIT_LOGISTIC{i})
        uniqueContrasts = unique(FIT_LOGISTIC{i}{j}.cTest);
        uniqueContrasts = uniqueContrasts(~isnan(uniqueContrasts));
        PerformanceByContrastAll = nan(numNeurons,length(uniqueContrasts),length(FIT_LOGISTIC{i}));
        for ctr = 1:length(uniqueContrasts)
            whichTrialThatContrast = (FIT_LOGISTIC{i}{j}.cTest==uniqueContrasts(ctr));
            resultsThatContrast = FIT_LOGISTIC{i}{j}.YTest(whichTrialThatContrast);
            for k = 1:numNeurons
                predictionForThoseTrials = FIT_LOGISTIC{i}{j}.IndividualModels{k}.YPred(whichTrialThatContrast)>0.5;
                PerformanceByContrastAll(k,ctr,i) = sum(predictionForThoseTrials==resultsThatContrast)/length(resultsThatContrast);
            end
        end
    end
    PerformanceByContrast = nanmean(PerformanceByContrastAll,3);

    allPerformanceByContrast = [allPerformanceByContrast;PerformanceByContrast];
end
