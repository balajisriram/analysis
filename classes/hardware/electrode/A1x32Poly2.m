classdef A1x32Poly2<electrode
    
    properties (Constant=true)
        mapChans = [3 4 14 5 13 6 12 7 11 8 10 9 15 16 2 1 32 31 17 18 24 23 25 22 26 21 27 20 28 19 29 30]; % mappings to neuronexus
        groupings = {[15,16,17,18],[13,14,19,20],[11,12,21,22],[9,10,23,24],[7,8,25,26],[5,6,27,28],[3,4,29,30],[1,2,31,32]}; % standard neuronexus groupings
    end
    
    methods
        %% constructor
        function e = A1x32Poly2(varargin)
            e.type = 'Neuronexus';
            e.numChans = 32;
            e.configuration = '4 Shank; 2 tets per shank';            
        end % electrode
        
        %% getPotentialTrodes (returns which channels to group together).
        function trodes = getPotentialTrodes(etrode, path, folder)
            trodes = [];
            [~,~,~,~,etrode.disabled] = rankContinFiles([path, '\', folder],1); 
            %etrode.disabled = []; %testing
            for groups = 1:length(etrode.groupings)
                if ~isempty(setdiff((etrode.groupings{groups}),etrode.disabled))
%                     trodes = [trodes trode(setdiff((etrode.groupings{groups}),etrode.disabled))];
                    if etrode.mapChans == -1
                        trodes = [trodes trode(setdiff((etrode.groupings{groups}),etrode.disabled))];
                    else
                        trodes = [trodes trode(setdiff(etrode.mapChans(etrode.groupings{groups}),etrode.disabled))];
                    end
                end
            end
        end

    end %methods
end % classdef