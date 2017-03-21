%% plot the example session
if ~exist('DETAILS','var')
    load DetailsAt500MS
    DETAILS = SPIKEDETAILS;
    clear SPIKEDETAILS;
end
relevantAnalysis = 11; % the AtVariousTimeScales has analysis at 11 for 500 ms from stim onset.
numTrialTop = 300;
numNeurons = 58;
contrasts = DETAILS{1}{relevantAnalysis}.contrasts(1:numTrialTop);
orientation = DETAILS{1}{relevantAnalysis}.orientations(1:numTrialTop);
durs = DETAILS{1}{relevantAnalysis}.actualStimDurations(1:numTrialTop);
spR = DETAILS{1}{relevantAnalysis}.spikeRatesActual(1:numTrialTop,1:numNeurons).*repmat(durs,1,numNeurons);

f = figure;
ax = axes; hold on;
maxSPR = max(spR(:));
for i = 1:numTrialTop
    if orientation(i)>0
        orientationColor = 'r';
    else
        orientationColor = 'b';
    end
    contrastColor = (1-contrasts(i))*[1 1 1];
    r = rectangle('Position',[1,i,1,1]); r.FaceColor = orientationColor;r.EdgeColor = 'none';
    r = rectangle('Position',[2,i,1,1]); r.FaceColor = contrastColor;r.EdgeColor = 'none'; 
    r = rectangle('Position',[3,i,durs(i)/max(durs),1]); r.FaceColor = 'b';r.EdgeColor = 'none'; 
    
    for j = 1:numNeurons
        r = patch([5+j 6+j 6+j 5+j],[i,i,i+1,i+1],'green'); r.EdgeColor = 'none';r.FaceAlpha = max(0.1,spR(i,j)/maxSPR);
    end
    
    % find number of neurons that fired atleast one spike
    nThatSpiked = sum(spR(i,:)>0);
    r = rectangle('Position',[numNeurons+8,i,nThatSpiked/numNeurons,1]); r.FaceColor = 'k';r.EdgeColor = 'none'; 
    
    % find average firing rates across population
    r = rectangle('Position',[numNeurons+10,i,nanmean(spR(i,:))/2,1]); r.FaceColor = 'k';r.EdgeColor = 'none'; 
%     text(1,i,sprintf('%d',i))
end
% ax.YLim = [0 30];
% ax.XLim = [0 30];
% axis equal
%% get number of neurons
numNeurons = [];
for i = 1:58
    try
    numNeurons = [numNeurons size(DETAILS{i}{relevantAnalysis}.spikeRatesActual,2)];
    catch ex
        numNeurons = [numNeurons nan];
    end
end
%% get the mean fraction and firing rates for example session
relevantAnalysis = 11; % the AtVariousTimeScales has analysis at 11 for 500 ms from stim onset.
c = DETAILS{1}{relevantAnalysis}.contrasts;
or = DETAILS{1}{relevantAnalysis}.orientations;
durs = DETAILS{1}{relevantAnalysis}.actualStimDurations;
spR = DETAILS{1}{relevantAnalysis}.spikeRatesActual.*repmat(durs,1,58);
spR(isnan(spR)) = 0;

f = sum(spR>0,2)/58;
mean(f),std(f)

disp(mean(f(c==0))),disp(std(f(c==0)))

disp(mean(f(c==0.15))),disp(std(f(c==0.15)))

disp(mean(f(c==1))),disp(std(f(c==1)))

%% now do it across the sessions
F = [];
C = [];
OR = [];
DURS = [];
SESSNUM = [];
for i = setdiff(1:58,[11,35])
    relevantAnalysis = 1; % the AtVariousTimeScales has analysis at 11 for 500 ms from stim onset.
    c = DETAILS{i}{relevantAnalysis}.contrasts;
    or = DETAILS{i}{relevantAnalysis}.orientations;
    durs = DETAILS{i}{relevantAnalysis}.actualStimDurations;
    
    goods = ~isnan(c) & ~isnan(or) & ~isnan(durs);
    spR = DETAILS{i}{relevantAnalysis}.spikeRatesActual;
    
    numNeurons = size(spR,2);
    if ~numNeurons ||~any(goods)
        continue;
    end
    spR = spR.*repmat(durs,1,numNeurons);
    spR(isnan(spR)) = 0;
    
    c = c(goods);
    or = or(goods);
    durs = durs(goods);
    spR = spR(goods,:);
    
    f = sum(spR>0,2)/numNeurons;
    
    F = [F;f];
    C = [C;c];
    OR = [OR;or];
    DURS = [DURS;durs];
    SESSNUM = [SESSNUM;i*ones(size(f))];
end

%% plot by contrast
g=gramm('x',C,'y',F);
g.stat_boxplot();
g.set_names('x','Contrast','y','Fraction','color','Session');
figure('Position',[100 100 800 400]);
g.draw();

%% plot By DURS
DURSALTERNATE = DURS;
DURSALTERNATE(DURSALTERNATE<0.055) = 0.05;
DURSALTERNATE(DURSALTERNATE>=0.055 & DURSALTERNATE<0.11) = 0.1;
DURSALTERNATE(DURSALTERNATE>=0.11 & DURSALTERNATE<0.19) = 0.15;
DURSALTERNATE(DURSALTERNATE>=0.19 & DURSALTERNATE<0.24) = 0.2;
DURSALTERNATE(DURSALTERNATE>=0.24 & DURSALTERNATE<0.31) = 0.3;
DURSALTERNATE(DURSALTERNATE>=0.31 & DURSALTERNATE<0.41) = 0.4;
DURSALTERNATE(DURSALTERNATE>=0.41) = 0.5;

g=gramm('x',DURSALTERNATE,'y',F,'color',C);
g.stat_boxplot();
g.set_names('x','Contrast','y','Fraction','color','Session');
figure('Position',[100 100 800 400]);
g.draw();

%% get mean population fraction at each session
popFrac = [];
for i = 1:58
    popFrac =[popFrac mean(F(SESSNUM==i))];
end

%% get mean population fraction at each session as a functin of C
popFracByContrast = [];
for i = 1:58
    popFracByContrast =[popFracByContrast; [mean(F(SESSNUM==i & C==0)) mean(F(SESSNUM==i & C==0.15)) mean(F(SESSNUM==i & C==1))]];
end

%% get mean population fraction at each session as a functin of C at DURSAL
popFracByContrastAt100 = [];
for i = 1:58
    popFracByContrastAt100 =[popFracByContrastAt100; [mean(F(SESSNUM==i & C==0 & DURSALTERNATE==0.1)) mean(F(SESSNUM==i & C==0.15& DURSALTERNATE==0.1)) mean(F(SESSNUM==i & C==1& DURSALTERNATE==0.1))]];
end

%% get mean population fraction at each session as a functin of DURS at C = 0.15
popFracByDurationAt0C = [];
for i = 1:58
    popFracByDurationAt0C =[popFracByDurationAt0C; ...
        [mean(F(SESSNUM==i & C==0 & DURSALTERNATE==0.05)) ...
        mean(F(SESSNUM==i & C==0 & DURSALTERNATE==0.1)) ...
        mean(F(SESSNUM==i & C==0 & DURSALTERNATE==0.15)) ...
        mean(F(SESSNUM==i & C==0 & DURSALTERNATE==0.2)) ...
        mean(F(SESSNUM==i & C==0 & DURSALTERNATE==0.3)) ...
        mean(F(SESSNUM==i & C==0 & DURSALTERNATE==0.4)) ...
        mean(F(SESSNUM==i & C==0 & DURSALTERNATE==0.5)) ...
        ]];
end
%% get mean population fraction at each session as a functin of DURS at C = 0.15
popFracByDurationAtLoC = [];
for i = 1:51
    popFracByDurationAtLoC =[popFracByDurationAtLoC; ...
        [mean(F(SESSNUM==i & C==0.15 & DURSALTERNATE==0.05)) ...
        mean(F(SESSNUM==i & C==0.15 & DURSALTERNATE==0.1)) ...
        mean(F(SESSNUM==i & C==0.15 & DURSALTERNATE==0.15)) ...
        mean(F(SESSNUM==i & C==0.15 & DURSALTERNATE==0.2)) ...
        mean(F(SESSNUM==i & C==0.15 & DURSALTERNATE==0.3)) ...
        mean(F(SESSNUM==i & C==0.15 & DURSALTERNATE==0.4)) ...
        mean(F(SESSNUM==i & C==0.15 & DURSALTERNATE==0.5)) ...
        ]];
end
%% are they any different?
Sigs = nan(7,7);
pVals = Sigs;
for i = 1:7
    for j = 1:7
        [p,h,stats] = ranksum(popFracByDurationAtLoC(:,i),popFracByDurationAtLoC(:,j));
        Sigs(i,j) = h;
        pVals(i,j) = p;
    end
end

figure; hold on;
plot(popFracByDurationAtLoC(:,1:4)','k')

for i = 1:4
    m = nanmean(popFracByDurationAtLoC(:,i));
    sd = nanstd(popFracByDurationAtLoC(:,i));
    n = sum(~isnan(popFracByDurationAtLoC(:,i)));
    plot(i,m,'kd');
    plot([i i],[m+2*sd/sqrt(n) m-2*sd/sqrt(n)]);
end
set(gca,'XLim',[0.5 4.5])
set(gca,'YLim',[0 1])
set(gca,'XTick',[1 2 3])
set(gca,'YTick',[0 0.25 0.5 0.75 1])
%% get mean population fraction at each session as a functin of DURS at C = 1
popFracByDurationAtHiC = [];
for i = 1:51
    popFracByDurationAtHiC =[popFracByDurationAtHiC; ...
        [mean(F(SESSNUM==i & C==1 & DURSALTERNATE==0.05)) ...
        mean(F(SESSNUM==i & C==1 & DURSALTERNATE==0.1)) ...
        mean(F(SESSNUM==i & C==1 & DURSALTERNATE==0.15)) ...
        mean(F(SESSNUM==i & C==1 & DURSALTERNATE==0.2)) ...
        mean(F(SESSNUM==i & C==1 & DURSALTERNATE==0.3)) ...
        mean(F(SESSNUM==i & C==1 & DURSALTERNATE==0.4)) ...
        mean(F(SESSNUM==i & C==1 & DURSALTERNATE==0.5)) ...
        ]];
end

%%

relevantAnalysis = 11; % the AtVariousTimeScales has analysis at 11 for 500 ms from stim onset.
c = DETAILS{1}{relevantAnalysis}.contrasts;
or = DETAILS{1}{relevantAnalysis}.orientations;
durs = DETAILS{1}{relevantAnalysis}.actualStimDurations;
spR = DETAILS{1}{relevantAnalysis}.spikeRatesActual.*repmat(durs,1,58);
spR(isnan(spR)) = 0;

dursFixed = bas.V1SparsenessPaper.CorrelationAnalyses.fixDurations(durs);
uniqC = unique(c(~isnan(c)));
uniqDur = unique(dursFixed(~isnan(dursFixed)));
spR = round(spR);

spikeResponsesByStimConditions = cell(2,length(uniqC), length(uniqDur));

for i = 1:length(uniqC)
    for j = 1:length(uniqDur)
        whichTrialsR = c==uniqC(i) & dursFixed==uniqDur(j) & or>0;
        spikeResponsesByStimConditions{1,i,j} = spR(whichTrialsR,:);
        whichTrialsL = c==uniqC(i) & dursFixed==uniqDur(j) & or<0;
        spikeResponsesByStimConditions{2,i,j} = spR(whichTrialsL,:);
        
    end
end














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
