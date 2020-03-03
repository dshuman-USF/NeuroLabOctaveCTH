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
% prompt for a number and wait until you get one.
% use default value on just ENTER

function num = getnum(prompt,default)
done = 0;
while done == 0
   if nargin == 2
      def = default;
   else
      def = [];
   end
   tmp=input(prompt,'s');
   if length(tmp) != 0
       num = str2num(tmp);
       if ~isempty(num)
          done = 1;
       else
          disp("Not a number, try again");
       end
   elseif ~isempty(def)
       num= def;
       done = 1;
   else
       disp("No value entered, try again");
   endif
endwhile
endfunction
