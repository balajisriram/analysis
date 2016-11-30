function AllNeurons = GetDetailsOnCorrelationBetweenUnits
if ~exist('DETAILS','var')
    load('Details_SpikeDetails')
end

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
    
    NumNeurons = size(spR,2);
    
    sessionHasContrasts = nan(1,size(contrastLimits,1));
    sessionHasDurations = nan(1,size(durationLimits,1));
    
    for j = 1:length(sessionHasDurations)
        sessionHasDurations(j) = any(dur>durationLimits(j,1) & dur<durationLimits(j,2));
    end
    
    for j = 1:length(sessionHasContrasts)
        sessionHasContrasts(j) = any(c>contrastLimits(j,1) & c<contrastLimits(j,2));
    end
    
    SpikeRateCorrelation = nan(NumNeurons,NumNeurons,2,length(sessionHasDurations),length(sessionHasContrasts));
    whichLeftOr = (or<0 & or>-pi/2) | (or>pi/2 & or<pi);
    
    for j = 1:NumNeurons
        for k = j:NumNeurons
            
            for l = 1:length(sessionHasDurations)
                for m = 1:length(sessionHasContrasts)
                    whichDurs = dur>durationLimits(l,1) & dur<durationLimits(l,2);
                    whichCtrs = c>contrastLimits(m,1) & c<contrastLimits(m,2);
                    
                    if any(whichDurs & whichCtrs)
                        % left
                        sp1 = DETAILS{i}{1}.spikeRatesActual(whichLeftOr & whichDurs & whichCtrs,j);
                        sp2 = DETAILS{i}{1}.spikeRatesActual(whichLeftOr & whichDurs & whichCtrs,k);
                        sp1 = sp1(~isnan(sp1) & ~isnan(sp2));
                        sp2 = sp2(~isnan(sp1) & ~isnan(sp2));
                        coef = corrcoef(sp1,sp2);
                        try
                            SpikeRateCorrelation(j,k,1,l,m) = coef(2);
                        catch
                            SpikeRateCorrelation(j,k,1,l,m) = NaN;
                        end
                        
                        % right
                        sp1 = DETAILS{i}{1}.spikeRatesActual(~whichLeftOr & whichDurs & whichCtrs,j);
                        sp2 = DETAILS{i}{1}.spikeRatesActual(~whichLeftOr & whichDurs & whichCtrs,k);
                        sp1 = sp1(~isnan(sp1) & ~isnan(sp2));
                        sp2 = sp2(~isnan(sp1) & ~isnan(sp2));
                        coef = corrcoef(sp1,sp2);
                        try
                            SpikeRateCorrelation(j,k,2,l,m) = coef(2);
                        catch
                            SpikeRateCorrelation(j,k,2,l,m) = NaN;
                        end
                    else
                        SpikeRateCorrelation(j,k,1,l,m) = NaN;
                        SpikeRateCorrelation(j,k,2,l,m) = NaN;
                    end
                    
                end
            end

        end
    end
    
    AllNeurons{end+1} = SpikeRateCorrelation;
       
end


end