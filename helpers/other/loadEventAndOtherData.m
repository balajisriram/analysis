load('E:\workingSessionsnoWaveform\bas079_2016-06-23_13-56-26_736610_Inspected.mat')

%%
e = sess.eventData;
e.eventFolder = '\\ghosh-nas.ucsd.edu\ghosh\Temporary Items\bas079_06_23';
e = e.openMessages(fullfile(e.eventFolder,'messages.events')); %reads messages.events text file
e = e.getChannelEvents();         %builds e.out from openEphys .event method
%% if its fucked up
e.out(1).eventTimes = e.out(1).eventTimes(2:end);
e.out(1).eventID = e.out(1).eventID(2:end);
e.out(1).eventType = e.out(1).eventType(2:end);
e.out(1).sampNum = e.out(1).sampNum(2:end);
e.out(1).eventID(2:2:end) = 0;
%% okay proceed
mappings = 'phys';
e = e.getTrialEvents(mappings);   %gets info from e.out section
e = e.getTrialInfo();

%% load it back and save
sess.eventData = e;
save('E:\workingSessionsnoWaveform\bas079_2016-06-23_13-56-26_736610_Inspected.mat','sess')
