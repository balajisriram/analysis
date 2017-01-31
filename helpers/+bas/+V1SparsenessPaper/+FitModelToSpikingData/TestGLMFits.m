function TestGLMFits
%% TestGLMFitting



%% mdl1
numTrials = 100;
LeftRate = 0.5;
RightRate = 0.6;

LeftTrials1 = normrnd(LeftRate,.5,numTrials,1);
RightTrials1 = normrnd(RightRate,.5,numTrials,1);

InputVals = [1*ones(numTrials,1);0*ones(numTrials,1)];
InputCategory = categorical(InputVals);
% figure;
% plot(LeftTrials1,1,'k+'); hold on
% plot(RightTrials1,0,'kx')

[mdl1,dev,stats]= mnrfit([LeftTrials1;RightTrials1],InputCategory);

% x = -20:.01:20;
% y = mdl1(2)*x+mdl1(1);
% plot(x,logistic(y),'k--');
% set(gca,'YLim',[-0.1 2.1]);

Test1 = [LeftTrials1;RightTrials1];
pihats = mnrval(mdl1,Test1);
OutputVals = (pihats(:,1)<pihats(:,2));
[~,choice] = max(pihats,[],2);

% plot(Test1(choice==2),1,'bo');
% plot(Test1(choice==1),0,'ro');

performance1 = sum(InputVals==OutputVals)/length(OutputVals);

%% mdl2
numTrials = 100;
LeftRate = 5;
RightRate = 0.2;

LeftTrials2 = normrnd(LeftRate,.5,numTrials,1);
RightTrials2 = normrnd(RightRate,.5,numTrials,1);

InputVals = [1*ones(numTrials,1);0*ones(numTrials,1)];
InputCategory = categorical(InputVals);
% figure;
% plot(LeftTrials2,1,'k+'); hold on
% plot(RightTrials2,0,'kx')

[mdl2,dev,stats]= mnrfit([LeftTrials2;RightTrials2],InputCategory);

% x = -20:.01:20;
% y = mdl2(2)*x+mdl2(1);
% plot(x,logistic(y),'k--');
% set(gca,'YLim',[-0.1 2.1]);

Test2 = [LeftTrials2;RightTrials2];
pihats = mnrval(mdl2,Test2);
OutputVals = (pihats(:,1)<pihats(:,2));
[~,choice] = max(pihats,[],2);

% plot(Test(choice==2),1,'bo');
% plot(Test(choice==1),0,'ro');

performance2 = sum(InputVals==OutputVals)/length(OutputVals);


%% add both
mdlBoth = [mdl1 mdl2];
TestBoth = [Test1 Test2];

InputVals = [1*ones(numTrials,1);2*ones(numTrials,1)];
InputCategory = categorical(InputVals);


mdlBoth = mnrfit(TestBoth,InputCategory);
pihats = mnrval(mdlBoth,TestBoth);
OutputVals = (pihats(:,1)<pihats(:,2));
[~,choice] = max(pihats,[],2);
performanceBoth = sum(InputVals==OutputVals)/length(OutputVals);


%%
% keyboard
y1 = mdl1(2)*Test1+mdl1(1);
y2 = mdl2(2)*Test2+mdl2(1);

plot(y1+y2);

OutputVals = ((y1+y2)<0);
performanceSummed = sum(InputVals==OutputVals)/length(OutputVals);
%%
disp([performance1 performance2 performanceBoth performanceSummed])
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