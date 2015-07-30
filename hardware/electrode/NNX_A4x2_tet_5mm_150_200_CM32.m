classdef NNX_A4x2_tet_5mm_150_200_CM32<electrode
    
    properties (Constant=true)
        groupings = {[1],[2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13],[14], [15], [16], [17], [18],[19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32]};
        %groupings = {[1,2],[3,4]}
    end
    
    methods
        %% constructor
        function e = NNX_A4x2_tet_5mm_150_200_CM32(varargin)
            e.type = 'Neuronexus';
            e.numChans = 32;
            e.configuration = '4 Shank; 2 tets per shank';
            
        end % electrode
        
        %% getPotentialTrodes (returns which channels to group together).
        function trodes = getPotentialTrodes(etrode, path, folder)
            trodes = [];
            [~,~,~,~,etrode.disabled] = rankContinFiles([path, '\', folder],1); 
            for groups = 1:length(etrode.groupings)
                if ~isempty(setdiff((etrode.groupings{groups}),etrode.disabled))
                    trodes = [trodes trode(setdiff((etrode.groupings{groups}),etrode.disabled))];
                end
            end
        end

    end %methods
end % classdef