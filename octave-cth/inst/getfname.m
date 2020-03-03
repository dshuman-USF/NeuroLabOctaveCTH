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
% prompt for file name, use default on just ENTER

function name = getfname(default='');
   have_name = 0;
   while have_name == 0
      tmp = input("File to load: ","s");
      tmp = strtrim(tmp);
      if length(tmp) != 0
           name = tmp;
           have_name = 1;
      else
        disp('No file name entered, try again');
      end
   end
endfunction
