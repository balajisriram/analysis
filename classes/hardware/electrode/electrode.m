classdef electrode
    properties 
        type = 'generic';
        configuration = 'unknown';
        numChans = NaN;
        impedance = NaN;
        disabled = [];
        lowestDepth = [];
    end
    methods
        %% constructor
        function s = electrode(depth)
            s.lowestDepth = depth;
        end % electrode
        
        %% getPotentialTrodes (returns which channels to group together).
        function trodes = getPotentialTrodes(etrode,path,folder)
            warning('ideally should be set by the subclass. using defaults here');
            trodes =  getIndividualChannelsAsTrodes(etrode,path,folder); % ## added group 
        end
        
        function trodes = getIndividualChannelsAsTrodes(etrode)
            trodes = [];
            chans = setdiff(1:etrode.numChans,etrode.disabled);
            for i = 1:length(chans)
                trodes = [trodes trode(chans(i))];
            end
        end
    end %methods
end % classdef