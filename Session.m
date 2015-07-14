classdef Session
    properties
        sessionID % rip From Folder
        timeStamp % get automatically
        
        subject   
        electrode % grouping of electrodes. (single or multi-channel).
        monitor   % all 3 of these object in the 'hardware' folder
        rig
        
        sessionPath   
        sessionFolder  
        trialDataPath 
        trials
        
        trodes
        eventData
                
        history       = {};
    end
    methods
        function sess = Session(subject,sessionPath,sessionFolder,trialDataPath, etrode, mon, rigState)
            assert(ischar(subject),'subject input is not a character')
            sess.subject = subject;
                        
            sess.timeStamp = now;
            
            assert((exist(sessionPath,'dir')==7),'No Access to sessionPath or not correct path');
            sess.sessionPath = sessionPath;
            
            assert((exist(fullfile(sessionPath,sessionFolder),'dir')==7),'No Access to sessionFolder or not correct path');
            sess.sessionFolder = sessionFolder;
            
            assert((exist(trialDataPath,'dir')==7),'No Access to trialDataPath or not Correct path');
            sess.trialDataPath = trialDataPath;
            
            assert(isa(etrode,'electrode'),'etrode is not an electrode');
            sess.electrode = etrode;
            
            assert(isa(mon,'monitor'),'mon is not a monitor');
            sess.monitor = mon;
 
            assert(isa(rigStat,'rig'),'rigStat is not a rig');
            sess.rig = rigStat;
            
            sess.sessionID = sprintf('%s_%s',upper(subject),datestr(sess.timeStamp,30));
            sess.history{end+1} = sprintf('Initialized session @ %s',datestr(sess.timeStamp,21));
        end
        
        function session = process(session)            %
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
            
            % 1. get events data (##pass in correct file)
            session.eventData = eventData(session.trialDataPath);
            
            % 2. get the trodes for the electrode
            session.trodes = session.electrode.getPotentialTrodes;
            
            % 3. detect spikes
            session = session.detectSpikes;
            
            % 4. sort spikes
            session = session.sortSpikes;

                
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
        
        function session = detectSpikes(session)
            for i = 1:length(session.trodes)
                dataPath = fullfile(session.sessionPath,session.sessionFolder);
                session.trodes(i) = session.trodes(i).detectSpikes(dataPath);
            end
        end
        
        function [fileName] = saveSession(session)  % save session as a struct to mat file
            fileName = [session.sessionFolder,'___',int2str(session.timeStamp),'.mat'];
            save(fileName, '-v7.3'); %for some reason wouldnt save correctly unless '-v7.3' command added
        end
    end
end