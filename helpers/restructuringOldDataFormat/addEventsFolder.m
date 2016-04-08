function success = addEventsFolder(fname)
    files = dir([fname,'\bas*']);
    cd(fname);
    for file = files'
        load(file.name);
        try
            sess = addToEventData(sess);
        catch ex
            disp(sess.sessionFolder);
        end
    end
    success = 1;
end