% Function to normalize the archetype CTHs to conform to the normalization used
% for the current data set.
% Passed:  archetypes: matrix of archetype CTHs.
%          cth:        a representative cth from the data set. 
%                      Assumes all CTHs have identical normalization.
%          norm_type:  string that contains current normalization type.
%                      "m" is mean/area
%                      "p" is peak
%                      "u" is unit
%                      "n" is none, no adjustment.
%                          Note for the none case to work, the archetypes would have
%                          to have been generated from a set of CTHs that had no
%                          normalization. In general, the none case may not be
%                          useful for clustering with archetypes.
% Returns: normalized archetype CTHs

function [norm_centers] = renorm_archetypes(archetypes, cth, norm_type)
   norm_centers=[];

   if strcmp(norm_type,"m")
      area_norm = sum(cth);
      for i = 1:size(archetypes)(1)
         factor = sum(archetypes(i,:));
         scale = factor/area_norm;
         norm_centers(i,:) = archetypes(i,:)/scale;
      end
   elseif strcmp(norm_type,"p") || strcmp(norm_type,"u")
     peak = max(cth);
     for i = 1:size(archetypes)(1)
        factor = max(archetypes(i,:));
        scale = factor/peak;
        norm_centers(i,:) = archetypes(i,:)/scale;
      end
   else
      norm_centers=archetypes;
   end  
end
