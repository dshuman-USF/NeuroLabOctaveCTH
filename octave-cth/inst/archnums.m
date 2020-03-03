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
% to avoid having lots of magic numbers for archetype cths
% in the code, this function puts all the magic in one place.
function [arch] = archnums()
   arch=struct;
   arch.std=[100,200,300];
   arch.flat=[400];
   arch.swallow=[600,700,800];
   arch.lareflex=[1000,1100,1200];
end
