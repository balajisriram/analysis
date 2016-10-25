
%create some obviously unimodal and bimodal Gaussian distributions just to
%see what dip statistic does
% Nic Price 2006

Cent1 = ones(1,9);
Cent2 = 1:1:9;
sig = 0.5;
nboot = 500;
dip = [];
p = [];
tic
for a = 1:length(Cent1),
    xpdf = sort([Cent1(a)+randn(1,200) Cent2(a)+randn(1,200)]); %allocate 200 points in each
    [dip, p] = HartigansDipSignifTest(xpdf, nboot);
    
    subplot(3,3,a)
    hist(xpdf,-2:0.25:12)    
    title(['dip=',num2str(dip,3), ', p=',num2str(p,3)])
    xlim([-2 12])
end
% FixAxis([-2 12]);
toc