locStart = '/media/ghosh/My Passport/workingSessions';
locEnd = '/media/ghosh/My Passport/workingSessionsnoWaveform';
d = dir(locStart);
d = d(~ismember({d.name},{'.','..'}));
SessionName = cell(size(d));
HasStimRecords = false(size(d));
HadErrorWithStimLoad = HasStimRecords;
NumUnits = nan(size(d));

for i = 1:length(d)
    load(fullfile(locStart,d(i).name));
    SessionName{i} = d(i).name;
    HasStimRecords(i) = ~isempty(sess.trialDetails);
    HadErrorWithStimLoad(i) = strcmp(sess.history{3}{2},'BAD_TIMESTAMPS');
    NumUnits(i) = sess.numUnits;
    % now remove spikewaveformData
    for j = 1:sess.numTrodes
        sess.trodes(j).spikeWaveForms = [];
        for k = 1:sess.trodes(j).numUnits
            sess.trodes(j).units(k).waveform = [];
        end
    end
    save(fullfile(locEnd,d(i).name),'sess');
    clear sess;
    
end