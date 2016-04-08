function session = finishClustering(session, start, finish)

for i = start:finish
    try
        session.trodes(i) = session.trodes(i).sortSpikes();
        det.identifier = ['Session.sortSpikes ', datestr(now)];
        det.message = sprintf('sorted on trode %d of %d',i, length(session.trodes));
        session = session.addToHistory('Completed',det);
        fName = saveSession(session);          %saves session between each sort just in case fails.
    catch ex
        session = session.addToHistory('Error',ex);
        fName = saveSession(session);
    end
end

end