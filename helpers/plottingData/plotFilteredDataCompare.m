function [ files ] = plotFilteredDataCompare( files )

x = rand;

for i = 1:length(files)

    
    [data, ~, ~] = load_open_ephys_data(files{i});
    r = floor(x*(length(data)-600000)); %size of data - 20 seconds
    N=round(min(30000/200,floor(size(data,1)/3))); %how choose filter orders? one extreme bound: Data must have length more than 3 times filter order.
    [b,a]=fir1(N,2*[200 10000]/30000);
    filtData=filtfilt(b,a,data);
    
    subplot(1,length(files),i);
    plot(filtData(r:(r+600000))');
    
end

end

