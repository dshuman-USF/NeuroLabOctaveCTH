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

% INPUTS:
%    linkage output table
%    index to start at
%    current depth which  starts at 1, recursion increments up to the max depth
%    then bails out
% OUTPUTS
%    example final output:
%    [ 15  2
%      14  3
%      13  3
%      12  4
%    ]

function [clusts] = getclusts(tree,idx,curr_depth,max_depth)

if idx == 0  % at bottom, done
   return;
end

   temp=[];
   clusts=[];
   numpts = rows(tree)+1;
   left = tree(idx,2);
   right = tree(idx,1);

   if left > numpts    % work down left side
      clusts =[clusts;[left curr_depth]];
      if (curr_depth < max_depth)  % time to bail?
         temp = getclusts(tree,left-numpts,curr_depth+1,max_depth);
         if ~isempty(temp)
            clusts=[clusts;temp];
         end
      end
   end

   if right > numpts % work down right side
      clusts =[clusts;[right curr_depth]];
      if (curr_depth < max_depth)
         temp = getclusts(tree,right-numpts,curr_depth+1,max_depth);
         if ~isempty(temp)
            clusts=[clusts;temp];
         end
      end
   end
   if ~isempty(clusts)   % sort in ascending levels 2, 3, 4, etc.
      [s,i] = sort(clusts(:,2));
      clusts=clusts(i,:);
   end
endfunction

