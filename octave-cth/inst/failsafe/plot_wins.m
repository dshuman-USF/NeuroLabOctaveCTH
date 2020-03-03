% call this with the windows you want on a monitor and we'll tell you
% what params you need to send to figure(...) to draw them.
% INPUTS:  init: = 1 to reset and calculate everything again 
%          cols  # of windows across
%          rows  # of windows down 
% 
% RETURNS: lots of useful window metric info
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

function [win_metrics] = plot_wins(cols,rows)
   persistent twomons;
   persistent winpixes;

   mlock();  # When a caller does a clear() call, it resets our persistent
             # vars.  This keeps them initialized.
   if isempty(twomons)
      [twomons winpixes] = win_pixels();  % only once during 1st call
   end

   % to plot at position [x y w h]
   % y = yres - (yorg + top_frame + menu_h + h)
   % total win size is 
   %  tw = frame_l + frame_r + w;
   %  th = frame_t + menu_h + h + toolbar_h + frame_b;

    % remove how many pixels col/row frames need, then divide remainder by col/row. 
    % This is the w h values in the figure(...) calls, basically, 
    % how big they have to be to draw col x row windows.
   inner_x1_size = floor((twomons(1).usable_x-cols*winpixes.xframe)/cols); % mon 1
   inner_y1_size = floor((twomons(1).usable_y-rows*winpixes.yframe)/rows);
   next_x1_step = inner_x1_size + winpixes.xframe; % total size in pixels of each window
   next_y1_step = inner_y1_size + winpixes.yframe;

   inner_x2_size = floor((twomons(2).usable_x-cols*winpixes.xframe)/cols); % mon 2
   inner_y2_size = floor((twomons(2).usable_y-rows*winpixes.yframe)/rows);
   next_x2_step = inner_x2_size + winpixes.xframe;
   next_y2_step = inner_y2_size + winpixes.yframe;

   win_metrics=struct;
   win_metrics(1).xorg=twomons(1).xorg+winpixes.frame_leftw;
   win_metrics(1).yorg=twomons(1).y_res-(twomons(1).yorg + winpixes.frame_toph + inner_y1_size + winpixes.menu_h);
   win_metrics(1).curr_xorg=win_metrics(1).xorg;
   win_metrics(1).curr_yorg=win_metrics(1).yorg;
   win_metrics(1).width=inner_x1_size;
   win_metrics(1).height=inner_y1_size;
   win_metrics(1).x_step=next_x1_step;
   win_metrics(1).y_step=next_y1_step;
   win_metrics(1).x_wrap = twomons(1).xorg+(twomons(1).usable_x-1);
   win_metrics(1).y_wrap = twomons(1).y_res-(twomons(1).yorg+twomons(1).usable_y);
   win_metrics(1).left_w = winpixes.frame_leftw;
   win_metrics(1).top_h = winpixes.frame_toph;
   win_metrics(1).x_res = twomons(1).x_res;
   win_metrics(1).y_res = twomons(1).y_res;

   win_metrics(2).xorg=twomons(2).xorg+winpixes.frame_leftw;
   win_metrics(2).yorg=twomons(2).y_res-(twomons(2).yorg + winpixes.frame_toph + inner_y2_size + winpixes.menu_h);
   win_metrics(2).curr_xorg=win_metrics(2).xorg;
   win_metrics(2).curr_yorg=win_metrics(2).yorg;
   win_metrics(2).width=inner_x2_size;
   win_metrics(2).height=inner_y2_size;
   win_metrics(2).x_step=next_x2_step;
   win_metrics(2).y_step=next_y2_step;
   win_metrics(2).x_wrap = twomons(2).xorg+(twomons(2).usable_x-1);
   win_metrics(2).y_wrap = twomons(2).y_res-(twomons(2).yorg+twomons(2).usable_y);
   win_metrics(2).left_w = winpixes.frame_leftw;
   win_metrics(2).top_h = winpixes.frame_toph;
   win_metrics(2).x_res = twomons(2).x_res;
   win_metrics(2).y_res = twomons(2).y_res;
end

