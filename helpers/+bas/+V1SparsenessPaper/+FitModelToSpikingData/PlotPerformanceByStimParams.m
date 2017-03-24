%% Performance split by contrast

allPerformance = [];
allSignificance = [];
whichSession = [];
allPerformanceByContrast = [];
loc = 'C:\Users\ghosh\Desktop\analysis\FitsIndividual_1';

AllPerformances = [];
AllSignificance = [];
AllSessions = [];

for i = 1:58
    disp(i)
    try
        try
            name = sprintf('FitThisSession%d500.mat',i);
            load(fullfile(loc,name));
        catch ex
            getReport(ex)
            continue
        end
        
        
        if isempty(fitsThisSession)
            continue
        end
        numNeurons = length(fitsThisSession{1}.IndividualModels);
        numSplits = length(fitsThisSession);
        
        AllIndividualFits = cell(numNeurons);
        AllUniqueContrasts = [0 0.15 1];
        AllUniqueDurations = [0.05 0.1 0.15 0.2 0.3 0.4 0.5];
        

        for j = 1:numNeurons
            AllIndividualFits{j}.PerformanceByCondition = NaN(length(AllUniqueContrasts),length(AllUniqueDurations),numSplits);
            PValues = nan(1,numSplits);
            for k = 1:numSplits
                YTest = fitsThisSession{k}.YTest;
                cTest = fitsThisSession{k}.cTest;
                dTest = bas.V1SparsenessPaper.CorrelationAnalyses.fixDurations(fitsThisSession{k}.dTest);
                
                for l =1:length(AllUniqueContrasts)
                    for m =1:length(AllUniqueDurations)
                        whichThatContrastThatDuration = cTest == AllUniqueContrasts(l) & dTest == AllUniqueDurations(m);
                        try
                            AllIndividualFits{j}.PerformanceByCondition(l,m,k) = ...
                                mean(fitsThisSession{k}.IndividualModels{j}.YPred(whichThatContrastThatDuration)==...
                                YTest(whichThatContrastThatDuration));
                            PValues(k) = fitsThisSession{k}.IndividualModels{j}.Stats.p(2);
                        catch ex
                            AllIndividualFits{j}.PerformanceByCondition(l,m,k) = nan;
                            PValues(k) = NaN;
                        end
                    end
                end
            end
            AllPerformances(:,:,end+1) = nanmean(AllIndividualFits{j}.PerformanceByCondition,3);
            AllSessions(end+1) = i;
            AllSignificance(end+1) = sum(PValues<0.05)>60;
        end
    catch ex
        keyboard
    end

end
temp = AllPerformances;
temp(:,:,1) = [];
%%
mByCAndD = nanmean(temp,3);
sdByCAndD = nanstd(temp,[],3);
d = [50 100 150 200];
figure;
plot(d,mByCAndD(2,1:4),'color',[0.5 0.5 0.5],'d-'); hold on;
plot(d,mByCAndD(3,1:4),'color','kd-');

%% by significant
mByCAndDSig = nanmean(temp(:,:,logical(AllSignificance)),3);
sdByCAndDSig = nanstd(temp(:,:,logical(AllSignificance)),[],3);
d = [50 100 150 200];
figure;

plot(d,mByCAndDSig(2,1:4),'color',[0.5 0.5 0.5],'Marker','d','MarkerFaceColor',[0.5 0.5 0.5]); hold on;
for j = 1:4
    plot([d(j) d(j)],[mByCAndDSig(2,j)-2*sdByCAndDSig(2,j)/sqrt(154) mByCAndDSig(2,j)+2*sdByCAndDSig(2,j)/sqrt(154)],'color',[0.5 0.5 0.5])
end
plot(d,mByCAndDSig(3,1:4),'color','k','Marker','d','MarkerFaceColor','k');
for j = 1:4
    plot([d(j) d(j)],[mByCAndDSig(3,j)-2*sdByCAndDSig(3,j)/sqrt(154) mByCAndDSig(3,j)+2*sdByCAndDSig(3,j)/sqrt(154)],'color','k')
end

set(gca,'xLim',[0 250])