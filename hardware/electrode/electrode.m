classdef electrode
    properties 
        type = 'generic';
        configuration = 'unknown';
        numChans = NaN;
        impedance = NaN;
        disabled = [];
    end
    methods
        %% constructor
        function s = electrode()
        end % electrode
        
        %% getPotentialTrodes (returns which channels to group together).
        function trodes = getPotentialTrodes(etrode)
            warning('ideally should be set by the subclass. using defaults here');
            trodes =  getIndividualChannelsAsTrodes(etrode, 1); % ## added group 
        end
        
        function trodes = getIndividualChannelsAsTrodes(etrode)
            trodes = trode(1,etrode.numChans);
            for i = 1:etrode.numChans
                trodes(i) = trode(i);
            end
        end
    end %methods
end % classdef