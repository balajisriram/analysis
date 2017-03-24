%% get the data
allPerformance = out.allPerformance;
allSignificance = out.allSignificance;
allEstimates = out.allEstimates;
allPVals = out.allPVals;
whichSession = out.whichSession;
sessionID = out.sessionID;
sessionPerformance = out.sessionPerformance;

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

plot(ci,[100,100],'color',[0.5 0.5 0.5]);
%% compare sessionPerformance with best performing neuron
bestPerformingNeurons = [];
meanPerformingNeurons = [];
numNeuronsThatSession = [];
numSignificantNeurons = [];
for i = 1:length(sessionID)
    whichNeurons = whichSession==sessionID(i);
    whichSignificant = allSignificance(whichNeurons);
    performances = allPerformance(whichNeurons);
    if isempty(performances)
        bestPerformingNeurons = [bestPerformingNeurons NaN];
        meanPerformingNeurons = [meanPerformingNeurons NaN];
        numNeuronsThatSession = [numNeuronsThatSession NaN];
        numSignificantNeurons = [numSignificantNeurons NaN];
    else
        bestPerformingNeurons = [bestPerformingNeurons max(performances)];
        meanPerformingNeurons = [meanPerformingNeurons nanmean(performances)];
        numNeuronsThatSession = [numNeuronsThatSession sum(whichNeurons)];
        numSignificantNeurons = [numSignificantNeurons sum(whichSignificant)];
    end
end
figure;
scatter(bestPerformingNeurons,sessionPerformance,'ko'); hold on
axis equal
plot([0.5 0.7],[0.5 0.7]);
xlabel('Best Performing Neuron');
ylabel('Session Performance');


figure;
scatter(meanPerformingNeurons,sessionPerformance,'ko'); hold on
axis equal
plot([0.5 0.7],[0.5 0.7]);
xlabel('Mean Performing Neuron');
ylabel('Session Performance');

%%
figure;hold on
for i = 1:length(bestPerformingNeurons)
    plot(numNeuronsThatSession(i),bestPerformingNeurons(i),'r^');
    plot(numNeuronsThatSession(i),sessionPerformance(i),'gd');
    
    if sessionPerformance(i)>bestPerformingNeurons(i)
        plot([numNeuronsThatSession(i) numNeuronsThatSession(i)],[bestPerformingNeurons(i) sessionPerformance(i)],'g');
    else
        plot([numNeuronsThatSession(i) numNeuronsThatSession(i)],[bestPerformingNeurons(i) sessionPerformance(i)],'r');
    end
end

%%

figure;
subplot(2,1,1); scatter(numNeuronsThatSession,sessionPerformance,'ko');xlabel('#Neurons');ylabel('Session Performance');
fit = polyfit(numNeuronsThatSession(~isnan(sessionPerformance)),sessionPerformance(~isnan(sessionPerformance)),1);
plot([0 100],polyval(fit,[0 100]),'r--')

subplot(2,1,2); scatter(numNeuronsThatSession,bestPerformingNeurons,'ko');xlabel('#Neurons');ylabel('Best Performance');

