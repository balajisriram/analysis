loc = '\\ghosh-nas.ucsd.edu\ghosh\Physiology\InspectedSessions';
saveLoc = 'C:\Users\ghosh\Desktop\sessionReports';

d = dir(loc);
d = d(~ismember({d.name},{'.','..'}));

errorReport = {};
for i = 1:length(d)
    clear sess;
    try
        load(fullfile(loc,d(i).name));
        sessReport = sess.getReport();
        
        save(fullfile(saveLoc,d(i).name),'sessRepport');
    catch ex
        errorReport{end+1}.name = d(i).name;
        errorReport{end+1}.exc = ex;
    end
end
