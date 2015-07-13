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
            trodes =  getIndividualChannelsAsTrodes(etrode);
        end
        
        function trodes = getIndividualChannelsAsTrodes(etrode)
            chans = 1:etrode.numChans;
            chans = chans(~ismember(chans,etrode.disabled));
            trodes = 
        end
    end %methods
end % classdef