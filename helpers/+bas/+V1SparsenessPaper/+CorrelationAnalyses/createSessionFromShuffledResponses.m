function out = createSessionFromShuffledResponses(in)
spikeResponsesByStimConditions = in.spikeResponsesByStimConditions;
Cs = in.uniqC;
Ds = in.uniqDur;
ors = [pi/4,-pi/4];
% #1 is or>0; #2 is or<0;

assert(all(size(spikeResponsesByStimConditions)==[2,length(Cs),length(Ds)]));
spR = [];
c = [];
durs = [];
or = [];

for i = 1:2
    for j = 1:length(Cs)
        for k = 1:length(Ds)
            numTrialsOfThisType = size(spikeResponsesByStimConditions{i,j,k},1);
            spR = [spR;  spikeResponsesByStimConditions{i,j,k}];
            or= [or;repmat(ors(i),numTrialsOfThisType,1)];
            c= [c;repmat(Cs(j),numTrialsOfThisType,1)];
            durs= [durs;repmat(Ds(k),numTrialsOfThisType,1)];
        end
    end
end

out.contrasts = c;
out.durations = durs;
out.orientations = or;
out.spikeRatesActual = spR;
end