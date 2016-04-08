function [ raster ] = subsetTrialRasterAllUnits( sess, unitNum, range, subset )
% subsetTrialRasterAllUnits = runs trial raster for all units of a session on a
%                       specified subset of the trial data.
%
% parameters = sess: session to analyze
%              range: range in m/s to check before/after frame onset (see
%                     trialRaster function)
%              subset: special string to specify subset of trials that are
%                      going to be tested on. 
%              unitNum: unit in session where units are in order of trode
%                       in which they are contained
%

%% Current subsets implemented %%
%
% Orientation = takes all trials with stim length of ~100ms and creates
%               raster for every single unit of the session. Then plots to
%               user in subplot with orientations as rows and units as
%               columns.
%
%%



switch upper(subset)
    case 'ORIENTATION'
        trialsThisSession = [sess.eventData.trials.trialNumber];
        stimLength = [sess.eventData.stim.stop]-[sess.eventData.stim.start];
        %gets all trials of around >300 and less than 800 ms
        which = stimLength >0.3 & stimLength <0.8;
        trialSubset = trialsThisSession(which);
        
        %further splits this new trial subset up by graphics orientation
        stimDetailsAll = [sess.eventData.trialData.stimulusDetails];
        orsAll = [stimDetailsAll.orientations];
        
        orientations = orsAll(which);
        
        orientations = unique(orientations); % gets all unique orientations
        
        oriTrials = cell(1,length(orientations));
        for i = 1:length(orientations)  %puts each orientation's trials into its own
            for j = 1:length(trialSubset)  %cell of cell array
                if(sess.eventData.trialData(trialSubset(j)).stimulusDetails.orientations == orientations(i))
                    oriTrials{i} = [oriTrials{i} trialSubset(j)];
                end
            end
        end

        %now run trialRaster on each unit for each orientation
        ind = 1;
        raster = cell(1,sess.numUnits*length(orientations));
        for i = 1:length(sess.trodes)
            for j = 1:length(sess.trodes(i).units)
                for k = 1:length(oriTrials)
                    [raster{ind}] = trialRaster(sess, oriTrials{k}, sess.trodes(i).units(j), range);
                    ind = ind+1;
                end
            end
        end
        
        %now plot out raster using plotTrialRaster function and correct
        %figure sizes.
        
        allUnits = [sess.trodes.units];        
        targetUnit = allUnits(unitNum);
        numRows = 2;
        numColumns = ceil(length(orientations)/numRows);
        startingInd = (unitNum-1)*length(orientations)+1;
        rasterInd = startingInd:startingInd+length(orientations);
        for i = 1:length(orientations)
            subplot(numRows, numColumns, i);
            plotTrialRaster(raster{rasterInd(i)}, orientations, i, range, sess);
        end
        
        

    otherwise
        error('subset not recognized');
end


end

