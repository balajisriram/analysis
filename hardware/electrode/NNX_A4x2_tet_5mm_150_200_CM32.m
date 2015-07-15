classdef NNX_A4x2_tet_5mm_150_200_CM32<electrode
    properties
        % ## dont need because defined in superclass
        %impedance = NaN;
        %disabled = [];
    end
    
    properties (Constant=true)
        groupings = {[1 2]};
    end
    
    methods
        %% constructor
        function e = NNX_A4x2_tet_5mm_150_200_CM32()
            e.type = 'Neuronexus';
            % ## changing for now to test - e.numChans = 32;
            e.numChans = 2;
            e.configuration = '4 Shank; 2 tets per shank';
        end % electrode
        
        %% getPotentialTrodes (returns which channels to group together).
        function trodes = getPotentialTrodes(etrode)
            trodes = [];
            for groups = 1:length(etrode.groupings)
                trodes = [trodes trode(etrode.groupings{groups})];
            end
        end

    end %methods
end % classdef