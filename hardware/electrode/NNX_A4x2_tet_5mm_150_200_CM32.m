classdef NNX_A4x2_tet_5mm_150_200_CM32<electrode
    properties 
        impedance = NaN;
        disabled = [];
    end
    methods
        %% constructor
        function e = NNX_A4x2_tet_5mm_150_200_CM32()
            e.type = 'Neuronexus';
            e.numChans = 32;
            e.configuration = {};
        end % electrode
        
        %% getPotentialTrodes (returns which channels to group together).
        function trodes = getPotentialTrodes(etrode)
            error('needs to be setup')
        end

    end %methods
end % classdef