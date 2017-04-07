function out = getFractionResponsive(in,outType)
out = cell(size(in.spikeResponsesByStimConditions));

for i = 1:length(in.uniqC)
    for j = 1:length(in.uniqDur)
        numNeurons = size(in.spikeResponsesByStimConditions{1,i,j},2);
        out{1,i,j} = sum(in.spikeResponsesByStimConditions{1,i,j}>0,2)/numNeurons;
    end
end

switch outType
    case 'cell'
        %  do nothing
    case 'vector'
        temp = [];
        for i = 1:length(in.uniqC)
            for j =1:length(in.uniqDur) 
                temp = [temp;out{1,i,j}];
                temp = [temp;out{2,i,j}];
            end
        end
        out = temp;
end
end