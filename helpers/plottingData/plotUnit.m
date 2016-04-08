function [ unit ] = plotUnit( unit )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

newUnit = [];
for i = 1:size(unit.waveform, 3)
    
    newUnit = [newUnit unit.waveform(:,:,i)];

end

plot(newUnit');

end

