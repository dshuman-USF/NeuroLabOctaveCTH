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
% Utility to see if the current file has lareflex CTHs in it.
% See getseq.m for an explanation of the code below.

function found = need_lareflex(CthVars)
   found = false;
   for [val,key]=CthVars
       namefields = strsplit(key,"_");
       period = namefields{end-1};
       if strcmp(period,"13")
          found = true;
          break;
       end
   end
end
