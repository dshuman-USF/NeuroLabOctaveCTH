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
% calculate inconsistency coefficient of the output of 
% the linkage function.
% INPUTS: tree
%         optional depth, default is 2
% OUTPUTS:
%          I  TABLE, like so:
%          mean    stddev   # clusters in level    inconsistency coefficient
%          CLUS a cell array that lists the cluster(s) that the I table
%          used for each row, that is I(1) -> CLUS{1}
% matlab orders the table from the bottom up, so we do, too.

function [I CLUS] = loc_inconsistent(tree,depth)

if nargin < 2
   depth=2;
endif

[m n] = size(tree);
CLUS=zeros(m,m);
leaf = m+1;
I = zeros(m,4);
CLUS=cell;

for lev = 1:m

      % make list of nodes to visit below this level
   nodes=[];
   nodeidx=1;
   nodes=[lev+leaf 1];  %current level is always 1
   belownodes=[];
   belownodes=getclusts(tree,lev,2,depth);
   if ~isempty(belownodes)
      nodes=[nodes;belownodes];
   end
   CLUS{lev} = nodes(:,1)';
     % now calculate stats 
   stats=tree((nodes(:,1)-leaf),3);  % get list of distances
   I(lev,1) = mean(stats);
   I(lev,2) = std(stats);
   I(lev,3) = rows(stats);
   if I(lev,2) > 0        % leaf rows have inconsisency coeffecient of zero
      I(lev,4) = (tree(nodes(1)-leaf,3) - I(lev,1)) / I(lev,2);
   end
end


endfunction

