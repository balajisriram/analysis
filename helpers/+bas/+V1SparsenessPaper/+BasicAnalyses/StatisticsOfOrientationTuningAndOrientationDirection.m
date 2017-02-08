% This script loops over sessions collects information about 
% (1) Firing rates of neurons
% (2) Statistics of OSI
clear all;
% loc = '/media/ghosh/My Passport/workingSessions';
loc = 'E:\workingSessionsnoWaveform';
d = dir(fullfile(loc,'*.mat'));

DETAILS = {};
problems = []; % 35, 27 22, 21, 19, 14 12 % 11, 10, 9, 7 is weird
for j = 1:length(d)
    disp(j)
    clear sess
    load(fullfile(loc,d(j).name));
    disp(d(j).name)
    
    % firing Rates and OSI
    try
        osi = sess.getFeature('OSIsWithJackKnife');
        vect = sess.getFeature('OrientedVectorWithJackKnife');
    catch ex
        osi = [];
        vect = [];
    end
    vect.sessionName = d(j).name;
    osi.sessionName = d(j).name;
    DETAILS{end+1} = {fr,vect,osi};
end
% 
save('Details_OrientationVector_Second.mat','DETAILS');

%% Get the Various features of OSI
temp1 = load('C:\Users\ghosh\Dropbox\Manuscripts\V1 paper\Figure\OSIANDSpikingCharacterizstics\Details_OSI.mat');

DETAILS1 = temp1.DETAILS;


OSIs = [];
FRs = [];

OSIMEANS = [];
OSISDs = [];
OSILEN = [];
OSIMINs = [];
OSIMAXs = [];
OSICILO = [];
OSICIHI = [];
for i = 1:length(DETAILS1)
    if isfield(DETAILS1{i}{2},'OSI')
        OSIs = [OSIs DETAILS1{i}{2}.OSI];
        FRs = [FRs DETAILS1{i}{1}.firingRates];
        
        OSIMEANS = [OSIMEANS cellfun(@nanmean,DETAILS1{i}{2}.OSISubsample)];
        OSISDs = [OSISDs cellfun(@nanstd,DETAILS1{i}{2}.OSISubsample)];
        OSILEN = [OSILEN cellfun(@length,DETAILS1{i}{2}.OSISubsample)];
        OSIMINs = [OSIMINs cellfun(@min,DETAILS1{i}{2}.OSISubsample)];
        OSIMAXs = [OSIMAXs cellfun(@max,DETAILS1{i}{2}.OSISubsample)];
        OSICILO = [OSICILO cellfun(@(x) quantile(x,0.025),DETAILS1{i}{2}.OSISubsample)];
        OSICIHI = [OSICIHI cellfun(@(x) quantile(x,0.975),DETAILS1{i}{2}.OSISubsample)];
    end
end

%% 
temp2 = load('C:\Users\ghosh\Dropbox\Manuscripts\V1 paper\Figure\OSIANDSpikingCharacterizstics\Details_OrientationVector.mat');
DETAILS2 = temp2.DETAILS;


VECANG = [];
VECSTR = [];
OSIs = [];
FRs = [];

OSIMEANS = [];
OSISDs = [];
OSILEN = [];
OSIMINs = [];
OSIMAXs = [];
OSICILO = [];
OSICIHI = [];

VECANGMEANS = [];
VECSTRMEANS = [];
VECANGSDs = [];
VECSTRSDs = [];
VECANGLEN = [];
VECSTDLEN = [];
VECANGMINs = [];
VECSTRMINs = [];
VECANGMAXs = [];
VECSTRMAXs = [];
VECANGCILO = [];
VECSTRCILO = [];
VECANGCIHI = [];
VECSTRCIHI = [];

for i = 1:length(DETAILS1)
    if isfield(DETAILS1{i}{2},'vectors')
        temp = cell2mat(DETAILS2{i}{2}.vectors);
        VECANG = [VECANG [temp.ang]];
        VECSTR = [VECSTR [temp.str]];
        FRs = [FRs DETAILS1{i}{1}.firingRates];
        
        VECANGMEANS = [];
        VECSTRMEANS = [];
        VECANGSDs = [];
        VECSTRSDs = [];
        VECANGLEN = [];
        VECSTDLEN = [];
        VECANGMINs = [];
        VECSTRMINs = [];
        VECANGMAXs = [];
        VECSTRMAXs = [];
        VECANGCILO = [];
        VECSTRCILO = [];
        VECANGCIHI = [];
        VECSTRCIHI = [];
        
        temp = cell2mat(DETAILS2{i}{2}.vectorsJackKnife);
        OSIMEANS = [OSIMEANS cellfun(@nanmean,DETAILS1{i}{3}.OSISubsample)];
        OSISDs = [OSISDs cellfun(@nanstd,DETAILS1{i}{3}.OSISubsample)];
        OSILEN = [OSILEN cellfun(@length,DETAILS1{i}{3}.OSISubsample)];
        OSIMINs = [OSIMINs cellfun(@min,DETAILS1{i}{3}.OSISubsample)];
        OSIMAXs = [OSIMAXs cellfun(@max,DETAILS1{i}{3}.OSISubsample)];
        OSICILO = [OSICILO cellfun(@(x) quantile(x,0.025),DETAILS1{i}{3}.OSISubsample)];
        OSICIHI = [OSICIHI cellfun(@(x) quantile(x,0.975),DETAILS1{i}{3}.OSISubsample)];
    end
end

%%
load Details_OrientationVector_Second

VECANG = [];
VECSTR = [];
OSIs = [];
FRs = [];

OSIMEANS = [];
OSISDs = [];
OSILEN = [];
OSIMINs = [];
OSIMAXs = [];
OSICILO = [];
OSICIHI = [];

VECANGMEANS = [];
VECSTRMEANS = [];
VECANGSDs = [];
VECSTRSDs = [];
VECANGLEN = [];
VECSTRLEN = [];
VECANGMINs = [];
VECSTRMINs = [];
VECANGMAXs = [];
VECSTRMAXs = [];
VECANGCILO = [];
VECSTRCILO = [];
VECANGCIHI = [];
VECSTRCIHI = [];

for i = 1:length(DETAILS)
    if isfield(DETAILS{i}{2},'vectors')
        numNeurons = length(DETAILS{1}{1}.firingRates);
        for j = 1:numNeurons
            FRs = [FRs DETAILS{i}{1}.firingRates(j)];
            
            VECANG = [VECANG DETAILS{i}{2}.vectors{j}.ang];
            VECSTR = [VECSTR DETAILS{i}{2}.vectors{j}.str];
            VECSTRMEANS = [VECSTRMEANS mean([DETAILS{i}{2}.vectorsJackKnife{j}.str])];
            VECANGMEANS = [VECANGMEANS mean([DETAILS{i}{2}.vectorsJackKnife{j}.ang])];
            VECSTRSDs = [VECSTRSDs std([DETAILS{i}{2}.vectorsJackKnife{j}.str])];
            VECANGSDs = [VECANGSDs std([DETAILS{i}{2}.vectorsJackKnife{j}.ang])];
            VECSTRLEN = [VECSTRLEN length([DETAILS{i}{2}.vectorsJackKnife{j}.str])];
            VECANGLEN = [VECANGLEN length([DETAILS{i}{2}.vectorsJackKnife{j}.ang])];
            VECSTRMINs = [VECSTRMINs min([DETAILS{i}{2}.vectorsJackKnife{j}.str])];
            VECANGMINs = [VECANGMINs min([DETAILS{i}{2}.vectorsJackKnife{j}.ang])];
            VECSTRMAXs = [VECSTRMAXs max([DETAILS{i}{2}.vectorsJackKnife{j}.str])];
            VECANGMAXs = [VECANGMAXs max([DETAILS{i}{2}.vectorsJackKnife{j}.ang])];
            
            VECSTRCILO = [VECSTRCILO quantile([DETAILS{i}{2}.vectorsJackKnife{j}.str],0.025)];
            VECANGCILO = [VECANGCILO quantile([DETAILS{i}{2}.vectorsJackKnife{j}.ang],0.025)];
            VECSTRCIHI = [VECSTRCIHI quantile([DETAILS{i}{2}.vectorsJackKnife{j}.str],0.975)];
            VECANGCIHI = [VECANGCIHI quantile([DETAILS{i}{2}.vectorsJackKnife{j}.ang],0.975)];
            
            OSIMEANS = [OSIMEANS nanmean(DETAILS{i}{3}.OSISubsample{j})];
            OSISDs = [OSISDs nanstd(DETAILS{i}{3}.OSISubsample{j})];
            OSILEN = [OSILEN length(DETAILS{i}{3}.OSISubsample{j})];
            OSIMINs = [OSIMINs min(DETAILS{i}{3}.OSISubsample{j})];
            OSIMAXs = [OSIMAXs max(DETAILS{i}{3}.OSISubsample{j})];
            OSICILO = [OSICILO quantile(DETAILS{i}{3}.OSISubsample{j},0.025)];
            OSICIHI = [OSICIHI quantile(DETAILS{i}{3}.OSISubsample{j},0.975)];
        end
        
        
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

%%
% i = 108;
% 
% sess.trialDetails(i).trialNum = trialNum;
% sess.trialDetails(i).trialStartTime = trialStartTime;
% sess.trialDetails(i).refreshRate = 60.0036;
% sess.trialDetails(i).stepName = 'gratings';
% sess.trialDetails(i).stimManagerClass = 'afcGratings';
% sess.trialDetails(i).stimDetails.pixPerCycs = stimulusDetails.chosenStim.pixPerCycs;
% sess.trialDetails(i).stimDetails.driftfrequencies = stimulusDetails.chosenStim.driftfrequencies;
% sess.trialDetails(i).stimDetails.orientations = stimulusDetails.chosenStim.orientations;
% sess.trialDetails(i).stimDetails.phases = stimulusDetails.chosenStim.phases;
% sess.trialDetails(i).stimDetails.contrasts = stimulusDetails.chosenStim.contrasts;
% sess.trialDetails(i).stimDetails.maxDuration = stimulusDetails.chosenStim.maxDuration;
% sess.trialDetails(i).stimDetails.radii = stimulusDetails.chosenStim.radii;
% sess.trialDetails(i).stimDetails.LEDON = 0;