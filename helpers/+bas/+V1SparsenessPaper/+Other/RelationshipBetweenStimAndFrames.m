% Establish the relationship between Stim and Frames (this is to fill in
% the details for latter sessions when the data isnt available any longer

clear all;
loc = 'E:\workingSessionsnoWaveform';
d = dir(fullfile(loc,'*.mat'));

for j = 1:length(d)
    disp(j)
    clear sess
    load(fullfile(loc,d(j).name));
    
    stim = sess.eventData.stim;
    frames = sess.eventData.frame;
    
    doPlotFrameDuration = true;
    if doPlotFrameDuration
        f = figure;
        
        try
            trialNumberInFrames = [];
            numFramesInFrames = [];
            trialNumberInStim = [];
            numFramesInStim = [];
            for i = 1:length(frames)
                if ~isempty(frames(i).start)
                    trialNumberInFrames(end+1) = frames(i).trialNumber;
                    numFramesInFrames(end+1) = length(frames(i).start)-2;
                    % look for this in stim Details
                    whichTrialNum = [sess.trialDetails.trialNum]==frames(i).trialNumber;
                    if ~any(whichTrialNum)
                        trialNumberInStim(end+1) = NaN;
                        numFramesInStim(end+1) = NaN;
                    else
                        trialNumberInStim(end+1) = frames(i).trialNumber;
                        sd = [sess.trialDetails.stimDetails];
                        durs = [sd.maxDuration];
                        numFramesInStim(end+1) = durs(whichTrialNum);
                    end
                end
            end
            
            ax = subplot(2,2,1); hold on;
            plot(trialNumberInStim,trialNumberInFrames,'k.');
            title('trNum vs trNum');
            
            ax = subplot(2,2,2); hold on;
            plot(numFramesInStim,numFramesInFrames,'k.');
            
            ax = subplot(2,2,3); hold on;
            corrs = xcorr(numFramesInStim,numFramesInFrames,10);
            plot(corrs,'k');
            [~,ind] = max(corrs);
            text(1,1,sprintf('%d',ind),'Units','normalized','HorizontalAlignment','right','VerticalAlignment','top');
        catch ex
            getReport(ex)
            d(j).name
        end
        name = d(j).name;
        name = name(1:end-3); % remove the .mat
        name = [name '.png'];
        saveas(f,name);
        close(f);
        
        
    end
    %% Now plot the data
    doPlotRelativeFrameLocation = false;
    if doPlotRelativeFrameLocation
        f = figure;
        axes; hold on;
        firstFrame = [];
        numFrames = [];
        frameDurations = [];
        stimDurations = [];
        try
            for i = 1:length(stim)
                if isempty(stim(i))
                    continue
                end
                
                stimStart = frames(i).start(2);
                %stimDuration = stim(i).stop-stim(i).start;
                
                frameStarts = frames(i).start-stimStart;
                
                plot(frameStarts,repmat(i,size(frameStarts)),'g.');
                firstFrame = [firstFrame frameStarts(1)];
                numFrames = [numFrames length(frameStarts)];
                frameDurations = [frameDurations frameStarts(end) - frameStarts(1)];
                %stimDurations = [stimDurations stimDuration];
                
            end
        catch ex
            getReport(ex)
        end
        name = d(j).name;
        name = name(1:end-3); % remove the .mat
        name = [name '.png'];
        saveas(f,name);
        close(f);
    end
end
