# return the type of normalization used for the current .cth file
# see getseq.m for more info on name format
function norm = getnorm(name)
   norm='';
   fields = strsplit(name,'_');
   if length(fields) > 3
      norm = fields{end-4};
   end
end
