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
% utility function to figure out number of monitors
% assumes our custom cth_screeninfo program is installed,
% takes its best shot if not.
% Figures out the two largest and returns info about them.
% Returns: [xorg0 yorg0 xusable0 yusable0 xres0 yres0 optional fudge factor0
%           xorg1 yorg1 xusable1 yusable1 xres1 yres1 optional fudge factor1]
% The usable is (res - decorations), such as task bars.
function [retmonf] = num_monitors
   retmonf=zeros(2,7);
   [res vals] = system("cth_screeninfo");
   if (res != 0)  % sometimes takes 2 tries, don't know why
      [res vals] = system("cth_screeninfo");
   end
   if (res == 0)  % success
      mon=strsplit(vals,'\n');
      mon(end)="";  % always a blank line at end
      totmons=length(mon);
      retmon=zeros(totmons,7);
      for nummons=1:totmons
         currmon=mon{nummons};
              % find, e.g.,  1920x1080+3840+0+1920+1080
         coords = strsplit(currmon,{"x","+"," "}); 
         retmon(nummons,1)=str2num(coords{3});  # usable x
         retmon(nummons,2)=str2num(coords{4});  # usable y
         retmon(nummons,3)=str2num(coords{1});  # xorg
         retmon(nummons,4)=str2num(coords{2});  # yorg
         retmon(nummons,5)=str2num(coords{5});  # total x
         retmon(nummons,6)=str2num(coords{6});  # total y
            # if using fltk for plot windows , it needs a fudge factor that is equal to
            # the sizey-usabley values. Qt plots do not require this. Don't know why. 
         if strcmp(graphics_toolkit,'fltk')
            retmon(nummons,7) = retmon(nummons,6)- retmon(nummons,4);
         else
            retmon(nummons,7) = 0;
         end
      end
      if totmons == 1
         retmonf(1,:)=retmon;
         retmonf(2,:)=retmon;
      elseif totmons == 2
         retmonf=retmon;
      else  % if more than 2, find largest two (if zero, kind of silly)
         [c r] = max(retmon(:,3) .* retmon(:,4));   % max pixels
         retmonf(1,:) = retmon(r,:);
         retmon(r,:) = [];
         [c r] = max(retmon(:,3) .* retmon(:,4));
         retmonf(2,:) = retmon(r,:);
         retmonf(find(retmonf==0)) = 1;   % program expects 1 1 for origin
      end
   else  % do the best we can
      scrinfo = get(0,'screensize');
      x0 = scrinfo(1);
      y0 = scrinfo(2);
      w0 = scrinfo(3)/2;
      h0 = scrinfo(4);
      x1 = w0;
      y1 = y0;
      w1 = w0;
      h1 = h0;
      retmonf=[x0 y0 w0 h0 w0 h0 0; x1 y1 w1 h1 w1 h1 0];
   end
   retmonf=sort(retmonf);
endfunction


