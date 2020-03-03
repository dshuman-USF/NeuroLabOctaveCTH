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
%% given a linkage output table and a distance (Y axis on plot)
%% return:
%%  1. 1xn matrix indicating which cluster the leaves belong to
%%     in leaf order 1-m
%%  2. 2xn matrix, first is leaf numbers in left-right order
%%     (like it looks in the dendrogram), second col is cluster #

function [clusters perm num]  = findcluslev(tree,lev)
   [m n] = size(tree);
   numpts = m + 1;     
   clusts=[];
   perm=[];

   inorder=getleaves(tree,m);
   seccol=zeros(numpts,1);
   perm=cat(2,inorder,seccol);
   clusts = tree(tree(:,3)>= lev,1:2);
   if isempty(clusts)
      clusts = [m+numpts];   % asking for all leaves in 1 cluster
   else
      clusts = reshape(clusts',2*size(clusts,1),[]); % interleave, l then r
      clusts =  flipud(clusts);                      % biggest first
   end

     % if the cluster a cluster owns is >= level, remove it
     % if is a leaf, leave it in the list
   for idx = 1:rows(clusts)
     if clusts(idx) > numpts && tree(clusts(idx)-numpts,3) >= lev
           clusts(idx) = 0; 
     end
   end
   clusts = clusts(clusts(:,1)~= 0,:);
   num = rows(clusts);
   clusters = zeros(numpts,1);
   for idx = 1:num
     if clusts(idx) > numpts
        leaves=getleaves(tree,clusts(idx)-numpts);
        clusters(leaves)=idx;
        a = ismember(perm(:,1),leaves);
        perm(find(a==1),2)=idx;
     else
        clusters(clusts(idx)) = idx;
        r = find(perm(:,1)==clusts(idx));
        perm(r,2)=idx;
     end
   end

endfunction

