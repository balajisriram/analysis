function s = plotFilteredDataFolder( dataFolder )
%plot filtered data of all channels in folder

fPath = [dataFolder,'\*.continuous'];
files = dir(fPath);
set(gca, 'ylim', [-700 700]);

for file = files'
    currChannel = str2num( file.name(find(file.name=='H')+1:find(file.name=='.')-1));
    
    [data, timestamps, info] = load_open_ephys_data([dataFolder,'\',file.name]);
    
    data = data(1:300000);
    
    % ## filter data
    N=round(min(30000/200,floor(size(data,1)/3))); %how choose filter orders? one extreme bound: Data must have length more than 3 times filter order.
    [b,a]=fir1(N,2*[200 10000]/30000);
    filteredSignal=filtfilt(b,a,data);
    
    mFilt = mean(filteredSignal);
    stdFilt = std(filteredSignal);
    
    %plot data
    subplot(4,8,currChannel);
    plot(1:300000, filteredSignal'); hold on;
    plot([1,300000], [mFilt+5*stdFilt mFilt+5*stdFilt], '--r',[1,300000], [mFilt-5*stdFilt mFilt-5*stdFilt], '--r');

end

