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
