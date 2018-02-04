location = '/Volumes/BAS_Data2/ProcessesSessions/m318_2017-08-26_18-14-22';

%% load the messages
fid = fopen(fullfile(location,'messages.events'));

tline = fgetl(fid);

trialNumber = [];
trialStartInd = [];
trialEndInd = [];

trialStarted = false;
clc
while ischar(tline)
    if strfind(tline,'TrialStart::')
        i = strfind(tline,'TrialStart::');
        % get the index
        ind = str2double(tline(1:i-2));
        tNum = str2double(tline(i+12:end));
        
        trialStarted = true;
        trialNumber = [trialNumber;tNum];
        trialStartInd = [trialStartInd;ind];
    elseif strfind(tline,'TrialEnd')
        if ~trialStarted
            fprintf('Trial not started but found Trial End. Last TrialNum = %d',trialNumber(end));
            keyboard
        end
        i = strfind(tline,'TrialEnd');
        ind = str2double(tline(1:i-2));
        
        trialEndInd = [trialEndInd;ind];
    else
        fprintf('%s :: NOT PROCESSED\n',tline);
    end
    
    tline = fgetl(fid);
end

%% load the events
[d,t,info] = load_open_ephys_data(fullfile(location,'all_channels.events'));

%%
nMin = 200; 
nMax = 205;
% filter for eventType = 3, nodeID=100,

which = info.nodeId==100 & info.eventType==3;
tWhich = t(which);
dWhich = d(which);
idWhich = info.eventId(which);

% get the time for 3 trials
tMin = trialStartInd(nMin)/30000;
tMax = trialEndInd(nMax)/30000;

tEventThat = tWhich(tWhich>=tMin & tWhich<=tMax);
dEventThat = dWhich(tWhich>=tMin & tWhich<=tMax);
idEventThat = idWhich(tWhich>=tMin & tWhich<=tMax);


%% plot
figure;
axes;
hold on;
for i = nMin:nMax
    plot([trialStartInd(i)/30000 trialEndInd(i)/30000],[0,0],'k','LineWidth',2);
    plot([trialStartInd(i)/30000 trialStartInd(i)/30000],[0 0.1],'k');
    plot([trialEndInd(i)/30000 trialEndInd(i)/30000],[0 0.1],'r');
end

for i = 1:length(tEventThat)
    switch dEventThat(i)
        case 0
            col = 'r';
        case 1
            col = 'g';
        case 2
            col = 'b';
        case 3
            col = 'm';
    end
    plot(tEventThat(i),dEventThat(i)+idEventThat(i)/2+0.1,'*','MarkerEdgeColor',col);
end




