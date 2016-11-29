function AllNeurons = CreateResponseHistogramsForAllNeurons
if ~exist('DETAILS','var')
    load('Details_SpikeDetails')
end

%% details on durations
durs = [];
ctrs = [];
orns = [];
for i = setdiff(1:length(DETAILS),[7,9,10,11,17,35])
    durs = [durs;DETAILS{i}{1}.actualStimDurations];
    ctrs = [ctrs;DETAILS{i}{1}.contrasts];
    orns = [orns;DETAILS{i}{1}.orientations];
end
%% get the response histogram

% seperate durations from 0-0.05;0.05-0.11;0.11-0.21;0.21-0.5;; 4 durations
% separate contrasts 0-0.1,0.11-0.2,0.8-1.1; 3 contrasts

AllNeurons = {};
durationLimits = [-0.01,0.051;...
                    0.051,0.11;...
                    0.11,0.21;...
                    0.21,0.5];
contrastLimits = [-0.1,0.1;...
                    0.11,0.2;...
                    0.8,1.1];
for i = setdiff(1:length(DETAILS),[7,9,10,11,17,35])
    fprintf('session %d: ',i);
    or = DETAILS{i}{1}.orientations;
    c = DETAILS{i}{1}.contrasts;
    dur = DETAILS{i}{1}.actualStimDurations;
    spR = DETAILS{i}{1}.spikeRatesActual;
    
    numNeurons = size(spR,2);
    
    sessionHasContrasts = nan(1,size(contrastLimits,1));
    sessionHasDurations = nan(1,size(durationLimits,1));
    
    for j = 1:length(sessionHasDurations)
        sessionHasDurations(j) = any(dur>durationLimits(j,1) & dur<durationLimits(j,2));
    end
    
    for j = 1:length(sessionHasContrasts)
        sessionHasContrasts(j) = any(c>contrastLimits(j,1) & c<contrastLimits(j,2));
    end
    
    
    for j = 1:numNeurons
        SpikeRateHistogram = cell(2,length(sessionHasDurations),length(sessionHasContrasts));
        SpikeNumHistogram = SpikeRateHistogram;
        SpikeTimeHistogram = SpikeRateHistogram;
        whichLeftOr = (or<0 & or>-pi/2) | (or>pi/2 & or<pi);
        for k = 1:length(sessionHasDurations)
            for l = 1:length(sessionHasContrasts)
                whichDurs = dur>durationLimits(k,1) & dur<durationLimits(k,2);
                whichCtrs = c>contrastLimits(l,1) & c<contrastLimits(l,2);
                
                % left
                SpikeRateHistogram{1,k,l} = DETAILS{i}{1}.spikeRatesActual(whichLeftOr & whichDurs & whichCtrs,j);
                SpikeNumHistogram{1,k,l} = DETAILS{i}{1}.spikeNumsActual(whichLeftOr & whichDurs & whichCtrs,j);
                SpikeTimeHistogram{1,k,l} = DETAILS{i}{1}.spikeRatesActual(whichLeftOr & whichDurs & whichCtrs,j);
                
                % right
                SpikeRateHistogram{2,k,l} = DETAILS{i}{1}.spikeRatesActual(~whichLeftOr & whichDurs & whichCtrs,j);
                SpikeNumHistogram{2,k,l} = DETAILS{i}{1}.spikeNumsActual(~whichLeftOr & whichDurs & whichCtrs,j);
                SpikeTimeHistogram{2,k,l} = DETAILS{i}{1}.spikeRatesActual(~whichLeftOr & whichDurs & whichCtrs,j);
            end
        end
        
        NeuronResponses.SpikeRateHistogram = SpikeRateHistogram;
        NeuronResponses.SpikeNumHistogram = SpikeNumHistogram;
        NeuronResponses.SpikeTimeHistogram = SpikeTimeHistogram;
        NeuronResponses.HasContrasts = sessionHasContrasts;
        NeuronResponses.HasDurations = sessionHasDurations;
        NeuronResponses.SessionNumber = i;
        
        AllNeurons{end+1} = NeuronResponses;
    end
       
end

end