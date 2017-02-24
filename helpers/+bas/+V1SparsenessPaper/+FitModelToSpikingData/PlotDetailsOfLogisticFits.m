%% Number of neurons that are significantly predictive of orientation
% neurons that are consistently predictive are predictive no matter what
% the training/testing splits are.
function out = PlotDetailsOfLogisticFits(num);
allPerformance = [];
allEstimates = [];
allPVals = [];
allSignificance = [];
uID = {};
whichSession = [];
sessionPerformance = [];
sessionID = [];

% location of data
loc = 'C:\Users\ghosh\Desktop\FitBySessionDetailed';
for i = 1:58
    try
        name = sprintf('FitThisSession%d_Detailed.mat',i);
        load(fullfile(loc,name));
    catch ex
        getReport(ex)
        continue
    end
    if isempty(fitsThisSession)
        continue;
    end
    FIT_LOGISTIC = {fitsThisSession{num,:}}; % 7 is window of length 0
    AllIndividualFits = cell(1,length(FIT_LOGISTIC));
     
    for j = 1:length(FIT_LOGISTIC)
        AllIndividualFits{j} = FIT_LOGISTIC{j}.IndividualModels;
    end
    
    % unitIDs
    [~ ,sessName] = fileparts(FIT_LOGISTIC{j}.sessionName);
    uIDsThis = FIT_LOGISTIC{j}.uid;
    
    unitIDsThis = {};
    for p = 1:length(uIDsThis)
        unitIDsThis{p} = sprintf('%s_%s',sessName,uIDsThis{p});
    end
    uID = {uID{:}, unitIDsThis{:}};
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
    PerformanceAll = nan(1,length(FIT_LOGISTIC));
    
    for j = 1:length(FIT_LOGISTIC)
        PerformanceAll(j) = FIT_LOGISTIC{j}.FullModel.PredictionAccuracy;
    end
    sessionPerformance = [sessionPerformance nanmean(PerformanceAll)];
    sessionID = [sessionID i];
end
out.uID = uID;

out.allPerformance = allPerformance;
out.allEstimates = allEstimates;
out.allPVals = allPVals;
out.allSignificance = allSignificance;

out.whichSession = whichSession;
out.sessionPerformance = sessionPerformance;
out.sessionID = sessionID;
end
% %% histogram the performance
% ax = axes;
% SignificantPerformances =  allPerformance(logical(allSignificance));
% [n,centers] = hist(allPerformance,30);
% b = bar(centers,n);
% b.FaceColor = [0.5 0.5 0.5];
% b.EdgeColor = 'none';
% hold on;
% 
% n1 = histc(SignificantPerformances,centers);
% b1 = bar(centers,n1);
% b1.FaceColor = 'b';
% b1.EdgeColor = 'none';
% 
% plot([0.5 0.5],ax.YLim,'k--');
% ax.YTick = [100 200 300];
% ax.XTick = [100 200 300];
% %% compare sessionPerformance with best performing neuron
% bestPerformingNeurons = [];
% meanPerformingNeurons = [];
% numNeuronsThatSession = [];
% for i = 1:length(sessionID)
%     whichNeurons = whichSession==sessionID(i);
%     performances = allPerformance(whichNeurons);
%     if isempty(performances)
%         keyboard
%     end
%     bestPerformingNeurons = [bestPerformingNeurons max(performances)];
%     meanPerformingNeurons = [meanPerformingNeurons nanmean(performances)];
%     numNeuronsThatSession = [numNeuronsThatSession sum(whichNeurons)];
% end
% figure;
% scatter(bestPerformingNeurons,sessionPerformance,'ko'); hold on
% axis equal
% plot([0.5 0.7],[0.5 0.7]);
% xlabel('Best Performing Neuron');
% ylabel('Session Performance');
% 
% %% 
% figure;hold on
% for i = 1:length(bestPerformingNeurons)
%     plot(numNeuronsThatSession(i),bestPerformingNeurons(i),'r^'); 
%     plot(numNeuronsThatSession(i),sessionPerformance(i),'gd'); 
%     
%     if sessionPerformance(i)>bestPerformingNeurons(i)
%         plot([numNeuronsThatSession(i) numNeuronsThatSession(i)],[bestPerformingNeurons(i) sessionPerformance(i)],'g');
%     else
%         plot([numNeuronsThatSession(i) numNeuronsThatSession(i)],[bestPerformingNeurons(i) sessionPerformance(i)],'r');
%     end
% end
% 
% %%
% 
% figure;
% subplot(2,1,1); scatter(numNeuronsThatSession,sessionPerformance,'ko');xlabel('#Neurons');ylabel('Session Performance');
% fit = polyfit(numNeuronsThatSession(~isnan(sessionPerformance)),sessionPerformance(~isnan(sessionPerformance)),1);
% plot([0 100],polyval(fit,[0 100]),'r--')
% 
% subplot(2,1,2); scatter(numNeuronsThatSession,bestPerformingNeurons,'ko');xlabel('#Neurons');ylabel('Best Performance');
% 
% %% Performance split by contrast
% 
% allPerformance = [];
% allSignificance = [];
% whichSession = [];
% allPerformanceByContrast = [];
% 
% for i = 1:length(FIT_LOGISTIC)
%     if isempty(FIT_LOGISTIC{i})
%         continue
%     end
%     AllIndividualFits = cell(1,length(FIT_LOGISTIC{1}));
%     
%     for j = 1:length(FIT_LOGISTIC{i})
%         AllIndividualFits{j} = FIT_LOGISTIC{i}{j}.IndividualModels;
%     end
%     numNeurons = length(AllIndividualFits{1});
%     Performance = nan(numNeurons,length(FIT_LOGISTIC{1}));
%     for j = 1:length(FIT_LOGISTIC{i})
%         for k = 1:numNeurons
%             Performance(k,j) = AllIndividualFits{j}{k}.PredictionAccuracy;
%         end
%     end
%     
%     % find the units with pValues<0.05
%     whichSig = PValues<0.05;
%     consistency = sum(whichSig,2);
%     neurons = find(consistency>6);
%     neuronIsSignificant = consistency>6;
%     
%     allPerformance = [allPerformance;mean(Performance,2)];
%     allSignificance = [allSignificance;neuronIsSignificant];
%     
%     whichSession = [whichSession;i*ones(size(neuronIsSignificant))];
%     
%     % now split the performance by contrast
%     
%     
%     for j = 1:length(FIT_LOGISTIC{i})
%         uniqueContrasts = unique(FIT_LOGISTIC{i}{j}.cTest);
%         uniqueContrasts = uniqueContrasts(~isnan(uniqueContrasts));
%         PerformanceByContrastAll = nan(numNeurons,length(uniqueContrasts),length(FIT_LOGISTIC{i}));
%         for ctr = 1:length(uniqueContrasts)
%             whichTrialThatContrast = (FIT_LOGISTIC{i}{j}.cTest==uniqueContrasts(ctr));
%             resultsThatContrast = FIT_LOGISTIC{i}{j}.YTest(whichTrialThatContrast);
%             for k = 1:numNeurons
%                 predictionForThoseTrials = FIT_LOGISTIC{i}{j}.IndividualModels{k}.YPred(whichTrialThatContrast);
%                 PerformanceByContrastAll(k,ctr,j) = sum(predictionForThoseTrials==resultsThatContrast)/length(resultsThatContrast);
%             end
%         end
%     end
%     PerformanceByContrast = nanmean(PerformanceByContrastAll,3);
%     
%     switch size(PerformanceByContrast)
%         case 2
%             keyboard
%         case 1
%         otherwise
%             % keep going
%     end
% 
%     allPerformanceByContrast = [allPerformanceByContrast;PerformanceByContrast];
% end
