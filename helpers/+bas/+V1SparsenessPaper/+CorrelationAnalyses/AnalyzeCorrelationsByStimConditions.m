if ~exist('allNeurons','var')
    load AllNeurons_Correlations
end

Correlations = cell(2,3,4);
for i = 1:length(allNeurons)
    
    for j = 1:3
        for k = 1:4
            Correlations{1,j,k} = [Correlations{1,j,k};reshape(allNeurons{i}(:,:,1,k,j),[],1)];
            Correlations{2,j,k} = [Correlations{2,j,k};reshape(allNeurons{i}(:,:,2,k,j),[],1)];
        end
    end
    
end

%% now plot those suckers
M = cellfun(@nanmean,Correlations); ML = squeeze(M(1,:,:));MR = squeeze(M(2,:,:));
S = cellfun(@nanstd,Correlations); SL = squeeze(S(1,:,:));SR = squeeze(S(2,:,:));
N = cellfun(@(x) sum(~isnan(x)),Correlations); NL = squeeze(N(1,:,:));NR = squeeze(N(2,:,:));
figure;
ax1 = subplot(1,2,1);
errorbar()

ax2 = subplot(1,2,2);
