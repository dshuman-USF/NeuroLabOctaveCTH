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
% get a random port that is probably not in use 
% (race condition is possible but very unlikely)
% return port
function [guiport] = getport
haveport = 0;
while haveport == 0
   guiport=randi([49152,65535]);
   portchk = sprintf("netstat -an | grep -q %d",guiport);
   inuse=system(portchk);
   if inuse == 1
      haveport = 1;
   endif
endwhile
