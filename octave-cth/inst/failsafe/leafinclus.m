% return all the clusters a leaf is in
%

function ownedby = leafinclus(z,leaf)

   ownedby=[];
   [m n] = size(z);
   numleaves = m + 1;
   topclus = numleaves + m;  % top cluster #
   
   [r c] = find(z==leaf);  % row where this leaf is
   r = r + numleaves;
   ownedby = r;
   while r < topclus
      [r c] = find(z==r);
      r = r+numleaves;
      ownedby=[ownedby r];
   end

endfunction

