% Use the xdotool program to get the window ids for the cth plot windows
% and the error bar plot windows.
% This assumes the win ID numericial order correspond to the order
% they were created in.   There may be cases where this isn't true.
% INPUTS:  srch_name - title text to use to find windows of interest
% OUTPUTS: win_ids   - X window ids

function [win_ids]=get_win_ids(srch_name)
   win_ids=[];
   win_ids=uint32(win_ids);
   cmd = sprintf("xdotool search --name \"%s\"",srch_name);
   [stat, wins]=system(cmd);
   w=strsplit(wins,'\n');
   w=w(1:end-1)';   % last line always blank
   numwins=rows(w);
   for plots=1:numwins
      [winid,count,errmsg] = sscanf(w{plots},"%d","C");
      win_ids=[win_ids winid];
   end
end

