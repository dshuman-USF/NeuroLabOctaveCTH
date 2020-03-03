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
