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
% plot windows on monitor 2 on the primary desktop.

function [x y w h] = tilemon2d1(init=0,col=0,row=0)
   persistent inited = 0;
   persistent mon2;

   if init ~= 0
      inited = 0;
   end
   if inited == 0
      inited = 1;
      tmp = plot_wins(col,row);
      mon2 = tmp(2);
      x = mon2.curr_xorg;
      y = mon2.curr_yorg;
   else
      x = mon2.curr_xorg + mon2.x_step;
      y = mon2.curr_yorg;
      if x >= mon2.x_wrap
         x = mon2.xorg;
         y = mon2.curr_yorg - mon2.y_step;
         if y <= mon2.y_wrap
            y = mon2.yorg;
         end
      end
   end
   mon2.curr_xorg = x;
   mon2.curr_yorg = y;
   w = mon2.width;
   h = mon2.height;
endfunction
