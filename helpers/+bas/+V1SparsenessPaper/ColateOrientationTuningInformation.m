load Details_OrientationVector_Second

VECANG = [];
VECSTR = [];
OSIs = [];
FRs = [];

OSIMEANS = [];
OSISDs = [];
OSILEN = [];
OSIMINs = [];
OSIMAXs = [];
OSICILO = [];
OSICIHI = [];

VECANGMEANS = [];
VECSTRMEANS = [];
VECANGSDs = [];
VECSTRSDs = [];
VECANGLEN = [];
VECSTRLEN = [];
VECANGMINs = [];
VECSTRMINs = [];
VECANGMAXs = [];
VECSTRMAXs = [];
VECANGCILO = [];
VECSTRCILO = [];
VECANGCIHI = [];
VECSTRCIHI = [];

for i = 1:length(DETAILS)
    if isfield(DETAILS{i}{2},'vectors')
        numNeurons = length(DETAILS{i}{1}.firingRates);
        for j = 1:numNeurons
            FRs = [FRs DETAILS{i}{1}.firingRates(j)];
            
            VECANG = [VECANG DETAILS{i}{2}.vectors{j}.ang];
            VECSTR = [VECSTR DETAILS{i}{2}.vectors{j}.str];
            VECSTRMEANS = [VECSTRMEANS mean([DETAILS{i}{2}.vectorsJackKnife{j}.str])];
            VECANGMEANS = [VECANGMEANS mean([DETAILS{i}{2}.vectorsJackKnife{j}.ang])];
            VECSTRSDs = [VECSTRSDs std([DETAILS{i}{2}.vectorsJackKnife{j}.str])];
            VECANGSDs = [VECANGSDs std([DETAILS{i}{2}.vectorsJackKnife{j}.ang])];
            VECSTRLEN = [VECSTRLEN length([DETAILS{i}{2}.vectorsJackKnife{j}.str])];
            VECANGLEN = [VECANGLEN length([DETAILS{i}{2}.vectorsJackKnife{j}.ang])];
            VECSTRMINs = [VECSTRMINs min([DETAILS{i}{2}.vectorsJackKnife{j}.str])];
            VECANGMINs = [VECANGMINs min([DETAILS{i}{2}.vectorsJackKnife{j}.ang])];
            VECSTRMAXs = [VECSTRMAXs max([DETAILS{i}{2}.vectorsJackKnife{j}.str])];
            VECANGMAXs = [VECANGMAXs max([DETAILS{i}{2}.vectorsJackKnife{j}.ang])];
            
            VECSTRCILO = [VECSTRCILO quantile([DETAILS{i}{2}.vectorsJackKnife{j}.str],0.025)];
            VECANGCILO = [VECANGCILO quantile([DETAILS{i}{2}.vectorsJackKnife{j}.ang],0.025)];
            VECSTRCIHI = [VECSTRCIHI quantile([DETAILS{i}{2}.vectorsJackKnife{j}.str],0.975)];
            VECANGCIHI = [VECANGCIHI quantile([DETAILS{i}{2}.vectorsJackKnife{j}.ang],0.975)];
            
            OSIMEANS = [OSIMEANS nanmean(DETAILS{i}{3}.OSISubsample{j})];
            OSISDs = [OSISDs nanstd(DETAILS{i}{3}.OSISubsample{j})];
            OSILEN = [OSILEN length(DETAILS{i}{3}.OSISubsample{j})];
            OSIMINs = [OSIMINs min(DETAILS{i}{3}.OSISubsample{j})];
            OSIMAXs = [OSIMAXs max(DETAILS{i}{3}.OSISubsample{j})];
            OSICILO = [OSICILO quantile(DETAILS{i}{3}.OSISubsample{j},0.025)];
            OSICIHI = [OSICIHI quantile(DETAILS{i}{3}.OSISubsample{j},0.975)];
        end
        
        
    end
end

%%

f = figure;
ax = subplot(6,1,1);
hist(VECANGMEANS,50);
axis tight;

ax = subplot(6,1,2:6);

hold on
[sortedVECANG,order]  = sort(VECANGMEANS);

for i = 1:length(sortedVECANG)
    %     plot([VECANGMEANS(order(i))+VECANGSDs(order(i)) VECANGMEANS(order(i))-VECANGSDs(order(i))],[i i],'k');
    %     if (OSIs(order(i))> OSICILO(order(i))) && (OSIs(order(i))< OSICIHI(order(i)))
    %         plot(OSIs(order(i)),i,'b.');
    %     else
    if (VECANGMEANS(order(i))<0)
        plot(VECANGMEANS(order(i)),i,'b.');
    else
        plot(VECANGMEANS(order(i)),i,'r.');
    end
    %     end
    %     plot(OSIMEANS(order(i)),i,'b.');
end
axis tight

%% Only high OSIs 
which = OSIMEANS>0.3;
VECS = VECANGMEANS(which);


f = figure;
ax = subplot(6,1,1);
hist(VECS,50);
axis tight;

ax = subplot(6,1,2:6);

hold on
[sortedVECANG,order]  = sort(VECS);

for i = 1:length(sortedVECANG)
    %     plot([VECANGMEANS(order(i))+VECANGSDs(order(i)) VECANGMEANS(order(i))-VECANGSDs(order(i))],[i i],'k');
    %     if (OSIs(order(i))> OSICILO(order(i))) && (OSIs(order(i))< OSICIHI(order(i)))
    %         plot(OSIs(order(i)),i,'b.');
    %     else
    if (VECS(order(i))<0)
        plot(VECS(order(i)),i,'b.');
    else
        plot(VECS(order(i)),i,'r.');
    end
    %     end
    %     plot(OSIMEANS(order(i)),i,'b.');
end
axis tight



%%
f = figure;
ax = axes;

hold on
scatter(FRs,(VECANGCIHI-VECANGCILO),'ko');
which = ~isnan(FRs) & ~isnan(VECANGCIHI) & ~isnan(VECANGCILO);
[r,p] = corrcoef(FRs(which),(VECANGCIHI(which)-VECANGCILO(which)))

%%
f = figure;
ax = axes;

hold on
scatter(OSISDs,VECANGSDs,'ko');
which = ~isnan(OSISDs) & ~isnan(VECANGSDs)
[r,p] = corrcoef(OSISDs(which),VECANGSDs(which))

