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
# do a projection of vect onto plane subspace e1 and e2 as basis 
% Use e1 e2 basis vectors and project pt(s) into the plane they determine
% ref: http://math.stackexchange.com/questions/185546/how-to-project-a-n-dimensional-point-onto-a-2-d-subspace

function projpt = project2(e1,e2,pts)
   r=rows(pts);
   projpt=[];
   ve1=ones(r,1)*e1;
   ve2=ones(r,1)*e2;
   X = dot(pts,ve1,2) ./ dot(ve1,ve1,2);
   Y = dot(pts,ve2,2) ./ dot(ve2,ve2,2);
   projpt = [X Y];
endfunction

