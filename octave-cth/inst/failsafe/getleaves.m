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
