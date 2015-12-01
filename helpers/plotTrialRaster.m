function plotTrialRaster( trialRaster, orientations, k, range, sess )
% plotTrialRaster = plots raster in form where x-axis is cell number and y
%                   axis is the number of spikes in that particular cell.
%
% parameters = trialRaster: raster to plot.
%

freq = sess.trodes(1).detectParams.samplingFreq; 
rangeInSamps = (range/1000)*freq; %ms to samples

xvals = zeros(length(trialRaster), length(0-rangeInSamps(1):0+rangeInSamps(2)));

for i = 1:length(trialRaster)
    xvals(i,:) = trialRaster{i};
end

spy(xvals, 5);
daspect([400 1 1]);
title(num2str(radtodeg(orientations(k))));


end

