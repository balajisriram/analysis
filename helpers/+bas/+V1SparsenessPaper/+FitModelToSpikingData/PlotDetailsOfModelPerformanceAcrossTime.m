% 
% AllPerformances
% AllEstimates
% AllPVals
% AllSignificance
for num = [1:13];
    out = bas.V1SparsenessPaper.FitModelToSpikingData.PlotDetailsOfLogisticFits(num);
    if num ==1
        AllPerformances = out.allPerformance;
        AllEstimates = out.allEstimates;
        AllPVals = out.allPVals;
        AllSignificance = out.allSignificance;
        UnitIDs = out.uID;
    else
        AllPerformances = [AllPerformances out.allPerformance];
        AllEstimates = [AllEstimates out.allEstimates];
        AllPVals = [AllPVals out.allPVals];
        AllSignificance = [AllSignificance out.allSignificance];
    end
end
%%
i = 1; UnitPerformanceTable10MS  = table(UnitIDs',AllPerformances(:,i) ,AllEstimates(:,i),AllPVals(:,i),AllSignificance(:,i),'VariableNames',{'uID','Performance10MS', 'Estimates10MS', 'PVals10MS', 'Significance10MS' });
i = 2; UnitPerformanceTable25MS  = table(UnitIDs',AllPerformances(:,i) ,AllEstimates(:,i),AllPVals(:,i),AllSignificance(:,i),'VariableNames',{'uID','Performance25MS', 'Estimates25MS', 'PVals25MS', 'Significance25MS' });
i = 3; UnitPerformanceTable50MS  = table(UnitIDs',AllPerformances(:,i) ,AllEstimates(:,i),AllPVals(:,i),AllSignificance(:,i),'VariableNames',{'uID','Performance50MS', 'Estimates50MS', 'PVals50MS', 'Significance50MS' });
i = 4; UnitPerformanceTable75MS  = table(UnitIDs',AllPerformances(:,i) ,AllEstimates(:,i),AllPVals(:,i),AllSignificance(:,i),'VariableNames',{'uID','Performance75MS', 'Estimates75MS', 'PVals75MS', 'Significance75MS' });
i = 5; UnitPerformanceTable100MS = table(UnitIDs',AllPerformances(:,i) ,AllEstimates(:,i),AllPVals(:,i),AllSignificance(:,i),'VariableNames',{'uID','Performance100MS','Estimates100MS','PVals100MS','Significance100MS'});
i = 6; UnitPerformanceTable150MS = table(UnitIDs',AllPerformances(:,i) ,AllEstimates(:,i),AllPVals(:,i),AllSignificance(:,i),'VariableNames',{'uID','Performance150MS','Estimates150MS','PVals150MS','Significance150MS'});
i = 7; UnitPerformanceTable200MS = table(UnitIDs',AllPerformances(:,i) ,AllEstimates(:,i),AllPVals(:,i),AllSignificance(:,i),'VariableNames',{'uID','Performance200MS','Estimates200MS','PVals200MS','Significance200MS'});
i = 8; UnitPerformanceTable250MS = table(UnitIDs',AllPerformances(:,i) ,AllEstimates(:,i),AllPVals(:,i),AllSignificance(:,i),'VariableNames',{'uID','Performance250MS','Estimates250MS','PVals250MS','Significance250MS'});
i = 9; UnitPerformanceTable300MS = table(UnitIDs',AllPerformances(:,i) ,AllEstimates(:,i),AllPVals(:,i),AllSignificance(:,i),'VariableNames',{'uID','Performance300MS','Estimates300MS','PVals300MS','Significance300MS'});
i = 10;UnitPerformanceTable350MS = table(UnitIDs',AllPerformances(:,i) ,AllEstimates(:,i),AllPVals(:,i),AllSignificance(:,i),'VariableNames',{'uID','Performance350MS','Estimates350MS','PVals350MS','Significance350MS'});
i = 11;UnitPerformanceTable400MS = table(UnitIDs',AllPerformances(:,i) ,AllEstimates(:,i),AllPVals(:,i),AllSignificance(:,i),'VariableNames',{'uID','Performance400MS','Estimates400MS','PVals400MS','Significance400MS'});
i = 12;UnitPerformanceTable450MS = table(UnitIDs',AllPerformances(:,i) ,AllEstimates(:,i),AllPVals(:,i),AllSignificance(:,i),'VariableNames',{'uID','Performance450MS','Estimates450MS','PVals450MS','Significance450MS'});
i = 13;UnitPerformanceTable500MS = table(UnitIDs',AllPerformances(:,i) ,AllEstimates(:,i),AllPVals(:,i),AllSignificance(:,i),'VariableNames',{'uID','Performance500MS','Estimates500MS','PVals500MS','Significance500MS'});

save('UnitPerformanceTables.mat','UnitPerformanceTable10MS','UnitPerformanceTable25MS','UnitPerformanceTable50MS','UnitPerformanceTable75MS','UnitPerformanceTable100MS',...
    'UnitPerformanceTable150MS','UnitPerformanceTable200MS','UnitPerformanceTable250MS','UnitPerformanceTable300MS','UnitPerformanceTable350MS','UnitPerformanceTable400MS',...
    'UnitPerformanceTable450MS','UnitPerformanceTable500MS');
%% plots

figure;


%% all means
% m = nanmean(AllPerformances);
% s = nanstd(AllPerformances);
% n = sum(~isnan(AllPerformances));
% sem = s./sqrt(n);
% 
% subplot(4,2,1);
% errorbar(log10([50 100 200 500 1000 5000]), m(7:12), 2*sem(7:12),'k')
% 
% subplot(4,2,2);
% errorbar(log10([20 50 100 200 500 1000]), m(1:6), 2*sem(1:6),'k')
% 
% %% only significant
% mSig = nan(size(m));
% sSig = mSig;
% nSig = mSig;
% semSig = mSig;
% for i = 1:12
%    pThat =  AllPerformances(:,i);
%    sigThat = logical(AllSignificance(:,i));
%    
%    mSig(i) = nanmean(pThat(sigThat));
%    sSig(i) = nanstd(pThat(sigThat));
%    nSig(i) = length(pThat(sigThat));
%    semSig(i) = sSig(i)/sqrt(nSig(i));
% end
% subplot(4,2,1); hold on;
% errorbar(log10([50 100 200 500 1000 5000]), mSig(7:12), 2*semSig(7:12),'b');
% plot([1 4],[0.5 0.5],'k--')
% subplot(4,2,2);hold on;
% errorbar(log10([20 50 100 200 500 1000]), mSig(1:6), 2*semSig(1:6),'b')
% plot([1 4],[0.5 0.5],'k--')
% %% Number of significant units
% subplot(4,2,3); hold on;
% bar(log10([50 100 200 500 1000 5000]), nSig(7:12),'b');
% subplot(4,2,4); hold on;
% bar(log10([20 50 100 200 500 1000]), nSig(1:6),'b');
% 
% %% Plotting probabilitiesw of Significance
% 
% pRelevant = repmat(AllSignificance(:,3),1,12);
% vals = sum(pRelevant.*AllSignificance)./sum(pRelevant);
% 
% subplot(4,2,5);
% plot(log10([50 100 200 500 1000 5000]), vals(7:12),'b');
% 
% subplot(4,2,6);
% plot(log10([20 50 100 200 500 1000]), vals(1:6),'b');

%% all means
m = nanmean(AllPerformances);
s = nanstd(AllPerformances);
n = sum(~isnan(AllPerformances));
sem = s./sqrt(n);

subplot(4,1,1:2);
errorbar(([0 25 50 75 100 150 200 250 300 350 400 450 500]), m, 2*sem,'k')

%% only significant
mSig = nan(size(m));
sSig = mSig;
nSig = mSig;
semSig = mSig;
for i = 1:13
   pThat =  AllPerformances(:,i);
   sigThat = logical(AllSignificance(:,i));
   
   mSig(i) = nanmean(pThat(sigThat));
   sSig(i) = nanstd(pThat(sigThat));
   nSig(i) = length(pThat(sigThat));
   semSig(i) = sSig(i)/sqrt(nSig(i));
end
subplot(4,1,1:2); hold on;
errorbar(([0 25 50 75 100 150 200 250 300 350 400 450 500]), mSig, 2*semSig,'b');
plot([0 500],[0.5 0.5],'k--')

%% Number of significant units
subplot(4,1,3); hold on;
bar([0 25 50 75 100 150 200 250 300 350 400 450 500], nSig,'b');


%% Plotting probabilitiesw of Significance

pRelevant = repmat(AllSignificance(:,5),1,13);
vals = sum(pRelevant.*AllSignificance)./sum(pRelevant);

subplot(4,1,4);
plot([0 25 50 75 100 150 200 250 300 350 400 450 500], vals,'b');
