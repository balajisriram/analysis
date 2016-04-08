function [ dataFolder, numChans ] = plotSpikeCheck( dataFolder, numChans, stdAway )
%  Function for manual check for spikes on .cont files. Grabs numChans
%  number of channels all from different trodes and plots them on top of 
%  eachother. Logic here is that there should be single channel spikes
%  clear if the data is good since the channels are from different trodes.

%  Note: currently using NNX_A1x32_Poly3_5mm_25s_117 electrode as the model
%  trode structure so these values will be hard-coded.
    groupings = {[1,11,22,32],[2,3,12,21],[12,21,30,31],[3,4,13,21],[13,21,29,30],[4,5,13,20],[13,20,28,29],[5,6,14,20],[14,20,27,28],...
            [6,7,14,19],[14,19,26,27],[7,8,15,19],[15,19,25,26],[8,9,15,18],[15,18,24,25],[9,10,16,18],[16,18,23,24],[10,16,17,23]};
    numTrodes=18;  
    trodeSet = 1:18;
    
    if numChans>numTrodes
        error('numChans must be less than 18');
    end

    trodesSelected = [];
    for i=1:numChans
        randInd = ceil(rand*length(trodeSet));
        trodesSelected = [trodesSelected trodeSet(randInd)];
        trodeSet(randInd) = [];
    end
    
    chansToPlot = [];
    for i=1:length(trodesSelected)
        allowed = setdiff(groupings{trodesSelected(i)}, chansToPlot);
        if isempty(allowed)
            error('unlucky randoms please try again');
        end
        randInd = ceil(rand*length(allowed));
        chansToPlot = [chansToPlot allowed(randInd)];
    end
    
    rand20s = -1;
    totalSize = -1;
    maxY = -1;
    cmap = colormap(hsv);
    divisor = floor(size(cmap,1)/length(chansToPlot));
    for i=1:length(chansToPlot)
        channel = chansToPlot(i);
        fPath = [dataFolder,'\100_CH', num2str(channel), '.continuous'];
        
        disp(fPath)
        
        [data, ~, ~] = load_open_ephys_data(fPath);
        if rand20s == -1
            rand20s = ceil(rand*(length(data)-21*30000));
            totalSize = length(data);
            indToPlot = rand20s:(rand20s+20*30000);
        end
        N=round(min(30000/200,floor(size(data,1)/3))); 
        [b,a]=fir1(N,2*[200 10000]/30000);
        filteredSignal=filtfilt(b,a,data);
        
        p = plot(filteredSignal(indToPlot)');
        hold on;
        p1 = plot(get(gca,'xlim'),[mean(filteredSignal)+(stdAway)*std(filteredSignal) mean(filteredSignal)+(stdAway)*std(filteredSignal)],'r--');
        p2 = plot(get(gca,'xlim'),[mean(filteredSignal)-(stdAway)*std(filteredSignal) mean(filteredSignal)-(stdAway)*std(filteredSignal)],'r--');
%         for j=1:7
%             p3 = plot(get(gca,'xlim'),[mean(filteredSignal)+(stdAway+j)*std(filteredSignal) mean(filteredSignal)+(stdAway+j)*std(filteredSignal)],'r--');
%             p4 = plot(get(gca,'xlim'),[mean(filteredSignal)-(stdAway+j)*std(filteredSignal) mean(filteredSignal)-(stdAway+j)*std(filteredSignal)],'r--');
%             color = cmap(i*divisor,:);
%             set(p3,'Color', color);
%             set(p4,'Color', color);
%         end
        color = cmap(i*divisor,:);
        set(p,'Color', color);
        set(p1,'Color', color);
        set(p2,'Color', color);
        if(max(filteredSignal(indToPlot)) > maxY || abs(min(filteredSignal(indToPlot))) > maxY)
            maxY = max(max(filteredSignal(indToPlot)),abs(min(filteredSignal(indToPlot))) > maxY);
        end
        set(gca, 'ylim', [-1.2*maxY 1.2*maxY]);
    end
    
    disp(rand20s/totalSize);
end

