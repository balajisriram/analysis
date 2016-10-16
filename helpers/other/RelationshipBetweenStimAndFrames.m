% Establish the relationship between Stim and Frames (this is to fill in
% the details for latter sessions when the data isnt available any longer

clear all;
load('E:\workingSessionsnoWaveform\284_2016-01-08_12-16-38_736341_Inspected.mat');

stim = sess.eventData.stim;
frames = sess.eventData.frame;

%% Now plot the data
figure;
axes; hold on;
firstFrame = [];
numFrames = [];
frameDurations = [];
stimDurations = [];
for i = 1:length(stim)
    if isempty(stim(i))
        continue
    end
    
    stimStart = stim(i).start;
    stimDuration = stim(i).stop-stim(i).start;
    
    frameStarts = frames(i).start-stimStart;
    
    plot(frameStarts,repmat(i,size(frameStarts)),'g.');
    firstFrame = [firstFrame frameStarts(1)];
    numFrames = [numFrames length(frameStarts)];
    frameDurations = [frameDurations frameStarts(end) - frameStarts(1)];
    stimDurations = [stimDurations stimDuration];
    
end
