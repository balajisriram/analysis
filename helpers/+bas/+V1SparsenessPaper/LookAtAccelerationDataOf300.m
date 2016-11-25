%% load the data into x,y,z and plot

% get the events
filename = 'E:\300\FullRecordedData\300_2016-11-23_20-49-03\all_channels.events';
[events, t1, info] = load_open_ephys_data(filename);

% x
filename = 'E:\300\FullRecordedData\300_2016-11-23_20-49-03\100_AUX1.continuous';
[x, t2] = load_open_ephys_data(filename);

% y
filename = 'E:\300\FullRecordedData\300_2016-11-23_20-49-03\100_AUX2.continuous';
[y, t3] = load_open_ephys_data(filename);

% z
filename = 'E:\300\FullRecordedData\300_2016-11-23_20-49-03\100_AUX3.continuous';
[z, t4] = load_open_ephys_data(filename);

%%
plot(timestamps(1:300000),data(1:300000))