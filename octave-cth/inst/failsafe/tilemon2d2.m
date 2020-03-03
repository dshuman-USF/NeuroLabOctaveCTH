% utility function to start and keep track of tile locations for displaying 
% plot windows on monitor 2 on the desktop to the right of the primary one.

function [x y w h] = tilemon2d2(init=0,col=0,row=0)
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
