% location of data
spikeRate = load('C:\Users\ghosh\Desktop\analysis\DetailsAt500MS.mat');
loc2 = 'C:\Users\ghosh\Desktop\analysis\FitsForSessions_Shuffled_new';
% figure;
spikeCorrelationActual = [] ;
spikeCorrelationShuffle= [] ;
CorrelationEachSession = {};
for i = 10:19
    try
        disp(i)
        name = sprintf('FitThisSession%d_Shuffle.mat',i);
        shufflePerformance = load(fullfile(loc2,name));
        
        numNeurons = size(spikeRate.SPIKEDETAILS{i}{1}.spikeNumsActual,2);
        spikeCorrelationActual = nan(numNeurons,numNeurons);
        spikeCorrelationShuffle = nan(numNeurons,numNeurons,100);
        
        spikeCorrelationActual = corrcoef(spikeRate.SPIKEDETAILS{i}{1}.spikeNumsActual);
        for l = 1:100
            spikeCorrelationShuffle(:,:,l) = corrcoef(shufflePerformance.fitsThisSession{l}.shuffledSession.spikeRatesActual);
        end
        
        numCols = 3;
        xLoc = mod(i-1,numCols)+1;
        yLoc = floor((i-xLoc)/numCols) + 1;
        
        corrs1 = spikeCorrelationActual(logical(triu(ones(numNeurons),1)));
        corrs1 = corrs1(~isnan(corrs1));
        
        corrs2 = nanmean(spikeCorrelationShuffle,3);
        corrs2 = corrs2(logical(triu(ones(numNeurons),1)));
        corrs2 = corrs2(~isnan(corrs2));
        
        corrs = [corrs1;corrs2];
        cats = [ones(size(corrs1)); 2*ones(size(corrs2))];
        CorrelationEachSession{i}.corrs = corrs;
        CorrelationEachSession{i}.cats = cats;
%         g(xLoc,yLoc) = gramm('x',corrs,'color',cats);
%         g(xLoc,yLoc).stat_bin('normalization','probability','geom','stairs');
%         g(xLoc,yLoc).set_title(sprintf('session:%d',i));
%         g(xLoc,yLoc).no_legend();
        figure;
        g = gramm('x',corrs,'color',cats);
        g.stat_bin('normalization','probability','geom','stairs');
        g.set_title(sprintf('session:%d',i));
        g.no_legend();
        g.draw();
    catch ex
        getReport(ex)
%         keyboard
    end
end
% g.set_title('Relation between Shuffled vs Actual probabilities')
g.draw();