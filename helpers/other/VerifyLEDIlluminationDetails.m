% verify details about LED illumination
loc = 'E:\mdemo_LED_2015-12-30_12-46-16'; % might have to change this

e = eventData(loc,'phys');

% now use the details to split the data and find the number of LED trials

dets = [e.trialData];
trialNums = [dets.trialNum];
stimDets = [dets.stimulusDetails];
chosenStims = [stimDets.chosenStim];
ledVals =nan(1,length(stimDets));
for i = 1:length(stimDets)
    ledVals(i) = stimDets(i).LEDIntensity(1);
end

% find the respective trial nums:
LEDTrialNumsFromEventData = [e.LED1.trialNumber];
LEDTrialNumsFromStimDeets = trialNums(ledVals>0);

% LEDTrialNumsFromEventData has a '0' at the beginning ehy???
LEDTrialNumsFromEventData(1) = [];

% verify the trial numbers are equal!
fprintf('verifying the LED details from two different measurements are equal = %d\n',all(LEDTrialNumsFromEventData==LEDTrialNumsFromStimDeets));

% % get the stim start/stop time for the corresponding trials with LED
% % stimulation also with the Led start stop times
LEDStartTimes = [e.LED1(2:end).start];
LEDStopTimes = [e.LED1(2:end).stop];
% 
% whichStims = ismember([e.stim.trialNumber],LEDTrialNumsFromStimDeets);

%% verify that the stim duration matches
TrialNumInStimEventData = [e.stim.trialNumber];
TrialNumInStimDetails = trialNums;
StimStartTimes = [e.stim.start];
StimStopTimes = [e.stim.stop];
StimDurationsFromEventData = StimStopTimes-StimStartTimes;
StimDurationFromStimulusDetails = [chosenStims.maxDuration]/60;
[r,p] = corrcoef(StimDurationsFromEventData,StimDurationFromStimulusDetails); % turns out this is pretty bad!
disp('Correlation coefficient between DurEventData(1:end-1) and DurstimDetails(2end)');
[r,p] = corrcoef(StimDurationFromStimulusDetails(1:end-1),StimDurationsFromEventData(2:end))
% turns out that StimDurationFromStimulusDetails(1:end-1) corresponds to
% StimDurationsFromEventData(2:end) why? I don't know...
%% look at the LED 
LEDStartTimes = [e.LED1(2:end).start];
LEDStopTimes = [e.LED1(2:end).stop];
LEDDurs = LEDStopTimes - LEDStartTimes;
whichTrialsHaveLED = ismember(TrialNumInStimEventData,LEDTrialNumsFromEventData+1);
[r,p] = corrcoef(LEDDurs,StimDurationsFromEventData(whichTrialsHaveLED));

% load the ADC1 - LED values
[d,t,i] = load_open_ephys_data('E:\mdemo_LED_2015-12-30_12-46-16\100_ADC1.continuous');

% loop through the LEDStartTimes and sample the LEDStim around it (10 ms
% before, 10 ms after)

%% Onset
LEDStimulusSamples = zeros(length(LEDStartTimes),600);
for j = 1:length(LEDStartTimes)
    [~,loc] = min(abs(t-LEDStartTimes(j)));
    LEDStimulusSamples(j,:) = d(loc-299:loc+300);
end
meanLED = mean(LEDStimulusSamples);
stdLED = std(LEDStimulusSamples,[],1);
tRef = linspace(-10,10,600);
plot(tRef,meanLED,'k');
hold on;
plot(tRef,meanLED+stdLED,'k--');
plot(tRef,meanLED-stdLED,'k--');
xlabel('Time Since LED Onset (ms)');
ylabel('LED Luminance Value(arbitrary)');
title('LED Onset Timecourse');

%% plot individual curves
plot(tRef,LEDStimulusSamples);

%% Offset
LEDStimulusSamples = zeros(length(LEDStopTimes),600);
for j = 1:length(LEDStopTimes)
    [~,loc] = min(abs(t-LEDStopTimes(j)));
    LEDStimulusSamples(j,:) = d(loc-299:loc+300);
end
meanLED = mean(LEDStimulusSamples);
stdLED = std(LEDStimulusSamples,[],1);
tRef = linspace(-10,10,600);
plot(tRef,meanLED,'k');
hold on;
plot(tRef,meanLED+stdLED,'k--');
plot(tRef,meanLED-stdLED,'k--');
xlabel('Time Since LED Offset (ms)');
ylabel('LED Luminance Value(arbitrary)');
title('LED Offset Timecourse');

%% plot individual curves
plot(tRef,LEDStimulusSamples);