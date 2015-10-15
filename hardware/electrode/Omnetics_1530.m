classdef Omnetics_1530<electrode
    
    properties (Constant=true)
        mapChans = 1:32; % mappings seem to be consistent?
        groupings = {[1,2,31,32],[3,4,29,30],[5,6,27,28],[7,8,25,26],[9,10,23,24],[11,12,21,22],[13,14,19,20],[15,16,17,18]}; % standard omnetics groupings
    end
    
    methods
        %% constructor
        function e = Omnetics_1530(varargin)
            e.type = 'Omnetics1530';
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