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
% draw a set of invisible plot windows on monitor 2, get the real screen locations
% and sizes of the bar plot windows

function [scrn_pos]=calc_slots_m2(cols,rows)
   scrn_pos=[];
   figs=[];
   tmp = plot_wins(cols,rows);
   mon2 = tmp(2);
   x = mon2.curr_xorg;
   y = mon2.curr_yorg;
   w = mon2.width;
   h = mon2.height;
   tmpfig = figure('position',[x,y,w,h],'visible','off');
   figs=[figs tmpfig];
   realpos=get(tmpfig,'position');
   scrn_pos=[scrn_pos;realpos];
   while true 
      x = x + mon2.x_step;
      if x >= mon2.x_wrap
         x = mon2.xorg;
         y = y - mon2.y_step;
         if y <= mon2.y_wrap
            break;
         end
      end
      tmpfig = figure('position',[x,y,w,h],'visible','off');
      figs=[figs tmpfig];
      realpos=get(tmpfig,'position');
      scrn_pos=[scrn_pos;realpos];
   end
   close(figs);
endfunction
