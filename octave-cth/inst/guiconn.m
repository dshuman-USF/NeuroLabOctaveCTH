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
% Try to connect to gui
% if not started with a port arg, get a random port, start the gui process
% with the port# then listen for the gui process to connect to us until it
% does

function guiconn(port)
global client;
global termUI;
   if (port == 0)    % no port arg
      port = getport();
      cmd = sprintf("cthgui -p %d",port);
      disp("Launching gui. . .");
      fflush(stdout);
      status = system(cmd,[],"async");
      disp("Launched");
   end
   disp("Waiting for gui to connect. . .");
   fflush(stdout);
   client = guicomm(port);
   if (client < 0)
      disp("Listen for gui failed, falling back to local terminal UI.")
      termUI=1;
   else
      disp("Connected. . .");
      fflush(stdout);
   end
end
