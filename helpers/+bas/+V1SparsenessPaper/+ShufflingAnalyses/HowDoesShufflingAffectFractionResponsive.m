%% load the data
if ~exist('DETAILS','var')
    load DetailsAt500MS
    DETAILS = SPIKEDETAILS;
    clear SPIKEDETAILS;
end

%% 
for i = 3 %setdiff(1:58,[11,35])
    relevantAnalysis = 1; % the AtVariousTimeScales has analysis at 11 for 500 ms from stim onset.
    
    separatedResponses = bas.V1SparsenessPaper.CorrelationAnalyses.separateResponsesByStimulus(DETAILS{i});
    fOrig = bas.V1SparsenessPaper.ShufflingAnalyses.getFractionResponsive(separatedResponses,'vector');
    
    
    hold on;
    fNews = [];
    for j = 1:100
        shuffledSession = bas.V1SparsenessPaper.CorrelationAnalyses.shuffleResponses(separatedResponses);
        fNew = bas.V1SparsenessPaper.ShufflingAnalyses.getFractionResponsive(shuffledSession,'vector');
        fNews = [fNews fNew];
%         if kstest2(fOrig,fNew)
%             boxplot(fNew,'plotstyle','compact','colors','g');
%         else
%             boxplot(fNew,'plotstyle','compact','colors','g');
%         end
    end
    
    boxplot([fOrig fNews],'plotstyle','compact','colors','k');
    
end
