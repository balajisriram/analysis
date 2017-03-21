function FIT_LOGISTIC = FitLogisticRegressionToData
if ~exist('SPIKEDETAILS','var')
    load('DetailsAt500MS')
end
tempSeed = rng;
rng(736774);
FIT_LOGISTIC = {};

tic
fprintf('\n');

for i = setdiff(1:length(SPIKEDETAILS),[])
    try
        numConditions = 1;
        numTests = 100;
        fitsThisSession = cell(numConditions,numTests);
        for l = 1:numConditions
            fprintf('session %d: ',i);
            or = SPIKEDETAILS{i}{l}.orientations;
            c = SPIKEDETAILS{i}{l}.contrasts;
            dur = SPIKEDETAILS{i}{l}.actualStimDurations;
            spR = SPIKEDETAILS{i}{l}.spikeRatesActual;
            
            stimToRight = double(or>0);
            
            whichNonZeroC = c>0;
            
            
            fprintf('test:')
            for j = 1:numTests
                fprintf('%d.',j);
                % train 70%, test 30%. train only on c>0
                whichTrain = whichNonZeroC & rand(size(whichNonZeroC))<0.7;
                whichTest = ~whichTrain;
                
                fit.trialsTrain = SPIKEDETAILS{i}{l}.trNums(whichTrain);
                fit.trialsTest = SPIKEDETAILS{i}{l}.trNums(whichTest);
                XTrain = spR(whichTrain,:);
                XTest = spR(whichTest,:);
                YTrain = stimToRight(whichTrain) +1; % Left = 1; Right = 2;
                fit.YTest = stimToRight(whichTest)+1;
                fit.cTest = c(whichTest);
                fit.dTest = dur(whichTest);
                fit.uid = SPIKEDETAILS{i}{l}.uid;
                fit.sessionName = SPIKEDETAILS{i}{l}.sessionName;
                % individual models
                IndividualModels = cell(1,size(spR,2));
                for k = 1:size(spR,2)
                    disp(k);
                    try
                        [mdl,dev,stats] = mnrfit(XTrain(:,k),YTrain);%,'Distribution','binomial');
                        IndividualModels{k}.Model = mdl;
                        IndividualModels{k}.Deviance = dev;
                        IndividualModels{k}.Stats = stats;
                        pihats = mnrval(mdl,XTest(:,k));
                        [~,choice] = max(pihats,[],2);
                        IndividualModels{k}.YPred = choice;
                        IndividualModels{k}.PredictionAccuracy = sum(fit.YTest==IndividualModels{k}.YPred)/length(fit.YTest);
                    catch ex
                        IndividualModels{k}.Model = [];
                        IndividualModels{k}.Deviance = [];
                        IndividualModels{k}.Stats = [];
                        IndividualModels{k}.YPred = [];
                        IndividualModels{k}.PredictionAccuracy = NaN;
                    end
                end
                fit.IndividualModels = IndividualModels;
                
                try
                    [mdl,dev,stats] = mnrfit(XTrain,YTrain);%,'constant','Upper','linear','Distribution','binomial');
                    FullModel.Model = mdl;
                    FullModel.Deviance = dev;
                    FullModel.Stats = stats;
                    
                    pihats = mnrval(mdl,XTest);
                    [~,choice] = max(pihats,[],2);
                    
                    FullModel.YPred = choice;
                    FullModel.PredictionAccuracy = sum(fit.YTest==choice)/length(fit.YTest);
                catch ex
                    FullModel.Model = [];
                    FullModel.Deviance = [];
                    FullModel.Stats = [];
                    FullModel.YPred = [];
                    FullModel.PredictionAccuracy = NaN;
                end
                
                fit.FullModel = FullModel;
                
                fitsThisSession{l,j} = fit;
            end
            fprintf('\n');
            %         FIT_LOGISTIC{i} = fitsThisSession;
            FitDataName = sprintf('FitThisSession%d_500.mat',i);
            save(FitDataName,'fitsThisSession')
        end
    catch ex
        getReport(ex)
        fprintf('failed for %d\n',i);
    end
end
toc
rng(tempSeed)

end