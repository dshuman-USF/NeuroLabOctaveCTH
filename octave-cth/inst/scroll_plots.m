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
% Scroll the bar plot windows.
% This is really some in-line code from cth_project that both the GUI 
% and terminal UIs need.
% Passed: entirely too much stuff.
% Returns: current postion for later
% and the error bar plot windows.

function [curr_bar_pos]=scroll_plots(cmd,curr_bar_pos,scroll_step,num_to_show,tot_bars,barh,bar_ids,scrn_pos2)
   drawnow();   % force any pending window updates to occur
   if strcmp(cmd,'FORWARD')
      curr_bar_pos = curr_bar_pos + scroll_step;
      if curr_bar_pos > tot_bars
         curr_bar_pos = 1;
      end
   else
      curr_bar_pos = curr_bar_pos - scroll_step;
      if curr_bar_pos < 1
         curr_bar_pos = tot_bars - scroll_step + 1;
      end
   end
   bar_pos = curr_bar_pos;

   for replot=1:num_to_show
      if isfigure(barh(bar_pos))  # user can close window, be sensible
         figure(barh(bar_pos),'position',scrn_pos2(replot,:));
         bar_pos = bar_pos + 1;
         if bar_pos > tot_bars
            bar_pos = 1;
         end
      else
         barh(bar_pos)=[]; 
      end
   end

   bar_pos = curr_bar_pos;
   curr_ids=[];
   for showit=1:num_to_show
      curr_ids=[curr_ids bar_ids(bar_pos)];
      bar_pos = bar_pos + 1;
      if bar_pos > tot_bars
         bar_pos = 1;
      end
   end
   cmd1=sprintf("xdotool ");
   cmd2=sprintf(" windowactivate %i ", curr_ids);
   cmd3=cstrcat(cmd1,cmd2);
   system(cmd3);
   drawnow();
end