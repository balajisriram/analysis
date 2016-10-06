% verify details about LED illumination
loc = 'E:\mdemo_monitor_2015-12-30_14-41-24'; % might have to change this

e = eventData(loc,'phys');

% now use the details to split the data and find the number of LED trials

dets = [e.trialData];
trialNums = [dets.trialNum];
stimDets = [dets.stimulusDetails];
chosenStims = [stimDets.chosenStim];

%% verify that the stim duration matches
TrialNumInStimEventData = [e.stim.trialNumber];
TrialNumInStimDetails = trialNums;
StimStartTimes = [e.stim.start];
StimStopTimes = [e.stim.stop];
StimDurationsFromEventData = StimStopTimes-StimStartTimes;
StimDurationFromStimulusDetails = [chosenStims.maxDuration]/60;
% [r,p] = corrcoef(StimDurationsFromEventData,StimDurationFromStimulusDetails); % turns out this is pretty bad!
% turns out that StimDurationFromStimulusDetails(1:end-1) corresponds to
% StimDurationsFromEventData(2:end) why? I don't know...
%% look at the LED 
% load the ADC1 - LED values
[d,t,i] = load_open_ephys_data('E:\mdemo_monitor_2015-12-30_14-41-24\100_ADC1.continuous');

% loop through the LEDStartTimes and sample the LEDStim around it (10 ms
% before, 10 ms after)

%% Onset
monitorStimulusSamples = zeros(length(StimStartTimes),3000); % 50 ms before to 50 ms after
for j = 1:length(StimStartTimes)
    [~,loc] = min(abs(t-StimStartTimes(j)));
    monitorStimulusSamples(j,:) = d(loc+1501:loc+4500);
end
meanLED = mean(monitorStimulusSamples);
stdLED = std(monitorStimulusSamples,[],1);
tRef = linspace(50,150,3000);
plot(tRef,meanLED,'k');
hold on;
plot(tRef,meanLED+stdLED,'k--');
plot(tRef,meanLED-stdLED,'k--');
xlabel('Time Since Stim Onset (ms)');
ylabel('Monitor Luminance Value(arbitrary)');
title('Monitor Onset Timecourse');



%% Offset
monitorStimulusSamples = zeros(length(StimStopTimes),3000); % 50 ms before to 50 ms after
for j = 1:length(StimStopTimes)
    [~,loc] = min(abs(t-StimStopTimes(j)));
    monitorStimulusSamples(j,:) = d(loc-1499:loc+1500);
end
meanLED = mean(monitorStimulusSamples);
stdLED = std(monitorStimulusSamples,[],1);
tRef = linspace(-50,50,3000);
plot(tRef,meanLED,'k');
hold on;
plot(tRef,meanLED+stdLED,'k--');
plot(tRef,meanLED-stdLED,'k--');
xlabel('Time Since Stim Offset (ms)');
ylabel('Monitor Luminance Value(arbitrary)');
title('Monitor Offset Timecourse');

%% plot individual curves
plot(tRef,monitorStimulusSamples);