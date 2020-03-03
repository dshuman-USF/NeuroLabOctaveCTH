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

