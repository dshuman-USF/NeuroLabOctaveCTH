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
% given a linkage output table and index to
% start at, return all children leaves on and below
% the index.
% e.g. for a table with 10 rows, set index = 10
% to return all leaves.
% This is the non-recursive version.  Was having stack overflow problems with
% some trees using recursive one.  It is commented out below.

function [leaves] = getleaves(tree,level)
   leaves=[];
   stack=[];
   numpts = rows(tree)+1;
   current=level+numpts;   % root
   stack(1)=current;
  
   while ~isempty(stack) || current > 0
      if current > numpts
         current = tree(current-numpts,2); % left
         if current > numpts       % not a leaf
            stack=[current;stack]; % push
         end
      else
         leaves=[leaves;current];
         if isempty(stack)  % last right node done, stack is empty, done
            current = 0;
         else
            current = stack(1);   % pop
            stack(1)=[];
            current = tree(current-numpts,1); % right
            if current > numpts
               stack=[current;stack];  % push
            end
         end
      end
   end
end

%{
% this is the recursive version, was overflowing stack
% on some trees
function [leaves] = getleaves(tree,idx)
   max_recursion_depth(64000,'local');

   leaf=[];
   leaves=[];
   numpts = rows(tree)+1;

   left = tree(idx,2);
   right = tree(idx,1);

       % work down left side
   if left <= numpts    %leaf
      leaves=[leaves;left];
   else
      [leaf] = getleaves(tree,left-numpts);
      leaves = [leaves;leaf];
   end

   % work down right side
   if right <= numpts
      leaves=[leaves;right];
   else
      [leaf] = getleaves(tree,right-numpts);
      leaves = [leaves;leaf];
   end
endfunction

%}
