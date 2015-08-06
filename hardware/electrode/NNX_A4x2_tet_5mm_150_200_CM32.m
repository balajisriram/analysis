classdef NNX_A4x2_tet_5mm_150_200_CM32<electrode
    
    properties (Constant=true)
        mapChans = [3 4 14 5 13 6 12 7 11 8 10 9 15 16 2 1 32 31 17 18 24 23 25 22 26 21 27 20 28 19 29 30];
        groupings = {[1,3,6,8],[2,4,5,7],[9,11,14,16],[10,12,13,15],[17,19,22,24],[18,20,21,23],[25,27,30,32],[26,28,29,31]};
        %groupings = {[1],[2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13],[14], [15], [16], [17], [18],[19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32]};
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
%                     trodes = [trodes trode(setdiff((etrode.groupings{groups}),etrode.disabled))];
                    trodes = [trodes trode(setdiff(etrode.mapChans(etrode.groupings{groups}),etrode.disabled))];
                end
            end
        end

    end %methods
end % classdef