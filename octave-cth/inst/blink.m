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
% Blink the passed in point(s) by drawing a white circle or
% sphere around the point(s).

function h = blink(p,num_blinks=5)
   if num_blinks == 0
      if (columns(p) == 3)
         h = drawPoint3d(p,'marker','o','markersize',12,'markerfacecolor','w');
      else
         h = drawPoint(p,'marker','o','markersize',12,'markerfacecolor','w');
      end
      return
   end

   for i =1:num_blinks
      if (columns(p) == 3)
         htmp = drawPoint3d(p,'marker','o','markersize',12,'markerfacecolor','w');
      else
         htmp = drawPoint(p,'marker','o','markersize',12,'markerfacecolor','w');
      end
      drawnow;
      pause(.5);
      if i ~= num_blinks
         delete(htmp);
         drawnow;
         pause(.3);
      else
         h = htmp;
      end
   end
endfunction
