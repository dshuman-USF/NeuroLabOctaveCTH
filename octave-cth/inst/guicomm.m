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
# establish a connection with  the gui
# we become the server, the gui sends us info

function [client] = guicomm(port)
%   s = socket(AF_INET,SOCK_STREAM,0);
   s = socket(2,1,0);
   if (s < 0)
      disp("could not open socket")
      client = -1;
      return
   endif

   res = bind(s,port);
   if res < 0
      disp("failed to bind to port")
      client = -1;
      return
   endif

   res=listen(s,0);
   if (res < 0)
      disp("listen failed")
      client = -1;
      return
   endif

   [client,info] = accept(s);
   disconnect(s);  % don't need this any more, client is the connection

endfunction
