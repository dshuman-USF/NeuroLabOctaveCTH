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
% Calcuate cophenetic correlation coefficient
% INPUTS:
%          Z is output of linkage function
%          Y is output of pdist function
% OUTPUTS:
%          c cophenetic correlation coefficient
%          d cophenetic distances in the same format as Y
% Formula from: 
%
%     http://www.scielo.br/pdf/pab/v48n6/03.pdf, page 592
% 
%
%          sum(i=1 to n-1) sum (j>i to n) (Y(ij)-my) * (Z(ij)-mz)
%    c =   _______________________________________________________
%
%       sqrt(sum(i-1 to n-1) sum (j>i to n) (Y(ij)-my)^2 *
%                  sum(i-1 to n-1) sum (j>i to n) (Z(ij)-mz)^2)
%
%   where:
%          Y(i,j) is euclidean distance between i and j from Y
%
%          Z(i,j) distance is the height of the node at which i and j
%                 are joined 
%   
%           2 
%    my = ______  * sum(i=1 to n-1) sum(j>i to n) Y(ij)
%         n(n-1)
%
%           2 
%    mz = ______  * sum(i=1 to n-1) sum(j>i to n) Z(ij)
%         n(n-1)
%
%  This isn't in the source forge pacakge, so I wrote it.  --Dale

function [c d] = loc_cophenet(Z,Y)
   if (nargin > 1)  % it could be a lot of extra work to make
      maked=1;     % this, so don't make it unless requested
   else
      maked=0;
   end
   topsum = 0;
   sumsqry = 0;
   sumsqrz = 0;
   zmean=0;
   ymean=0;
   imax=rows(Z);
   jmax=rows(Z)+1;
   leaf=rows(Z)+1;

   ydis=squareform(Y);                   % rearrange for easier indexing
   if maked == 1
      [cr cc] = size(ydis);
      d=zeros(cr,cc);
   end

   for i_idx=1:imax
      for j_idx = i_idx+1:jmax
         a=leafinclus(Z,i_idx);          % all clusters these leaves are in
         b=leafinclus(Z,j_idx);
         sharedclus=min(intersect(a,b)); % closest cluster where they join
         dist=Z(sharedclus-leaf,3);      % distance where leaves i_idx and j_idx join
         zdist=dist;
         ydist=ydis(i_idx,j_idx);        % euclidean dist
         topsum = topsum + zdist*ydist;
         zmean = zmean+zdist;            % accumlate dists so we can subtract 
         ymean = ymean+ydist;            % means later 
         sumsqry = sumsqry + (ydist*ydist);
         sumsqrz = sumsqrz + (zdist*zdist);
         if maked == 1
            d(j_idx,i_idx) = zdist;
            d(i_idx,j_idx) = zdist;
         end
      end
   end
   meandiv = 2/(jmax*(jmax-1));        % factor from equations
   top = topsum-zmean*ymean*meandiv;   % subtract the means
   ysqr = sumsqry-ymean*ymean*meandiv;
   zsqr = sumsqrz-zmean*zmean*meandiv;
   c=top/sqrt(ysqr*zsqr);
   if maked == 1
      d=squareform(d);
   end
endfunction
