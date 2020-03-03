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
% Use e1 e2 e3 basis vectors and project pt(s) into the space they determine
% ref: http://math.stackexchange.com/questions/185546/how-to-project-a-n-dimensional-point-onto-a-2-d-subspace
% 

function projpt = project3(e1,e2,e3,pts)
   r=rows(pts);
   projpt=[];
   ve1=ones(r,1)*e1;
   ve2=ones(r,1)*e2;
   ve3=ones(r,1)*e3;
   X = dot(pts,ve1,2) ./ dot(ve1,ve1,2);
   Y = dot(pts,ve2,2) ./ dot(ve2,ve2,2);
   Z = dot(pts,ve3,2) ./ dot(ve3,ve3,2);
   projpt = [X Y Z];
endfunction

