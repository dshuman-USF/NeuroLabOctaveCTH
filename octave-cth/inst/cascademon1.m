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
% CTH info windows. Unlike most of the other windows, these do not tile
% but cascade.

function [x y w h] = cascademon1(init=0)
   persistent inited = 0;
   persistent wininfo;
   if init ~= 0
      inited = 0;
   end
   if inited == 0
      inited = 1;
      tmp = plot_wins(2,2);  % xres/2, yres/2
      wininfo = tmp(1);
      x = wininfo.curr_xorg;
      y = wininfo.curr_yorg;
   else
      x = wininfo.curr_xorg + wininfo.left_w;
      y = wininfo.curr_yorg - wininfo.top_h;
      if x >= wininfo.x_wrap || y <= wininfo.y_wrap
         x = wininfo.xorg;
         y = wininfo.yorg;
      end
   end
   wininfo.curr_xorg = x;
   wininfo.curr_yorg = y;
   w = wininfo.width;
   h = wininfo.height;
endfunction
