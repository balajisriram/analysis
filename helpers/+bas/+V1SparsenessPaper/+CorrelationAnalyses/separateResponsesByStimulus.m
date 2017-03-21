function out = separateResponsesByStimulus(in)
c = in{1}.contrasts;
or = in{1}.orientations;
durs = in{1}.actualStimDurations;
spR = in{1}.spikeRatesActual
numNeurons = size(spR,2);
spR = spR.*repmat(durs,1,numNeurons);
spR(isnan(spR)) = 0;

dursFixed = bas.V1SparsenessPaper.CorrelationAnalyses.fixDurations(durs);
uniqC = unique(c(~isnan(c)));
uniqDur = unique(dursFixed(~isnan(dursFixed)));
spR = round(spR);

spikeResponsesByStimConditions = cell(2,length(uniqC), length(uniqDur));

for i = 1:length(uniqC)
    for j = 1:length(uniqDur)
        whichTrialsR = c==uniqC(i) & dursFixed==uniqDur(j) & or>0;
        spikeResponsesByStimConditions{1,i,j} = spR(whichTrialsR,:);
        whichTrialsL = c==uniqC(i) & dursFixed==uniqDur(j) & or<0;
        spikeResponsesByStimConditions{2,i,j} = spR(whichTrialsL,:);
        
    end
end
out.uniqC = uniqC;
out.uniqDur = uniqDur;
out.spikeResponsesByStimConditions = spikeResponsesByStimConditions;
