
sessionPerformance = [];
numNeuronsInSession = [];
numSignificantNeuronsInSession = [];

% location of data
loc1 = 'C:\Users\ghosh\Desktop\analysis\FitsIndividual_1';
loc2 = 'C:\Users\ghosh\Desktop\analysis\FitAllShuffled';

AllSessionsPerformanceMean = [] ;
AllSessionsPerformanceStd = [] ;
ShuffledSessionPerformance = {};
numNeurons = [];
for i = 1:58
    disp(i)
    try
    name = sprintf('FitThisSession%d500.mat',i);
    sessionPerformance = load(fullfile(loc1,name));
    name = sprintf('FitThisSession%d_Shuffle.mat',i);
    shufflePerformance = load(fullfile(loc2,name));
    
    % get full model performance
    fullSessionPerf = [];
    for j = 1:length(sessionPerformance.fitsThisSession)
        fullSessionPerf = [fullSessionPerf sessionPerformance.fitsThisSession{j}.FullModel.PredictionAccuracy];
    end
    AllSessionsPerformanceMean(end+1) = nanmean(fullSessionPerf);
    AllSessionsPerformanceStd(end+1) = nanstd(fullSessionPerf);
    numNeurons(end+1) = length(sessionPerformance.fitsThisSession{1}.uid);
    % now deal with shuffle
    ShuffledSessionPerformance{i} = [];
    for shuffle = 1:100
        ShuffledSessionPerformance{i}(end+1) = nanmean(shufflePerformance.fitsThisSession{shuffle}.LogisticRegression.perfs);
    end
    catch ex
        getReport(ex)
        AllSessionsPerformanceMean(i) = NaN;
        AllSessionsPerformanceStd(i) = NaN;
        numNeurons(i) = NaN;
        ShuffledSessionPerformance{i} = [];
    end
    
end

%% plotting
figure;
axes; hold on
[~,order] = sort(AllSessionsPerformanceMean);
for i = 1:58
    m = AllSessionsPerformanceMean(order(i));
    sd = AllSessionsPerformanceStd(order(i));
    
%     plot([m-2*sd m+2*sd],[i i],'k');
    shuffs = ShuffledSessionPerformance{order(i)};
    shuffsLo = quantile(shuffs,0.025);
    shuffsHi = quantile(shuffs,0.975);
    plot([shuffsLo shuffsHi],[i i],'k')
    
    if m<shuffsLo
        plot(m,i,'rd');
    elseif m>shuffsHi
        plot(m,i,'gd');
    else
        plot(m,i,'kd');
    end
%     for j = 1:length(shuffs)
%         plot([shuffs(j) shuffs(j)],[i-0.25 i+0.25],'k');
%     end
    
end

%% improvement in performance
performancesForShuffled = cellfun(@nanmean,ShuffledSessionPerformance);
actualPerformance = AllSessionsPerformanceMean;
changeInPerformance = performancesForShuffled-actualPerformance;
scatter(numNeurons,changeInPerformance)