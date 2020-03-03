% utility function to start and keep track of tile locations for displaying 
% plot windows on monitor 1 on the desktop to the right of the primary one.

function [x y w h] = tilemon1d2(init=0,row=0,col=0)
   persistent inited = 0;
   persistent mon1;

   if init ~= 0
      inited = 0;
   end
   if inited == 0
      inited = 1;
      tmp = plot_wins(row,col);
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


