function trodeStr = createTrodeName(trodeChans)
if isempty(trodeChans.chans) % ## other if statements were no longer necessary
    error('trodeChans should be a numeric array');
end
trodeStr = mat2str(trodeChans.chans);
trodeStr = regexprep(regexprep(regexprep(trodeStr,' ','_'),'[',''),']','');
trodeStr = sprintf('trode_%s',trodeStr);
end