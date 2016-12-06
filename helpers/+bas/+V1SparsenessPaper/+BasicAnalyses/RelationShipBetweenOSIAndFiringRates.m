% This script loops over sessions collects information about 
% (1) Firing rates of neurons
% (2) Statistics of OSI
clear all;
% loc = '/media/ghosh/My Passport/workingSessions';
loc = 'F:\workingSessionsnoWaveform';
d = dir(fullfile(loc,'*.mat'));

DETAILS = {};
for j = 1:length(d)
    disp(j)
    clear sess
    load(fullfile(loc,d(j).name));
    disp(d(j).name)
    
    % firing Rates and OSI
    try
        fr = sess.getFeature('FiringRate');
        osi = sess.getFeature('OSIsWithJackKnife');
    catch ex
        getReport(ex)
        fr = [];
        osi = [];
    end
    fr.sessionName = d(j).name;
    osi.sessionName = d(j).name;
    DETAILS{end+1} = {fr,osi};
end

save('Details.mat','DETAILS');

%% Get the Various features
OSIs = [];
FRs = [];

OSIMEANS = [];
OSISDs = [];
OSILEN = [];
OSIMINs = [];
OSIMAXs = [];
OSICILO = [];
OSICIHI = [];
for i = 1:length(DETAILS)
    if isfield(DETAILS{i}{2},'OSI')
        OSIs = [OSIs DETAILS{i}{2}.OSI];
        FRs = [FRs DETAILS{i}{1}.firingRates];
        
        OSIMEANS = [OSIMEANS cellfun(@nanmean,DETAILS{i}{2}.OSISubsample)];
        OSISDs = [OSISDs cellfun(@nanstd,DETAILS{i}{2}.OSISubsample)];
        OSILEN = [OSILEN cellfun(@length,DETAILS{i}{2}.OSISubsample)];
        OSIMINs = [OSIMINs cellfun(@min,DETAILS{i}{2}.OSISubsample)];
        OSIMAXs = [OSIMAXs cellfun(@max,DETAILS{i}{2}.OSISubsample)];
        OSICILO = [OSICILO cellfun(@(x) quantile(x,0.025),DETAILS{i}{2}.OSISubsample)];
        OSICIHI = [OSICIHI cellfun(@(x) quantile(x,0.975),DETAILS{i}{2}.OSISubsample)];
    end
end

%% hist OSI 
ax = axes;
hist(OSIs,30); 
ax.YTick = [0 50 100 150];
xlabel('OSI');
ylabel('# units');

%% scatter OSI vs fr
ax = axes;
h = scatter(log10(FRs),OSIs);

%% plots about reliability of OSIS
f = figure;
ax = axes;

hold on
[sortedOSI,order]  = sort(OSIs);

for i = 1:length(sortedOSI)
    plot([OSICILO(order(i)) OSICIHI(order(i))],[i i],'k');
    if (OSIs(order(i))> OSICILO(order(i))) && (OSIs(order(i))< OSICIHI(order(i)))
        plot(OSIs(order(i)),i,'b.');
    else
        plot(OSIs(order(i)),i,'r.');
    end
%     plot(OSIMEANS(order(i)),i,'b.');
end
axis tight

%% create rules about inclusion criteria
rule1 = ~isnan(OSIs) & ~isnan(FRs) & ~isnan(OSIMEANS) & ~isnan(OSISDs) & ~isnan(OSICILO) & ~isnan(OSICIHI);
rule2 = (OSICIHI-OSICILO)<0.2;
rule3 = FRs<10;
OSIs1 = OSIs(rule1 & rule2 & rule3);
OSICILO1 = OSICILO(rule1 & rule2 & rule3);
OSICIHI1 = OSICIHI(rule1 & rule2 & rule3);


f = figure;
ax = axes;

hold on
[sortedOSI,order]  = sort(OSIs1);

for i = 1:length(sortedOSI)
    plot([OSICILO1(order(i)) OSICIHI1(order(i))],[i i],'k');
    if (OSIs1(order(i))> OSICILO1(order(i))) && (OSIs1(order(i))< OSICIHI1(order(i)))
        plot(OSIs1(order(i)),i,'b.');
    else
        plot(OSIs1(order(i)),i,'r.');
    end
%     plot(OSIMEANS(order(i)),i,'b.');
end
axis tight
