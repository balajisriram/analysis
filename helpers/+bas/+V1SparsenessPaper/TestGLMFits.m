%% TestGLMFitting

NegRate1 = 2;
PosRate1 = 3;

PosRate2 = 0;
NegRate2 = 5;
PosTrials1 = normrnd(PosRate1,.5,100,1);
NegTrials1 = normrnd(NegRate1,.5,100,1);

plot(PosTrials1,1,'b+'); hold on
plot(NegTrials1,0,'rx')


[mdl,dev,stats]= mnrfit([PosTrials1;NegTrials1],[ones(100,1);2*ones(100,1)])

x = -20:.01:20;
y = mdl(2)*x+mdl(1);
plot(x,exp(y)./(1+exp(y)),'k--');
set(gca,'YLim',[-0.1 1.1]);
% PosTest = poissrnd(PositivePoissRate1,100,1);
% NegTest = poissrnd(NegativePoissRate1,100,1);
% TestActual = [ones(100,1);zeros(100,1)];
% prediction = mnrval(mdl,[PosTest;NegTest]')>0.5;



% performance = sum(prediction==TestActual)/length(prediction)