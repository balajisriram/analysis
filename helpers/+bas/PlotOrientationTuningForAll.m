%% Characterize the firing rates
warning off;
dataFolders = {...
    'C:\Users\ghosh\Desktop\PhysData\284\InspectedSessions',...
    'C:\Users\ghosh\Desktop\PhysData\bas070\InspectedSessions',...
    'C:\Users\ghosh\Desktop\PhysData\bas072\InspectedSessions',...
    'C:\Users\ghosh\Desktop\PhysData\bas074\InspectedSessions'};
saveLocFigures = 'C:\Users\ghosh\Desktop\PhysData\Figures';
saveLocTunings = 'C:\Users\ghosh\Desktop\PhysData\Tunings';
numUnitsTotal = 0;
frUnits = [];
swUnits = [];
failures = [];
for i = 1:length(dataFolders);
    fprintf('i = %d\n',i);
    d = dir(dataFolders{i});
    d = d(~ismember({d.name},{'.','..'}));
    for j = 1:length(d)
        fprintf('filename = %s\n',d(j).name);
        try
            mkdir(fullfile(saveLocFigures,d(j).name));
            temp = load(fullfile(dataFolders{i},d(j).name));
            
%             fs = temp.sess.plotAllORTuning;
            tunings = temp.sess.getAllORTuning;
            
%             for k = 1:length(fs)
%                 set(fs(k),'units','normalized','outerposition',[0 0 1 1]);
%                 saveas(fs(k),fullfile(saveLocFigures,d(i).name,sprintf('%d.jpg',k)));
%                 close(fs(k));
%             end
            save(fullfile(saveLocTunings,d(j).name),'tunings');clear tunings;
        catch ex
            disp('failed')
            close all;
            failures(end+1).which = d(j).name;
            failures (end).reason = ex;
            clear tunings
        end
    end
end