%    Copyright (C) 2014-2020 K. F. Morris

%    This file is part of the USF CTH Clustering software suite.
%    This software is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.

%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.

%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <https://www.gnu.org/licenses/>.
%
%
% Function to normalize a .type file that is being loaded as if it were a .cth file
% We sometimes do this to cluster the .type files using various clustering algorithms.
% If newly discovered clusters were added in to the initial .type file, they may
% not be normalized to the same area or period that the rest of the CTHs were. This
% function adjusts the CTHs to the maximum area or period for the current data set.
% Passed:  CthVars: Holder of just about everything nonflat
%          namesnof: Name index into CthVArsl
% Returns: possibly renormalized CTHs

function [renormed] = renorm_cths(CthVars,namesnof)
   renormed=[];
   norm_type = getnorm(namesnof{1});
   max_val = 0;

   if strcmp(norm_type,"n")  % this probably breaks lots of stuff
      renormed = CthVars;
      return
   end

   for name_idx = 1:length(namesnof)
      if strcmp(norm_type,"m")
         curr_max = sum(CthVars.(namesnof{name_idx}).NSpaceCoords);
      elseif strcmp(norm_type,"p") || strcmp(norm_type,"u")
         curr_max = max(CthVars.(namesnof{name_idx}).NSpaceCoords);
      end
      if max_val < curr_max
         max_val = curr_max;
      end
   end

   for name_idx = 1:length(namesnof)
      if strcmp(norm_type,"m")
         factor = sum(CthVars.(namesnof{name_idx}).NSpaceCoords);
      elseif strcmp(norm_type,"p") || strcmp(norm_type,"u")
         factor = max(CthVars.(namesnof{name_idx}).NSpaceCoords);
      end
      scale = factor/max_val;
      CthVars.(namesnof{name_idx}).NSpaceCoords = CthVars.(namesnof{name_idx}).NSpaceCoords/scale;
   end
   renormed = CthVars;
end
