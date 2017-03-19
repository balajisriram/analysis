function durs = fixDurations(durs)
durs(durs<0.055) = 0.05;
durs(durs>=0.055 & durs<0.11) = 0.1;
durs(durs>=0.11 & durs<0.19) = 0.15;
durs(durs>=0.19 & durs<0.24) = 0.2;
durs(durs>=0.24 & durs<0.31) = 0.3;
durs(durs>=0.31 & durs<0.41) = 0.4;
durs(durs>=0.41) = 0.5;
end