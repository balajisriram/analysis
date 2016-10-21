function AnalyseVectorSums
location = 'C:\Users\ghosh\Desktop\PhysData\VectorSum';
d = dir(location);
d = d(~ismember({d.name},{'.','..'}));
STR = [];
ANG = [];
fileID = [];
unitNUM = [];
trodeNUM = [];
for i = 1:length(d)
    temp = load(fullfile(location,d(i).name));
    if ~isempty(temp.out.strength)
        STR = [STR temp.out.strength];
        ANG = [ANG temp.out.angle];
        fileID = [fileID i*ones(size(temp.out.strength))];
        unitNUM = [unitNUM temp.out.ident.unitNum];
        trodeNUM = [trodeNUM temp.out.ident.trodeNum];
    end
end

polar([ANG;ANG],[zeros(size(STR));STR],'k');
keyboard
end