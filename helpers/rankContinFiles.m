function [rankings, spikesFound, spikesRates, noiseSpikes, whichChansDisabled] = rankContinFiles(continFolder, thresholdFiringRate)
% [list] = rankContinFiles(folder)
%   Takes a folder of contin files and uses very quick version of spike
%   detection to determine which continuous files are more likely to
%   produce best/most spikes.
%
%  PARAMETERS:
%    1. continFolder = folder containing all contin files to rank
%
%  RETURN VALUES:
%    2. rankings = list of ints ex: [5,3,7,1...] where index
%    represents ranking of continuous file and rankings[index] = channel
%    of that file.
%    i.e. in this examples, channel 5 is best, 3 is second, etc...
%
%   Author: Robert Recatto
%   Date: 6/22/15
%

% NOTE: assumes file titles in default format return by OpenEphys i.e
%       (processerID_CHx.continuous) where x is the channel number. And
%       that files are in order of their channel number!
% ALSO: Uses random to not favor any type of spike time difference 
%       correlations. 

% 1. Cycle through each continuous file in folder

% TEST DATA
% rankContinReturn spikes found:
%  [ 214   162   154   150   164   178   191 ]
% rankings:
%  [ 1     7     6     5     2     3     4 ]
%
% load_open_ephys_data/spike detect spikes found:
%  [ 778   147   128   113   143  178   348 ]
% rankings:
%  [ 1     7     6     2     5     3     4 ]
%
% HOWEVER: note that since algorithm runs using random numbers, rankings of
%          channel 2 and channel 5 flip flop pretty frequently for this
%          particular data set. 

fPath = [continFolder,'\*.continuous'];
files = dir(fPath);
spikesFound = zeros(1, length(files));
spikesRates = zeros(1, length(files));
currChannel = 1;
for file = files'
    currChannel = str2num( file.name(find(file.name=='H')+1:find(file.name=='.')-1));
    [data, timestamps, info] = load_open_ephys_data([continFolder,'\',file.name]);
    noiseSpikes = (1-0.999999426696856)*length(data);
    
    % ## filter data
    N=round(min(30000/200,floor(size(data,1)/3))); %how choose filter orders? one extreme bound: Data must have length more than 3 times filter order.
    [b,a]=fir1(N,2*[200 10000]/30000);
    filteredSignal=filtfilt(b,a,data);
    
    %2. gets mean and stdDev for upper/lower bounds
    mVal = mean(filteredSignal); % ## mean and std of filtered data
    stdDev = std(filteredSignal);
    i = 1;
    
    filteredSignalTop = (filteredSignal>(mVal+5*stdDev));
    filteredSignalBot = (filteredSignal<(mVal-5*stdDev));
    numSpikesTop = sum(diff(filteredSignalTop) ==1);
    numSpikesBot = sum(diff(filteredSignalBot) ==1);
    spikeRate = (numSpikesTop+numSpikesBot-noiseSpikes)/(length(filteredSignal)/30000);
    spikesFound(currChannel) = numSpikesTop+numSpikesBot;
    spikesRates(currChannel) = spikeRate;
    
    whichChansDisabled = find(spikesRates<thresholdFiringRate);
end

% 4. construct rankings array using number of spikes found. 
rankings = zeros(1, length(files));
spikeRate = spikesRates; %## copy over before wipe data from this list
for rank = 1:length(files)
    [~, index] = max(spikeRate);
    rankings(rank) = index;
    spikeRate(index) = -1;
end

end

