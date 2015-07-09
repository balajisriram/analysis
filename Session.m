classdef Session
    properties
        sessionID % rip From Folder
        timeStamp % get automatically
        
        subject   % rip from folder
        electrode % grouping of electrodes. (single or multi-channel).
        monitor   % all 3 of these object in the 'hardware' folder
        rig
        
        sessionPath   
        sessionFolder  
        trialDataPath 
        trials
        
        groupMean
        groupStd
        rawData
        rawTimes
        
        unitData
        eventsData
        spikeData
        
        history      
    end
    methods
        function sess = Session(sessionPath,sessionFolder,trialDataPath, electrodeName, monitorName, rigName, rigState) %(changed by adding "rigstate" to pass in as well)
            
            %added this because not sure better way to do it manually.
            addpath(genpath('hardware'));
            
            index = strfind(sessionFolder, '_');
            sess.subject = sessionFolder(1:index(1));   %works for regular folders but commented out now for test
            
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
        
        function [unitData eventsData spikeData groupMean groupStd session] = process(session, spikeDetectionParams, spikeSortingParams) %had to add another parameter
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
            eventsData = eventData(fullfile(session.trialDataPath,'all_channels.events'));
            
            % 2. get electrode grouping information to specify how to
            %    process spikes
            grouping = getPotentialGroups(session.electrode);
            
            % 3. use grouping info to process spikes            
            % i. cycle through each group
            % format of grouping: 1 3 6 = 2 groups: 1 3 6 and 2 4 5
            %                     2 4 5
            allGroupsData = {};
            allGroupsTimes = {};
            allGroupsMean = {};
            allGroupsStd = {};
            allGroupsSpikes = {};
            allGroupsSpikeWaveforms = {};
            allGroupsSpikeTimes = {};
            allGroupsUnitData = {};
            
            %to fix small bug with empty cell on first iteration
            firstTime = 1;
  
            for group = 1:length(grouping)
                groupData = [];
                groupTimes = [];
                groupMean = [];
                groupStd = [];
                % a. for each channel in group
                for index = 1:length(grouping{group})
                    %builds filepath to pass into load function (hardcoded
                    %for now)
                    contFile = fullfile(session.sessionPath,session.sessionFolder,['108_CH',int2str(grouping{group}{index}),'.continuous']);

                    % i. load the cont data of each file
                    [rawData, rawTimestamps, rawInfo, dataMean, dataStd] = load_open_ephys_data(contFile);

                    % ii. combine raw data into one largers set. i.e. if
                    % group size == 4 and data length == 10. rawData should
                    % be 1x10 and groupData should be 4x10
                    groupData = [groupData rawData];
                    groupTimes = [groupTimes rawTimestamps];
                    groupMean = [groupMean dataMean];
                    groupStd = [groupStd dataStd];
                end
                allGroupsData = [allGroupsData groupData];
                allGroupsTimes = [allGroupsTimes groupTimes];
                allGroupsMean = [allGroupsMean groupMean];
                allGroupsStd = [allGroupsStd groupStd];
                
                % b. detect spike on possibly grouped raw data 
                [spikes, spikeWaveforms, spikeTimes]= detectSpikesFromNeuralData(groupData, groupTimes, spikeDetectionParams);
                %spikeData.spikes = spikes;
                %spikeData.spikeWaveforms = spikeWaveforms;
                %spikeData.spikeTimes = spikeTimes;
                allGroupsSpikes = [allGroupsSpikes spikes];
                allGroupsSpikeWaveforms = [allGroupsSpikeWaveforms spikeWaveforms];
                allGroupsSpikeTimes = [allGroupsSpikeTimes spikeTimes];
                
                %group spikewaveforms across multiple channels to one extended data set
                waveformsToCluster = [];
                spikesClust = [];
                spikeTimesClust = [];
                for i = 1:length(spikeWaveforms(1,1,:))
                    waveformsToCluster = [waveformsToCluster;spikeWaveforms(:,:,i)];
                    spikesClust = [spikesClust;spikes];
                    spikeTimesClust = [spikeTimesClust;spikeTimes];
                end

                % c. cluster grouped spikes
                [assignedClusters, rankedClusters, spikeModel] = sortSpikesDetected(spikesClust, waveformsToCluster, spikeTimesClust, spikeSortingParams);
                
                % d. set units as new found clusters 
                unitData = {};
                for i = 1:length(rankedClusters)
                    clusterWaveforms = {waveformsToCluster(assignedClusters == i,:)};
                    unitData = [unitData clusterWaveforms];
                end
                
                % so that first unitData set doesnt get combined with empty
                % cell array. Just for convenience.
                if firstTime == 1
                    allGroupsUnitData = unitData;
                    firstTime = -1;
                else
                    allGroupsUnitData = {allGroupsUnitData unitData};
                end
            end  
            
            spikeData.spikes = allGroupsSpikes;
            spikeData.spikeWaveforms = allGroupsSpikeWaveforms;
            spikeData.spikeTimes = allGroupsSpikeTimes;
            
            % 4. after goes through all groups, save all information
            %    into session object
            session.groupMean = allGroupsMean;
            session.groupStd = allGroupsStd;
            session.rawData = allGroupsData;
            session.rawTimes = allGroupsTimes;
        
            session.unitData = allGroupsUnitData;
            session.eventsData = eventsData;
            session.spikeData = spikeData;
            
        end      
        
        function [fileName] = saveSession(session)  % save session as a struct to mat file
            fileName = [session.sessionFolder,'___',int2str(session.timeStamp),'.mat'];
            save(fileName, '-v7.3'); %for some reason wouldnt save correctly unless '-v7.3' command added
        end
    end
end