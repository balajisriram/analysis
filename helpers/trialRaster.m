function [ raster ] = trialRaster(sess, trials, unit, range)
% trialRaster - takes a list of trials, a single unit, and a range, and
%               returns a raster indicating the how many times the unit
%               appears in each trial.
%
% Parameters: trials - list of which trials to check for correspondance.
%             unit - which unit to count for in each trial.
%             range - [before, after] in number of milliseconds to give a 
%                     buffer of time in which how close a spike can occur 
%                     to be considered due to that trial.
%
% Return: raster - cell array of length(trials) where each cell contains
%                  indices of all spikes that occur within range of of
%                  stimOnset of trial

raster = cell(1,length(trials));
freq = sess.trodes(1).detectParams.samplingFreq; 
rangeInSamps = (range/1000)*freq; %ms to samples



stimOnsetInd = [sess.eventData.stim(trials).start]*freq;
minInd = stimOnsetInd-rangeInSamps(1);
maxInd = stimOnsetInd+rangeInSamps(2);

for i = 1:length(maxInd)
    sampInd = minInd(i):maxInd(i);
    which = intersect(unit.index, sampInd)-minInd(i)+1;
    inds = zeros(1,length(sampInd));
    inds(which) = 1;
    raster{i} = inds;
end
end

