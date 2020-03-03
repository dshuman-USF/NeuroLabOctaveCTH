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

