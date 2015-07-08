classdef Session
    properties
        sessionID %rip From Folder
        timeStamp %get automatically
        
        subject   %rip from folder
        electrode %grouping of electrodes. (single or multi-channel).
        monitor   % all 3 of these object in the 'hardware' folder
        rig
        
        sessionPath   
        sessionFolder  
        trialDataPath 
        trials        
        
        history      
    end
    methods
        function sess = Session(sessionPath,sessionFolder,trialDataPath, electrodeName, monitorName, rigName, rigState) %(changed by adding "rigstate" to pass in as well)
            
            %added this because not sure better way to do it manually.
            addpath(genpath('hardware'));
            
            sess.timeStamp = now;
            
            % commented out for now to test
            %assert((exist(sessionPath,'dir')==7),'No Access to sessionPath or not correct path');
            sess.sessionPath = sessionPath;
            
            % commented out for now to test
            %assert((exist(fullfile(sessionPath,sessionFolder),'dir')==7),'No Access to sessionFolder or not correct path');
            sess.sessionFolder = sessionFolder;
            
            % commented out for now to test
            %assert((exist(trialDataPath,'dir')==7),'No Access to trialDataPath or not Correct path');
            sess.trialDataPath = trialDataPath;
            
            assert(ischar(electrodeName),'electrodeName is not a string');
            sess.electrode = electrode(electrodeName);
            
            assert(ischar(monitorName),'monitorName is not a string');
            sess.monitor = monitor(monitorName);
            
            % changed this to call constructor correctly, before only
            % passed one arg into constructor. 
            assert(ischar(rigName),'rigName is not a string');
            sess.rig = rig(rigName, rigState);
            
        end
        
        function [unitData eventsData] = process(session, spikeDetectionParams, spikeSortingParams, spikeModel) %had to add another parameter
            % loop through the channels, detect spikes, sort and then
            % output singleUnits, eventsData
            %
            % single units should be stored by electrode. i.e. 
            % singleUnit(i) is a list of singleUnits or identified clusters
            % for electrode i. 
            %
            % singleUnit should be its own class with the following fields
            % groupID = electrode this unit found in
            % unitID = unique ID for this particular unit in particular 
            %          electrode. 
            % timestamp = vector of timestamps that this waveform spike
            %             occured
            % waveform = waveform of spike at the timestamp
            %
            % eventsData should also be its own class with following fields
            % timestamp = time change occurs
            % toggle = rising edge or falling edge
            % eventID = what kind of event was it? trial, stim, etc... 
            
            addpath(genpath('helpers'));
            addpath(genpath('data'));
            
            % 1. get events data (##pass in correct file)
            eventsData = eventData(session.trialDataPath);
            
            % 2. get electrode grouping information to specify how to
            %    process spikes
            grouping = getPotentialGroups(session.electrode);
            
            % 3. use grouping info to process spikes            
            % i. cycle through each group
            % format of grouping: 1 3 6 = 2 groups: 1 3 6 and 2 4 5
            %                     2 4 5
            for group = 1:length(grouping)
                groupData = [];
                groupTimes = [];
                % a. for each channel in group
                for index = 1:length(grouping{group})
                    %builds filepath to pass into load function (hardcoded
                    %for now)
                    contFile = fullfile(session.sessionPath,session.sessionFolder,['108_CH',int2str(grouping{group}(index)),'.continuous']);

                    % i. load the cont data of each file
                    [rawData, rawTimestamps, rawInfo] = load_open_ephys_data(contFile);

                    % ii. combine raw data into one largers set. i.e. if
                    % group size == 4 and data length == 10. rawData should
                    % be 1x10 and groupData should be 4x10
                    groupData = [groupData rawData];
                    groupTimes = [groupTimes rawTimestamps];
                    disp(size(groupData));
                end
                % b. detect spike on possibly grouped raw data 
                [spikes, spikeWaveforms, spikeTimes]= detectSpikesFromNeuralData(groupData, groupTimes, spikeDetectionParams);
                unitData.spikes = spikeWaveforms;
                
                % c. cluster grouped spikes
               % [assignedClusters, rankedClusters, spikeModel] = sortSpikesDetected(spikes, spikeWaveforms, spikeTimes, spikeSortingParams, spikeModel);
                
                %unitData.assigned = assignedClusters;
                % d. add any cluster found to unitData
                
                
            end
            
            
        end        
    end
end