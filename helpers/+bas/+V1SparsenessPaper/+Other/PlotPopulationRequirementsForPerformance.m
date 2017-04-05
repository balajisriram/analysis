load('\\ghosh-nas.ucsd.edu\ghosh\Physiology\NewAnalysis\PerformanceByPopulationSize2.mat')
mPerfByCondition = squeeze(nanmean(out.performanceSignificant,2));
mPerfByCondition = squeeze(nanmean(out.performanceSignificant,2));

performancesAll = [];
durationsAll = [];
contrastsAll = [];
populationSizesAll = [];

for i = 1:length(populationSizes)
    for j = 1:length(contrasts)
        for k = 1:length(durations)
            for l = 1:numResamples
                performancesAll(end+1) = out.performanceSignificant(i,l,j,k);
                durationsAll(end+1) = durations(k);
                contrastsAll(end+1) = contrasts(j);
                populationSizesAll(end+1) = populationSizes(i);
            end
        end
    end
end

%%

g = gramm('x',log10(populationSizesAll),'y',performancesAll,'color',contrastsAll);
g.facet_wrap(durationsAll,'scale','fixed','ncols',4);
% g.stat_boxplot();
g.stat_summary('type','95percentile');
% g.no_legend();
figure('position',[366 471 1372 359]);
g.draw()

%%
figure;hold on
mC50 = [16,28,122,28];
C50Lo = [4,8 5 10];
C50Hi = [64,58,430,50];

errorbar([50 100 150 200],mC50,mC50-C50Lo, C50Hi-mC50,'g')

mC50 = [162,36,24,36];
C50Lo = [34,20,7,18];
C50Hi = [420,60,52,60];

errorbar([50 100 150 200],mC50,mC50-C50Lo, C50Hi-mC50,'b')