% given a linkage output table and # of clusters
% return:
%  1. 1xn matrix indicating which cluster the leaves belong to
%     in order 1-m
%  2. 2xn matrix, first is leaf numbers in left-right order
%     (like it looks in the dendrogram), second col is the cluster #
%  


function [clusters perm] = findclus(tree,num)
   [m n] = size(tree);
   numpts = m + 1;     
   clusts=[];
   perm=[];

   clusts = [m+numpts];   % index of last row

   while rows(clusts) < num && any(clusts > numpts)
      % find the node in current list that points to 
      % child cluster with the largest distance.
      children=[(clusts(clusts>numpts)),tree((clusts(clusts>numpts)-numpts),:)];
      [val row]=max(children(:,end));   % dist on last col
      maxnode=children(row,1);

%  more obvious, but less "octave-ish"
%      for list=1:rows(clusts)
%         node = clusts(list);
%         if node > numpts                % only clusters, not leaves
%            dist =tree(node-numpts,3);
%            if dist > maxdist
%               maxdist = dist;
%               maxnode = node;
%            end
%         end
%      end

       % found the max, replace that node with its two childern
       % and keep them in l-r order
      left= tree(maxnode-numpts,2);
      right= tree(maxnode-numpts,1);
      ins=find(clusts==maxnode);
      clusts(ins)=left;
      clusts=[clusts(1:ins);right;clusts(ins+1:end)];
   end

   % found the clusters, now get their leaves
   clusters = zeros(numpts,1);
   for idx = 1:rows(clusts)
     if clusts(idx) > numpts
        leaves=getleaves(tree,clusts(idx)-numpts);
        clusters(leaves)=idx;
        tmp=[leaves,zeros(rows(leaves),1)];
        tmp(:,2)=idx;
        perm=[perm;tmp];
     else
        clusters(clusts(idx)) = idx;
        tmp=[clusts(idx),idx];
        perm=[perm;tmp];
     end
   end

endfunction

