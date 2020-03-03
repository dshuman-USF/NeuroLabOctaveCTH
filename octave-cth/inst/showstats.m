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
%  Create a figure and display mean rate and scaled std err as 
%  error bars for current cluster.
%  INPUTS:
%          cnum     - chart # 
%          names    - variable names 
%          stats    - array of structs holding stats, ordered same as name
%          colors   - bar color 
%          x,y,w,h  - dimensions of window
%          bgnd     - background color of histograms
%          erbscale - 1 for manual scale, 2 for autoscale
%  OUTPUT: 
%         fig - handle to figure 
function fig = showstats(cnum,names,stats,colors,x,y,w,h,bgnd,erbscale)
   global HIDETHRESH;
   yax = 0;
   subs=[];
   ptinfo={};
   min_y = 0;
   max_y = 0;

   [~,cols] = size(names);
   [r,c] = subplotdim(cols);
   fig = figure('position',[x,y,w,h],'visible','off');
   hold on
   set(gcf,'numbertitle','off');
   set(gcf,'name',cnum);
   eb=[stats(1).stat];
   bins=rows(eb);
   for pt=1:cols
      eb = [stats(pt).stat];
      s_tmp = v38_subplot(r,c,pt,"align");
      subs=[subs s_tmp];
      e_tmp = errorbar(eb(:,1),eb(:,2),'.');
      set(e_tmp,'color',colors);
      if r < HIDETHRESH    # leave off x tick labels if too many rows
         set(gca,'fontsize',8,'xticklabelmode','manual','xtick',[1,bins/2,bins],'xticklabel',{'1',num2str(bins/2),num2str(bins)});
      else
         set(gca,'xtick',[]);
      end
      axis([0 bins+0.5]);
      box off;
      ptinfo(pt) = getseq(names{pt});  % save for maybe later
   end

   if erbscale == 1
      for pt=1:cols              % min and max
         ax=axis(subs(pt));
         if min_y > ax(3)
            min_y = ax(3);
         end
         if max_y < ax(4)
            max_y = ax(4);
         end
      end
   end
   for pt=1:cols               % CTH seq # at top of plot
      currsub=subs(pt);
      v38_subplot(currsub);
      ax=axis();
      if erbscale == 1
         ax(3) = min_y;
         ax(4) = max_y;
      end
      axis(ax);
      set(currsub,'ytick',[ax(3) round(mean([ax(3) ax(4)])) ax(4)]);
      text(0,ax(4),ptinfo(pt));
   end
   figure(fig,'visible','on');
endfunction

