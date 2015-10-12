loc = '\\ghosh-nas.ucsd.edu\ghosh\Physiology\InspectedSessions';
saveLoc = 'C:\Users\ghosh\Desktop\sessionReports';

d = dir(loc);
d = d(~ismember({d.name},{'.','..'}));

errorReport = {};

d = struct;
d(1).name = 'bas070_2015-08-11_12-51-37_736208_Inspected.mat';
d(2).name = 'bas070_2015-08-20_12-27-00_736218_Inspected.mat';
d(3).name = 'bas070_2015-08-21_11-50-57_736219_Inspected.mat';
d(4).name = 'bas070_2015-08-24_12-06-06_736224_Inspected.mat';
d(5).name = 'bas070_2015-08-26_11-48-54_736231_Inspected.mat';

for i = 2:length(d)
    clear sess;
%     try
        load(fullfile(loc,d(i).name));
        out = sess.getReport();
        
        save(fullfile(saveLoc,[sess.sessionID '.mat']),'out');
%     catch ex
%         errorReport{end+1}.name = d(i).name;
%         errorReport{end}.exc = ex;
%     end
end
