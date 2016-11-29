function TestGLMFits
%% TestGLMFitting

numTrials = 100;

LeftRate = 10;
RightRate = 15;

LeftTrials = normrnd(LeftRate,.5,numTrials,1);
RightTrials = normrnd(RightRate,.5,numTrials,1);

InputVals = [1*ones(numTrials,1);0*ones(numTrials,1)];
InputCategory = categorical(InputVals);

plot(LeftTrials,1,'k+'); hold on
plot(RightTrials,0,'kx')

[mdl,dev,stats]= mnrfit([LeftTrials;RightTrials],InputCategory);

x = -20:.01:20;
y = mdl(2)*x+mdl(1);
plot(x,logistic(y),'k--');
set(gca,'YLim',[-0.1 2.1]);

Test = [LeftTrials;RightTrials];
pihats = mnrval(mdl,Test);
OutputVals = (pihats(:,1)<pihats(:,2));
[~,choice] = max(pihats,[],2);

plot(Test(choice==2),1,'bo');
plot(Test(choice==1),0,'ro');

performance = sum(InputVals==OutputVals)/length(OutputVals)
% keyboard
% PosTest = poissrnd(PositivePoissRate1,100,1);
% NegTest = poissrnd(NegativePoissRate1,100,1);
% TestActual = [ones(100,1);zeros(100,1)];
% prediction = mnrval(mdl,[PosTest;NegTest]')>0.5;



% performance = sum(prediction==TestActual)/length(prediction)
end
%% 
function y = logistic(x);
y = (exp(x)./(1+exp(x)));
end