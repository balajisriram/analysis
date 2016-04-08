files = dir(['C:\Users\Ghosh\Desktop\ProcessedSessions','\bas*']);
cd('C:\Users\Ghosh\Desktop\ProcessedSessions');
for file = files'
    load(file.name);
    try
        [specialCase, sess] = fixEventDataTrials(sess);
        fname = saveSession(sess);
    catch
        disp(sess.sessionFolder);
    end
end