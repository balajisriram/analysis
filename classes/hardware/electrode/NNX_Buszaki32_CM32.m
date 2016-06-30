classdef NNX_Buszaki32_CM32<electrode
    
    properties (Constant=true)
        mapChans = [3 4 14 5 13 6 12 7 11 8 10 9 15 16 2 1 32 31 17 18 24 23 25 22 26 21 27 20 28 19 29 30]; % mappings to neuronexus
        groupings = {[1,2,3,4,5,6,7,8],[9,10,11,12,13,14,15,16],[17,18,19,20,21,22,23,24],[25,26,27,28,29,30,31,32]}; %Buszaki 32 groupings
    end
    properties
        threshStdDev = 4; %default 5 std threshold
    end
    
    methods
        %% constructor
        function e = NNX_Buszaki32_CM32(varargin)
            e.type = 'Neuronexus';
            e.numChans = 32;
            e.configuration = '4 Shank; Buszaki 32 config';
            if length(varargin)==1
                e.threshStdDev = varargin{1};
            end
        end % electrode
        
        %% getPotentialTrodes (returns which channels to group together).
        function trodes = getPotentialTrodes(etrode, path, folder)
            trodes = [];
            %[~,~,~,~,etrode.disabled] = rankContinFiles([path, '\', folder],1); %decides whether or not to disable any trodes
            etrode.disabled = []; %testing
            for groups = 1:length(etrode.groupings)
                if ~isempty(setdiff((etrode.groupings{groups}),etrode.disabled))
%                     trodes = [trodes trode(setdiff((etrode.groupings{groups}),etrode.disabled))];
                    if etrode.mapChans == -1  % for testing
                        trodes = [trodes trode(setdiff((etrode.groupings{groups}),etrode.disabled), etrode.threshStdDev)];
                    else
                        trodes = [trodes trode(setdiff(etrode.mapChans(etrode.groupings{groups}),etrode.disabled), etrode.threshStdDev)]; 
                    end %maps trode and groups channels to corresponding channels on hardware
                end
            end
        end

    end %methods
end % classdef