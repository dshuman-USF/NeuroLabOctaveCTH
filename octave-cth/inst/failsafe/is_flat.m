% Utility function to see if a CTH is a flat
% INPUTS: cth:       cth number
%         namesnof:  name list of non-flat cths
%         flatnames: name list of flat cths
%
% OUTPUTS exists:  true if there is such cth. It could be a sparse or
%                  not in the dataseta
%                  false if we can't find it
%         flat:    if exists is true, this is true if it is a flat, false otherwise. 

function [exists flat] = is_flat(cth,namesnof,flatnames)
   srch_name=sprintf("_%05d$",cth);  % use seq # at end of string
   f_idx = regexp(flatnames,srch_name);   % a flat name?
   pos = find(~cellfun('isempty',f_idx));
   if ~isempty(pos)
      exists = true;
      flat = true;
   else
      f_idx = regexp(namesnof,srch_name);   % not a flat name?
      pos = find(~cellfun('isempty',f_idx));
      if ~isempty(pos)
         exists = true;
         flat = false;
      else
         exists = false;   % does not exist.
         flat = false;
      end
   end
end
