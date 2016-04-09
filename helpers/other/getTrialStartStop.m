name = [];
startTrial = [];
endTrial = [];

files = dir('C:\Users\Ghosh\Desktop\ProcessedSessions\bas*');
cd('C:\Users\Ghosh\Desktop\ProcessedSessions');
i = 1;
for file = files'

    load(file.name);
    maxTrial = getMaxTrial(sess);
    minTrial = getMinTrial(sess);
    
    name = [name file.name];
    startTrial = [startTrial minTrial];
    endTrial = [endTrial maxTrial];
    save('sessionTrials');

end
