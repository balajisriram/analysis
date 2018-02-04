% load the cluster details
directory = '/Users/balaji/Desktop/m325_2017-08-10_14-21-22/';
KWIKName = '100_raw_CAR.kwik';
KWIKFilename = fullfile(directory,KWIKName);
spikeTimes = hdf5read(KWIKFilename, '/channel_groups/0/spikes/time_samples');
spikeClusters = hdf5read(KWIKFilename, '/channel_groups/0/spikes/clusters/main');

goodClusters = [17,25,26,27,47,51,66,96,98,99,100,102];
MUAClusters = [];

%% plot the ISI for these units
numGoods = length(goodClusters);


%% load the channel_events
eventsFilename = fullfile(directory,'all_channels.events');
[d,t,i] = load_open_ephys_data(eventsFilename);

%% process message_Events
messageFilename = fullfile(directory,'messages.events');
fid = fopen(messageFilename);
line = fgetl(fid);
data = {};
while(ischar(line))
    data{end+1} = line;
    line = fgetl(fid);
end
fclose(fid);

% loop through lines 