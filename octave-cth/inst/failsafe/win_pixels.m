% This gets info about the monitors and windows that the desktop manager draws on them.
% This only needs to be called once during cthgui startup.
% In theory, the user could change the display resolution. 
% This breaks, too bad.
% 
% RETURNS: twomons:  info about physical characteristics of monitors
%           twomons(1) is (probably) the left monitor
%           twomons(2) is (probably) the right monitor
%          winpixes: info about components of gui windows in pixels.
%
% It took a while to figure out how to get info to size the windows.
% In X, the origin is in the upper left corner of the screen.
% Octave figures use the origin as the lower left corner of the drawable area
% and the set the origin at the lower left corner of the window.
% So if you say create a figure window at [100 100 200 300] 
% it will be in the lower left area of the screen. 
% Here are the pieces of a figure window:
%    --------------------------------------- 
%    |     window manager decorations      | <- window manager frame
%    | ----------------------------------- |
%    | |        figure menu bar          | |
%    | |---------------------------------| |
%    | |                                 | |
%    | |                                 | |
%    | |                                 | |
%    | |                                 | |
%    | |        drawable area            | |
%    | |                                 | |
%    | |                                 | |
%    | |                                 | |
%    | |                                 | |
%    | ||- this is the origin the octave | |
%    | |V  figure function uses.         | |
%    | |---------------------------------| |
%    | |       figure optional toolbar   | |
%    | ----------------------------------- |
%    --------------------------------------- 
% We need to know frame h and w, plus menu bar and optional toolbar (the QT
% graphics_toolkit puts everything at the top).
% We also need to know about the screen, there may be toolbars at the top
% or bottom. So, the usable area is likely to be less than the screen's resolution.
% It is remarkably difficult to get all this info, and the window manager is
% free to modify your request, so if you ask for a 200 x 300 window, sometimes you
% get one that is 204 x 298.  Go figure. Heh.
% This still has problems with the monitors are run at a different resolution
% under xfce4. This wm does not position the windows even close to where they are
% supposed to be in the y axis on the lower-res monitor. Don't know why.

function [twomons, winpixes] = win_pixels()

   % Draw a window, then query the X11 machinery to figure out the real width
   % of a window in pixels. This gives us the # of pixels that the border and
   % other decorations take up.
   dummy_w = 200;
   dummy_h = 300;
   winpixes=struct;
   twomons=struct;
   [res vals] = system("cth_screeninfo");  % external cpp program we provide
   if (res != 0)  % sometimes takes 2 tries, don't know why
      [res vals] = system("cth_screeninfo");
   end

   if (res == 0)  % success
      mon=strsplit(vals,'\n');
      mon(end)="";  % always a blank line at end
      totmons=length(mon);
      allmons=struct;
      for nummons=1:totmons
         currmon=mon{nummons};
              % find, e.g.,  1920x1080+3840+0+1920+1080
         coords = strsplit(currmon,{"x","+"," "});
         allmons(nummons).usable_x = str2num(coords{1}); % usable x
         allmons(nummons).usable_y = str2num(coords{2}); % usable y
         allmons(nummons).xorg = str2num(coords{3});   % xorg 
         allmons(nummons).yorg = str2num(coords{4});   % yorg
         allmons(nummons).x_res = str2num(coords{5});    % x res
         allmons(nummons).y_res = str2num(coords{6});    % y res
      end
      if totmons == 1
         twomons(1,:)=allmons;
         twomons(2,:)=allmons;
      elseif totmons == 2
         twomons=allmons;
      else  % if more than 2, find largest two
         [c r] = max([allmons.x_res] .* [allmons.y_res]);   % max pixels
         twomons(1) = allmons(r);
         allmons(r)=[];
         [c r] = max([allmons.x_res] .* [allmons.y_res]);
         twomons(2) = allmons(r);
      end
   else  % do the best we can
      scrinfo = get(0,'screensize');
      x0 = scrinfo(1);
      y0 = scrinfo(2);
      w0 = scrinfo(3)/2;
      h0 = scrinfo(4);
      twomons=struct('xorg',x0,'yorg',y0,'usable_x',w0,'usable_y',h0,'x_res',w0,'y_res',h0,'left_w',10,'top_h',30);
      twomons(2)=twomons(1);
      ui_msg("ERROR WARNThe screen_info program failed.  The plots are probably going to be badly positionted.");
   end
   [val order] = sort([twomons.xorg]);
   twomons=twomons(order);

    % Got monitor info, now get window info
    % this tries to figure out the border areas of the window by drawing one
    % and getting info about it.

   fignum=getpid();
   fig = figure(fignum,'position',[300,400,dummy_w,dummy_h]);
   axis();
   drawnow();
   refresh(fig);
   ok1 = 1;

   cmd = cstrcat("xprop -name ", "\"Figure ",num2str(fig),"\"", " _NET_FRAME_EXTENTS");
   for wait=1:5
      try
         [ok1 frame]=system(cmd);  % sometimes takes a short time for window to display
         if isempty(strfind(frame,'not found'))   % wait a bit, but not forever
            break;
         else
            ui_msg("Retrying getting window stats");
            pause(1);
         end
      catch
         pause(1);
      end_try_catch
   end
   framesize=strsplit(frame,{' ',','});  % outer frame the win mgr draws
   winpixes.frame_leftw = str2num(framesize{3}); % left witdh
   frame_rightw = str2num(framesize{4});
   winpixes.frame_toph =str2num(framesize{5});  % top height
   winpixes.frame_bottomh =str2num(framesize{6});

    % info about what is inside the frame with menu bar
   cmd = cstrcat("xwininfo -name ","\"Figure ",num2str(fig),"\""," | grep -e Width -e Height");
   [ok2 size] = system(cmd);
   winsize = strsplit(size,' ');
   set(fig,'menubar','none');
   refresh(fig);
   for wait = 1:5
      [ok3 size_nomenu] = system(cmd);   % without menu bar
      winsize_nomenu = strsplit(size_nomenu,' ');
      if strcmp(winsize_nomenu{5},winsize{5}) == 0
         break;
      end
   end
   if ((ok1 == 0) && (ok2 == 0) && ok3 == 0)
      win_x_size = str2num(winsize{3});  % size of window inside frame
      win_y_size = str2num(winsize{5});
      real_x_w = win_x_size - dummy_w; % generally 0
      real_y_h = win_y_size - dummy_h; % size of menubar and toolbar
      winsize_nomenu = strsplit(size_nomenu,' ');
      win_y_size_nomenu = str2num(winsize_nomenu{5});
      winpixes.menu_h = win_y_size - win_y_size_nomenu;
      winpixes.toolbar_h = real_y_h - winpixes.menu_h;
      winpixes.xframe = real_x_w + winpixes.frame_leftw + frame_rightw;
      winpixes.yframe = real_y_h + winpixes.frame_toph + winpixes.frame_bottomh;
   else
      winpixes.xframe = 12;  % best guess, sometimes works
      winpixes.yframe = 98;
   end
   close(fig);
end

