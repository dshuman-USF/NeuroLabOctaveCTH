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
% utility function to start and keep track of tile locations for displaying 
% plot windows on monitor 1 on the primary desktop.

function [x y w h] = tilemon1d1(init=0,col=0,row=0)
   persistent inited = 0;
   persistent mon1;
   if init ~= 0
      inited = 0;
   end
   if inited == 0
      inited = 1;
      tmp = plot_wins(col,row);
      mon1 = tmp(1);
      x = mon1.curr_xorg;
      y = mon1.curr_yorg;
   else
      x = mon1.curr_xorg + mon1.x_step;
      y = mon1.curr_yorg;
      if x >= mon1.x_wrap
         x = mon1.xorg;
         y = mon1.curr_yorg - mon1.y_step;
         if y <= mon1.y_wrap
            y = mon1.yorg;
         end
      end
   end
   mon1.curr_xorg = x;
   mon1.curr_yorg = y;
   w = mon1.width;
   h = mon1.height;
endfunction
