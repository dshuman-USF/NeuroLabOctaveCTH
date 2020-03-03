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
% Calculate the 2D orthgognal normalized basis for the plane determined by
% three points in N space using modfied Gram-Schmidt algorithm.
% INPUTS:
%         3 points in N space
% OUTPUTS:        
%         2 orthogonal vectors that are a basis for plane in N space
%         status = 1 
%         OR
%         empty vectors
%         status = 0 on error, such as all points are on a line


function [e1 e2 status] = basis2d(A,B,C)
   e1 = [];
   e2 = [];

   # to test for collinear, use triangle inequality
   # for two vects ||AB + BC|| <= ||AB|| + ||BC||
   # if ==, then on same line
   CB = B - C;
   CA = A - C;
   if (abs(norm(CB + CA) - (norm(CB) + norm(CA))) < eps)
      status = 0;
      return;
   end

   # unit vector for CB (C is origin)
   #normalized CB
   norm_CB = (CB / norm(CB));
   #CA component on CB
   ca_component = dot(norm_CB,CA);
   # vect perpendicular to CB
   perp_to_cb = CA - ca_component * norm_CB;
   # normalized of same
   normalize_perp = perp_to_cb / norm(perp_to_cb);

   e1 = normalize_perp ;
   e2 = norm_CB;

   #if this zero (or close), they are orthogonal
   if (abs(dot(e1, e2)) > 1.0e-13)
      ui_msg(sprintf("ERROR WARNVectors not orthogonal: %f\n",abs(dot(e1,e2))))
      status = 0;
      return;
   end
   status = 1;
endfunction







