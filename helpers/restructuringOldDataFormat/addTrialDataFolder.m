function success = addTrialDataFolder(fname)
    files = dir([fname,'\bas*']);
    cd(fname);
    for file = files'
        load(file.name);
        try
            [sess] = getTrialDetails(sess, [sess.trialDataPath,'\stimRecords'])
            fName = saveSession(sess);
        catch ex
            disp(sess.sessionFolder);
        end
    end
    success = 1;
end