Open Ephys Analysis README

1. Processing the raw data
2. Changing spike detection parameters.
3. Changing spike sorting parameters.



			1. Processing the raw data

Provided in the "analysis/helpers" folder is the function "processAndSaveSession"

call the function as follows:

	sess = processAndSaveSession(dataFolder);

where dataFolder is folder containing the raw data. For Example: 
	
	sess = processAndSaveSession('D:\FullData074\bas074_2015-11-24_14-16-03');

Function processes data with default spike detection and spike sorting parameters.
Session will automatically be saved once sorting completes and can be found in folder function
is called in.



			2. Changing Spike Detection Parameters

The spike detection parameters can be found and changed in the file:

	 analysis\classes\spikeDetectionParams\filteredThreshold.m

Default parameters are as follows:
	
	freqLowHi = [200 10000]
        minmaxVolts
        thresholdVolts
        thresholdVoltsSTD
        waveformWindowMs = 1.5
        peakWindowMs = 0.6
        alignMethod = 'atPeak'
        peakAlignment = 'filtered'
        returnedSpikes = 'filtered'
        lockoutDurMs = 1
        thresholdMethod = 'std'
        ISIviolationMS = 1
        method = 'filteredThresh'
        samplingFreq = 30000;



			3. Changing Spike Sorting Parameters

The spike sorting parameters can be found and changed in the file:

	analysis\classes\spikeSortingParams\KlustaKwik.m

Default parameters are as follows:

	s.minClusters = 4;
        s.maxClusters = 30;
        s.nStarts = 1;
        s.splitEvery = 5;
        s.maxPossibleClusters = 30;
        s.featureList = {'tenPCs'};
        s.arrangeClustersBy = 'averageAmplitude';
        s.postProcessing ='biggestAverageAmplitudeCluster';

	