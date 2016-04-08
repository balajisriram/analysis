classdef NNX_A1x32_Poly3_5mm_25s_117<electrode
    
    properties (Constant=true)
        mapChans = [3 4 14 5 13 6 12 7 11 8 10 9 15 16 2 1 32 31 17 18 24 23 25 22 26 21 27 20 28 19 29 30]; % mappings to neuronexus
        groupings = {[1,11,22,32],[2,3,12,21],[12,21,30,31],[3,4,13,21],[13,21,29,30],[4,5,13,20],[13,20,28,29],[5,6,14,20],[14,20,27,28],...
            [6,7,14,19],[14,19,26,27],[7,8,15,19],[15,19,25,26],[8,9,15,18],[15,18,24,25],[9,10,16,18],[16,18,23,24],[10,16,17,23]}; %poly3 groupings
    end
    
    methods
        %% constructor
        function e = NNX_A1x32_Poly3_5mm_25s_117(varargin)
            e.type = 'Neuronexus';
            e.numChans = 32;
            e.configuration = '4 Shank; 2 tets per shank';            
        end % electrode
        
        %% getPotentialTrodes (returns which channels to group together).
        function trodes = getPotentialTrodes(etrode, path, folder)
            trodes = [];
            [~,~,~,~,etrode.disabled] = rankContinFiles([path, '\', folder],1); %decides whether or not to disable any trodes
            %etrode.disabled = []; %testing
            for groups = 1:length(etrode.groupings)
                if ~isempty(setdiff((etrode.groupings{groups}),etrode.disabled))
%                     trodes = [trodes trode(setdiff((etrode.groupings{groups}),etrode.disabled))];
                    if etrode.mapChans == -1  % for testing
                        trodes = [trodes trode(setdiff((etrode.groupings{groups}),etrode.disabled))];
                    else
                        trodes = [trodes trode(setdiff(etrode.mapChans(etrode.groupings{groups}),etrode.disabled))]; 
                    end %maps trode and groups channels to corresponding channels on hardware
                end
            end
        end

    end %methods
end % classdef