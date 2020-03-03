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
% To avoid clutter, we put the k-means stuff on the desktop to the right
% of the primary one.  Figure out which one this is. 
% If the window manager has only one desktop, these will be the same
% Desktops use zero-based numbering 0-n

function [primary,secondary]=get_dtops
   [res,primary]=system('xdotool get_desktop');
   [res,numdtop]=system('xdotool get_num_desktops');
   primary=str2num(primary);
   numdtop=str2num(numdtop);
   secondary=primary+1;
   if secondary == numdtop
      secondary = 0;
   end
end
