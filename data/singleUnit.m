classdef singleUnit
    % singlueUnit class to store information neuron information. 
    
    properties
        groupID %which channels group picked up this neuron?
        unitID %unique ID for this neuron among groupID
        timestamp %list of timestamps where this neuron fired
        waveform %list waveforms of spikes produced by neuron
    end
    
    methods
        %ctor, basically just a storage class for now
        function unit = singleUnit(group, id, ts, wf)
            unit.groupID = group;
            unit.unitID = id;
            unit.timestamp = ts;
            unit.waveform = wf;
        end
    end
    
end

