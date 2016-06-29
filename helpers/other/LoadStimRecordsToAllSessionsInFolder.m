sessLocation = 'F:\070\070_InspectedSessions';
stimLocation = 'F:\070\StimRecords';
clc;
d = dir(sessLocation);
d = d(~ismember({d.name},{'.','..'}));
for i = 1:length(d)
    clear sess
    load(fullfile(sessLocation,d(i).name));
    sess.trialDetails = [];
    % sess should exist
    if ~isempty(sess.trialDetails)
        fprintf('\n%s : ALREADY DONE POPULATING',sess.sessionID);
        sess.printDetailsAboutSession;
        continue
    end
    
    id = d(i).name;
    locs = strfind(id,'_');
    id = id(locs(1)+1:locs(2)-1);
    stimrecfoldername = datestr(datevec(id,'yyyy-mm-dd'),'mmddyyyy');
    
    if ~isdir(fullfile(stimLocation,stimrecfoldername));
        fprintf('\n%s : DID NOT FIND STIM RECORDS FOLDER',sess.sessionID);
        continue
    end
    
    sess = sess.populateTrialDetails(fullfile(stimLocation,stimrecfoldername));
    
    fprintf('\n%s : FINISHED POPULATING',sess.sessionID);
    sess.printDetailsAboutSession;
    
    save(fullfile(sessLocation,d(i).name),'sess');
end