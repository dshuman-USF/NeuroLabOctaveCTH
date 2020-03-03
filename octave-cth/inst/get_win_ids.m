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

