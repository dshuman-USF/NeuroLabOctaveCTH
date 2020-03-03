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
