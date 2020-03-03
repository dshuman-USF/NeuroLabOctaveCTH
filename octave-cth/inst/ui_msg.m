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
% Display info.
% If using the gui, send it via the socket interface.
% If using local ui, send it to the terminal.
% Since text can be fragmented, we add a delimter to the end of the
% passed-in text.  Embedded newlines are okay, it does not have to 
% be just one line of text.  The gui program will accumulate the text
% until it sees the delimiter, then display it.

function ui_msg(msg)
global termUI;
global client;
if termUI == 0
   guimsg=strcat(msg,"__END__");   % cthgui program expects this at end of text
   send(client,guimsg);
else
   disp(msg);
   fflush(1);
endif
