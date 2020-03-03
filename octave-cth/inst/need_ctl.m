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
% Utility to see if the current file has control periods.
% If so and we are clustering with archetypes, we need a standard type archetype
% file. For swallow and lareflex files with no control period information, we
% do not need a standard archtype file.
% See getseq.m for an explanation of the code below.

function found = need_ctl(CthVars)
   found = false;
   have_ctl = false;
   for [val,key]=CthVars
       namefields = strsplit(key,"_");
       if strcmp(namefields{1},"ZeroFlat") % always in 0 period, false positive
          continue;
       end
       period = namefields{end-1};
         % if only 11 or 13, not needed,  period 9 is cs-delta, not used for clustering
         % archetype .type files are in period xxx
       have_ctl = sum(strcmp(period,{"0","1","2","3","4","5","5","7","8","10","12","xxx"}));
       if have_ctl
          found = true;
          break;
       end
   end
end
