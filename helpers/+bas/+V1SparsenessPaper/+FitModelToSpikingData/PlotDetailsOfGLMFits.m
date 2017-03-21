%% plot the example session
if ~exist('DETAILS','var')
    load Details_SpikeDetails
end
contrasts = DETAILS{1}{1}.contrasts(1:5);
orientation = DETAILS{1}{1}.orientations(1:5);
durs = DETAILS{1}{1}.actualStimDurations(1:5);
spR = DETAILS{1}{1}.spikeRatesActual(1:5,1:20);

f = figure;
ax = axes; hold on;
maxSPR = max(spR(:));
for i = 1:5
    if orientation(i)>0
        orientationColor = 'r';
    else
        orientationColor = 'b';
    end
    contrastColor = (1-contrasts(i))*[1 1 1];
    r = rectangle('Position',[1,i,1,1]); r.FaceColor = orientationColor;r.EdgeColor = 'none';
    r = rectangle('Position',[2,i,1,1]); r.FaceColor = contrastColor;r.EdgeColor = 'none'; 
    r = rectangle('Position',[3,i,durs(i)/max(durs),1]); r.FaceColor = 'b';r.EdgeColor = 'none'; 
    
    for j = 1:20
        r = patch([5+j 6+j 6+j 5+j],[i,i,i+1,i+1],'green'); r.EdgeColor = 'none';r.FaceAlpha = spR(i,j)/maxSPR;
    end
%     text(1,i,sprintf('%d',i))
end
ax.YLim = [0 30];
ax.XLim = [0 30];
axis equal
%%
if ~exist('FITS','var')
    load FitsAllSessions_2
end

%% fill in the performance
for i = 1:length(FITS)
    for j = 1:length(FITS{i})
        for k = 1:length(FITS{i}{j}.IndividualModels)
            modelPrediction = FITS{i}{j}.IndividualModels{k}.YPred>0.5;
            FITS{i}{j}.IndividualModels{k}.PredictionAccuracy = sum(modelPrediction==FITS{i}{j}.YTest)/length(FITS{i}{j}.YTest);
        end        
    end
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
for i = 1:length(FITS)
    if isempty(FITS{i})
        continue
    end
    AllIndividualFits = cell(1,length(FITS{1}));
    
    for j = 1:length(FITS{i})
        AllIndividualFits{j} = FITS{i}{j}.IndividualModels;
    end
    numNeurons = length(AllIndividualFits{1});
    Estimates = nan(numNeurons,length(FITS{1}));
    PValues = nan(numNeurons,length(FITS{1}));
    Performance = nan(numNeurons,length(FITS{1}));
    for j = 1:length(FITS{i})
        for k = 1:numNeurons
            Estimates(k,j) = AllIndividualFits{j}{k}.Model.Coefficients.Estimate(2); % first is always intercept
            PValues(k,j) = AllIndividualFits{j}{k}.Model.Coefficients.pValue(2); % first is always intercept
            Performance(k,j) = AllIndividualFits{j}{k}.PredictionAccuracy;
        end
    end
    
    % find the units with pValues<0.05
    whichSig = PValues<0.05;
    consistency = sum(whichSig,2);
    neurons = find(consistency>6);
    neuronIsSignificant = consistency>6;
    
    allPerformance = [allPerformance;mean(Performance,2)];
    allEstimates = [allEstimates;mean(Estimates,2)];
    allPVals = [allPVals;geomean(PValues,2)];
    allSignificance = [allSignificance;neuronIsSignificant];
    
    whichSession = [whichSession;i*ones(size(neuronIsSignificant))];
    
    if length(allSignificance) ~=length(whichSession)
        keyboard
    end
    
    % sessoin wide performance
    PerformanceAll = nan(1,length(FITS{i}));
    
    for j = 1:length(FITS{i})
        PerformanceAll(j) = FITS{i}{j}.FullModel.PredictionAccuracy;
    end
    sessionPerformance = [sessionPerformance mean(PerformanceAll)];
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
numNeuronsThatSession = [];
for i = 1:length(sessionID)
    whichNeurons = whichSession==sessionID(i);
    bestPerformanceThatSession = allPerformance(whichNeurons&allSignificance);
    bestPerformingNeurons = [bestPerformingNeurons max(bestPerformanceThatSession)];
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

for i = 1:length(FITS)
    if isempty(FITS{i})
        continue
    end
    AllIndividualFits = cell(1,length(FITS{1}));
    
    for j = 1:length(FITS{i})
        AllIndividualFits{j} = FITS{i}{j}.IndividualModels;
    end
    numNeurons = length(AllIndividualFits{1});
    Performance = nan(numNeurons,length(FITS{1}));
    for j = 1:length(FITS{i})
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
    
    
    for j = 1:length(FITS{i})
        uniqueContrasts = unique(FITS{i}{j}.cTest);
        uniqueContrasts = uniqueContrasts(~isnan(uniqueContrasts));
        PerformanceByContrastAll = nan(numNeurons,length(uniqueContrasts),length(FITS{i}));
        for ctr = 1:length(uniqueContrasts)
            whichTrialThatContrast = (FITS{i}{j}.cTest==uniqueContrasts(ctr));
            resultsThatContrast = FITS{i}{j}.YTest(whichTrialThatContrast);
            for k = 1:numNeurons
                predictionForThoseTrials = FITS{i}{j}.IndividualModels{k}.YPred(whichTrialThatContrast)>0.5;
                PerformanceByContrastAll(k,ctr,i) = sum(predictionForThoseTrials==resultsThatContrast)/length(resultsThatContrast);
            end
        end
    end
    PerformanceByContrast = nanmean(PerformanceByContrastAll,3);

    allPerformanceByContrast = [allPerformanceByContrast;PerformanceByContrast];
end
