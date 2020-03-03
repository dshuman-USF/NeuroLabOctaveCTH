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
% Calculate the 3D orthgognal normalized basis for the space determined by four
% points in N space using modfied Gram-Schmidt algorithm.
% INPUTS:
%         4 points in N space
% OUTPUTS:        
%         3 orthogonal vectors that are a basis for 3-space in N space
%         status = 1 
%         OR
%         empty vectors
%         status = 0 on error, such as all points are on a line
% Ref:
% http://en.wikipedia.org/wiki/Gram%E2%80%93Schmidt_process#Numerical_stability
% also:
% http://www.math.uconn.edu/~troby/Math2210S14/LT/sec6_4.pdf

function [e1 e2 e3 status] = basis3d(A,B,C,D)
   e1 = [];
   e2 = [];
   e3 = [];
   status = 1;

   CB = B - C;
   CA = A - C;
   CD = D - C;

    # are pts collinear
   lhs = norm(CB + CA);
   rhs = norm(CB) + norm(CA);
   if (abs(rhs - lhs) < eps)
      printf("ERROR: points A B collinear\n");
      status = 0;
   endif

   lhs = norm(CB + CD);
   rhs = norm(CB) + norm(CD);
   if (abs(rhs - lhs) < eps)
      printf("ERROR: points B D collinear\n");
      status = 0;
   endif

   lhs = norm(CA + CD);
   rhs = norm(CA) + norm(CD);
   if (abs(rhs - lhs) < eps)
      printf("ERROR: points A C collinear\n");
      status = 0;
   endif

  # not collinear, are pts coplanar?
  cp = [CA;CB;CD];
  if rank(cp) <= 2
    disp("ERROR:  Pts are coplanar");
    status = 0;
  endif

   if status == 0
      disp("No point in continuing");
      return;
   endif

    # 3D basis determined by 4 points (3 vectors)
    # Gram-Schimdt
   u1 = CB;
   u2 = CA - ((dot(CA,u1)/dot(u1,u1)) * u1);
   u3 = CD - ((dot(CD,u1)/dot(u1,u1)) * u1) - ((dot(CD,u2)/dot(u2,u2)) * u2);
   e1 = u1/(norm(u1));
   e2 = u2/(norm(u2));
   e3 = u3/(norm(u3));

   #if these zero (or close), they are orthogonal
   if (abs(dot(e1, e2)) > 1.0e-13)
      ui_msg("ERROR WARNVectors e1 e2 not orthogonal.")
      status = 0;
   endif
   if (abs(dot(e1, e3)) > 1.0e-13)
      ui_msg("ERROR WARNVectors e1 e3 not orthogonal.")
      status = 0;
   endif
   if (abs(dot(e2, e3)) > 1.0e-13)
      ui_msg("ERROR WARNVectors e2 e3 not orthogonal.")
      status = 0;
   endif
   status = 1;
endfunction
