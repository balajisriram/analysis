function s = plotFilteredData( dataFolder, channel )
%plot filtered data of all channels in folder

fPath = [dataFolder,'\100_CH', num2str(channel), '.continuous'];
set(gca, 'ylim', [-700 700]);
disp(fPath)
[data, timestamps, info] = load_open_ephys_data(fPath);

    
% ## filter data
N=round(min(30000/200,floor(size(data,1)/3))); %how choose filter orders? one extreme bound: Data must have length more than 3 times filter order.
[b,a]=fir1(N,2*[200 10000]/30000);
filteredSignal=filtfilt(b,a,data);

%plot data
plot(timestamps(1:20*30000),filteredSignal(1:20*30000)');
hold on;
plot(get(gca,'xlim'),[mean(filteredSignal)+5*std(filteredSignal) mean(filteredSignal)+5*std(filteredSignal)],'r--')
plot(get(gca,'xlim'),[mean(filteredSignal)-5*std(filteredSignal) mean(filteredSignal)-5*std(filteredSignal)],'r--')
end

