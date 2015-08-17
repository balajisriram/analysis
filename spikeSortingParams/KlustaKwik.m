classdef KlustaKwik <spikeSortingParam
    properties
        minClusters
        maxClusters
        nStarts
        splitEvery
        maxPossibleClusters
        featureList
        arrangeClustersBy
        postProcessing

    end
    
    methods
        function s = KlustaKwik(varargin)
            s = s@spikeSortingParam(varargin{1});
            switch nargin
                case 1
                    switch varargin{1}
                        case 'KlustaKwikStandard'
                            s.minClusters = 4;
                            s.maxClusters = 40;
                            s.nStarts = 1;
                            s.splitEvery = 5;
                            s.maxPossibleClusters = 50;
                            s.featureList = {'tenPCs'};
                            s.arrangeClustersBy = 'averageAmplitude';
                            s.postProcessing ='biggestAverageAmplitudeCluster';
                        otherwise
                            error('unkonwn Klustakwik params')
                    end
                case 2
                    param = varargin{2};
                    s.minClusters = param.minClusters;
                    s.maxClusters = param.maxClusters;
                    s.nStarts = param.nStarts;
                    s.splitEvery = param.splitEvery;
                    s.maxPossibleClusters = param.maxPossibleClusters;
                    s.featureList = param.featureList;
                    s.arrangeClustersBy = param.arrangeClustersBy;
                    s.postProcessing =param.postProcessing;
            end
        end
        
       
        function [assignedClusters, rankedClusters, spikeModel] = sortSpikesDetected(par, spikeWaveforms, spikeTimestamps)
            currentDir=pwd;
            tempDir=fullfile(currentDir,'helpers','KlustaKwik');
            cd(tempDir);

            [features, nrDatapoints, spikeModel.featureDetails] = calculateFeatures(spikeWaveforms,par.featureList);
            
            fid = fopen('temp.fet.1','w+');
            fprintf(fid,[num2str(nrDatapoints) '\n']);
            for k=1:length(spikeTimestamps)
                fprintf(fid,'%s\n', num2str(features(k,1:nrDatapoints)));
            end
            fclose(fid);

            % set which features to use
            featuresToUse='';
            for i=1:nrDatapoints
                featuresToUse=[featuresToUse '1'];
            end
            % now run KlustaKwik
            if ispc
                cmdStr=['KlustaKwik.exe temp 1 -MinClusters ' num2str(par.minClusters) ' -MaxClusters ' num2str(par.maxClusters) ...
                    ' -nStarts ' num2str(par.nStarts) ' -SplitEvery ' num2str(par.splitEvery) ...
                    ' -MaxPossibleClusters ' num2str(par.maxPossibleClusters) ' -UseFeatures ' featuresToUse ' -Debug ' num2str(0) ];
            elseif IsLinux
                cmdStr=['./KKLinux temp 1 -MinClusters ' num2str(par.minClusters) ' -MaxClusters ' num2str(par.maxClusters) ...
                    ' -nStarts ' num2str(par.nStarts) ' -SplitEvery ' num2str(par.splitEvery) ...
                    ' -MaxPossibleClusters ' num2str(par.maxPossibleClusters) ' -UseFeatures ' featuresToUse ' -Debug ' num2str(0) ];
            elseif ismac
                cmdStr=['./KKMac temp 1 -MinClusters ' num2str(par.minClusters) ' -MaxClusters ' num2str(par.maxClusters) ...
                    ' -nStarts ' num2str(par.nStarts) ' -SplitEvery ' num2str(par.splitEvery) ...
                    ' -MaxPossibleClusters ' num2str(par.maxPossibleClusters) ' -UseFeatures ' featuresToUse ' -Debug ' num2str(0) ];
            end
            system(cmdStr);
            pause(0.1);
            % read output temp.clu.1 file
            try
                fid = fopen('temp.clu.1');
                assignedClusters=[];
                while 1
                    tline = fgetl(fid);
                    if ~ischar(tline),   break,   end
                    assignedClusters = [assignedClusters;str2num(tline)];
                end
            catch
                warning('huh? no .clu?')
                keyboard
            end

            % throw away first element of assignedClusters - the first line of the cluster file is the number of clusters found
            assignedClusters(1)=[];
            rankedClusters = unique(assignedClusters);
            rankedClusters(rankedClusters==1)=[];
            switch par.arrangeClustersBy
                case 'clusterCount'
                    clusterCounts=zeros(length(rankedClusters),2);
                    for i=1:size(clusterCounts,1)
                        clusterCounts(i,1) = i;
                        clusterCounts(i,2) = length(find(assignedClusters==rankedClusters(i)));
                    end
                    clusterCounts=sortrows(clusterCounts,-2);
                    rankedClusters=rankedClusters(clusterCounts(:,1));
                case 'averageAmplitude'
                    clusterAmplitude=zeros(length(rankedClusters),2);
                    for i=1:size(clusterAmplitude,1)
                        clusterAmplitude(i,1) = i;
                        clusterAmplitude(i,2) = diff(minmax(mean(spikeWaveforms(assignedClusters==rankedClusters(i)),1)));
                    end
                    clusterAmplitude=sortrows(clusterAmplitude,-2);
                    rankedClusters=rankedClusters(clusterAmplitude(:,1));
                case 'averageSpikeWidth'
                    clusterSpikeWidth=zeros(length(rankedClusters),2);
                    for i=1:size(clusterSpikeWidth,1)
                        clusterSpikeWidth(i,1) = i;
                        avgWaveform = mean(spikeWaveforms(assignedClusters==rankedClusters(i)),1);
                        [junk, minInd] = min(avgWaveform);
                        [junk, maxInd] = max(avgWaveform);
                        clusterSpikeWidth(i,2) = abs(minInd-maxInd);
                    end
                    clusterSpikeWidth=sortrows(clusterSpikeWidth,-2);
                    rankedClusters=rankedClusters(clusterSpikeWidth(:,1));
                case 'spikeWaveformStdDev'
                    clusterStdDev=zeros(length(rankedClusters),2);
                    for i=1:size(clusterStdDev,1)
                        clusterStdDev(i,1) = i;
                        clusterStdDev(i,2) = mean(std(spikeWaveforms(assignedClusters==rankedClusters(i)),1));
                    end
                    clusterStdDev=sortrows(clusterStdDev,2); %ascending 
                    rankedClusters=rankedClusters(clusterStdDev(:,1));
                otherwise
                    error('unknown arrangeClusterBy method')
            end
            rankedClusters(end+1) = 1;
            fclose(fid);

            % create the model files from the model file
            modelFilePath = fullfile(tempDir,'temp.model.1');
            spikeModel.clusteringModel = par.klustaModelTextToStruct(modelFilePath);
            spikeModel.clusteringMethod = 'KlustaKwik';
            spikeModel.featureList = par.featureList;


            % change back to original directory
            cd(currentDir);
        end
        
    end
    methods (Static=true)
        function kk=klustaModelTextToStruct(modelFile)
            modelFile
            fid=fopen(modelFile,'r');  % this is only the first one!
            if fid==-1
                modelFile
                error('bad file')
            end
            kk.headerJunk= fgetl(fid);
            ranges= str2num(fgetl(fid));
            sz=str2num(fgetl(fid));
            kk.numDims=sz(1);
            kk.numClust=sz(2);
            kk.numOtherThing=sz(3); % this is not num features? 
            kk.ranges=reshape(ranges,[],kk.numDims);
            kk.mean=nan(kk.numClust,kk.numDims);
            xx.cov=nan(kk.numDims,kk.numDims,kk.numClust);
            for c=1:kk.numClust
                clustHeader=str2num(fgetl(fid));
                if clustHeader(1)~=c-1
                    %just double check
                    error('wrong cluster')
                end
                kk.mean(c,:)=str2num(fgetl(fid));
                kk.weight(c)=clustHeader(2);
                for i=1:kk.numDims
                    kk.cov(i,:,c)=str2num(fgetl(fid));
                end
            end
            fclose(fid);
        end
    end
end
