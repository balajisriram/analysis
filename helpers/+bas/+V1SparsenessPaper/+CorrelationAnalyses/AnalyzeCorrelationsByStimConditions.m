if ~exist('AllNeurons','var')
    load AllNeurons_Correlations
end

Correlations = cell(2,3,4);
for i = 1:length(AllNeurons)
    
    for j = 1:3
        for k = 1:4
            Correlations{1,j,k} = [Correlations{1,j,k};reshape(AllNeurons{i}(:,:,1,k,j),[],1)];
            Correlations{2,j,k} = [Correlations{2,j,k};reshape(AllNeurons{i}(:,:,2,k,j),[],1)];
        end
    end
    
end

%% now plot those suckers
M = cellfun(@nanmean,Correlations); ML = squeeze(M(1,:,:));MR = squeeze(M(2,:,:));
S = cellfun(@nanstd,Correlations); SL = squeeze(S(1,:,:));SR = squeeze(S(2,:,:));
N = cellfun(@(x) sum(~isnan(x)),Correlations); NL = squeeze(N(1,:,:));NR = squeeze(N(2,:,:));


figure;
% 

%% responses at zero contrast across durations 
respL = squeeze(Correlations(1,1,:));
respR = squeeze(Correlations(2,1,:));

NL = cellfun(@(x) sum(~isnan(x)),respL);
NR = cellfun(@(x) sum(~isnan(x)),respR);

mL = cellfun(@nanmean ,respL);
mR = cellfun(@nanmean ,respR);

stdL = cellfun(@nanstd ,respL);
stdR = cellfun(@nanstd ,respR);

semL = stdL./sqrt(NL);
semR = stdR./sqrt(NR);


ax1 = subplot(3,1,1);hold on;
errorbar([50 100 200 500],mL,2*semL,'b');
errorbar([50 100 200 500],mR,2*semR,'r');

%%
respL = squeeze(Correlations(1,2,:));
respR = squeeze(Correlations(2,2,:));

NL = cellfun(@(x) sum(~isnan(x)),respL);
NR = cellfun(@(x) sum(~isnan(x)),respR);

mL = cellfun(@nanmean ,respL);
mR = cellfun(@nanmean ,respR);

stdL = cellfun(@nanstd ,respL);
stdR = cellfun(@nanstd ,respR);

semL = stdL./sqrt(NL);
semR = stdR./sqrt(NR);

ax1 = subplot(3,1,2);hold on;
errorbar([50 100 200 500],mL,2*semL,'b');
errorbar([50 100 200 500],mR,2*semR,'r');

%%
respL = squeeze(Correlations(1,3,:));
respR = squeeze(Correlations(2,3,:));

NL = cellfun(@(x) sum(~isnan(x)),respL);
NR = cellfun(@(x) sum(~isnan(x)),respR);

mL = cellfun(@nanmean ,respL);
mR = cellfun(@nanmean ,respR);

stdL = cellfun(@nanstd ,respL);
stdR = cellfun(@nanstd ,respR);

semL = stdL./sqrt(NL);
semR = stdR./sqrt(NR);

ax1 = subplot(3,1,3);hold on;
errorbar([50 100 200 500],mL,2*semL,'b');
errorbar([50 100 200 500],mR,2*semR,'r');
