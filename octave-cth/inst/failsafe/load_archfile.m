% Load a archetype file.
% INPUTS: centname:   path/filename
%         bins:       # bins in current .cth file
% OUTPUTS: a_centers: N-space archetypes array in file order
%          a_names:   names of archetypes
%          a_nums:    the arch numbers
%          a_valid:   true if a valid file, false otherwise  

function [a_centers a_names a_nums a_valid] = load_archfile(archname,bins)
   a_centers=[];
   a_names={};
   a_nums=[];
   a_valid = true;
   try
      archvars =load(archname,'A_*');
   catch
      archvars={};
   end
   if isempty(archvars) == 1    % no A_ vars
      ui_msg("ERROR WARNThis is not a valid archetype file, not loaded");
      a_valid = false;
      return
   end

   a_names=fieldnames(archvars);
   arch_bins=length(archvars.(a_names{1}).NSpaceCoords);
   if arch_bins != bins
      ui_msg(sprintf("ERROR WARNThe current CTH file has %d bins, the archetype file has %d bins\nThe number of bins must be the same.",bins,arch_bins));
     a_valid = false;
     return;
   end
   load(archname,'CTH_VERSION');
   load(archname,'ExpName_0001');
   ui_msg(sprintf("Loading %s\n%s\nArchetype info: %s",archname,CTH_VERSION,ExpName_0001));
   pt = 1;
   for [val,key]=archvars 
      a_centers(pt,:) = val.NSpaceCoords;
      typenum=strsplit(key,'_')(end);
      a_nums=[a_nums;str2double(typenum{end})];
      pt = pt + 1;
   end
end
