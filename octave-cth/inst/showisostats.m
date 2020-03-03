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
% Specialized version of showstats to plot the cth stats
% in one window using multiple length rows and colors.
%  Create a figure and display mean rate and scaled std err as 
%  error bars for current cluster.
%  INPUTS:
%          cnum     - chart # 
%          names    - variable names 
%          stats    - array of structs holding stats, ordered same as name
%          yvals    - Y coordinates sorted high to low
%          colors   - bar color 
%          x,y,w,h  - dimensions of window
%          bgnd     - background color of histograms
%          erbscale - 1 for manual scale, 2 for autoscale
%  OUTPUT: 
%         fig - handle to figure 
function fig = showisostats(cnum,names,stats,yvals,colors,x,y,w,h,bgnd,erbscale)
   rowlim = 16;  % max subplots per row
   yax = 0;
   subs=[];
   ptinfo={};
   min_y = 0;
   max_y = 0;

     % figure # columns by using r segments, then divide the yvals into that 
     % many regions and determine how many pts fall into each interval
     % We cannot reasonably display 500 cths on a single row, so we will
     % still use ragged rows, but will wrap ones that are over an arbitrary but
     % small limit.

   [~,cols]=size(yvals);
   r=ceil(sqrt(cols));   % of segments/bins
   ymin=min(yvals);
   ymax=max(yvals);
   yrange=linspace(ymin,ymax,r+1); % r+1 regions is r segments/bins
   ycnt=zeros(1,r);
   for pt=1:r-1
      seg{pt}=find(yvals>=yrange(pt) & yvals < yrange(pt+1));  % pt idx
      ybins(pt)=numel(seg{pt});
   end
   pt=r;
   seg{pt}=find(yvals>=yrange(pt) & yvals <= yrange(pt+1)); % put last pt in last interval
   ybins(pt)=numel(seg{pt});

   max_c=min(max(ybins),rowlim);  % arbitrary upper limit
   nrow=0;
   for pt=ybins
      if pt <= max_c
         nrow=nrow+1;
      else
         nrow=nrow+ceil(pt/max_c);
      end
   end

   fig = figure('position',[x,y,w,h],'visible','off');
   hold on
   set(gcf,'numbertitle','off');
   set(gcf,'name',cnum);

   subidx=1;     % subplot index 
   curr_pt=1;
   currcolor=0;
   color=shift(colors,-currcolor)(1,:);
   eb=[stats(1).stat];
   bins=rows(eb);
   for interval=ybins
      for pt=1:interval
         eb = [stats(curr_pt).stat];
         s_tmp = v38_subplot(nrow,max_c,subidx,"align");
         subs=[subs s_tmp];
         e_tmp = errorbar(eb(:,1),eb(:,2),'.');
         set(e_tmp,'color',color);
         set(s_tmp,'xticklabelmode','manual');
         set(s_tmp,'xtick',[1,bins/2,bins]);
         set(s_tmp,'xticklabel',{'1',num2str(bins/2),num2str(bins)});
         axis([0 bins+0.5]);
         box off;
         ptinfo(curr_pt)=getseq(names{curr_pt});  % save for maybe later
         curr_pt=curr_pt+1;
         subidx=subidx+1;
      end
      if interval==0 || mod(interval,rowlim)~=0   % blank interval or have to pad row?
         for filler=1:rowlim-mod(interval,rowlim);
            blankbar(nrow,max_c,subidx);
            subidx=subidx+1;
         end
      end
      currcolor=currcolor+1;
      color=shift(colors,-currcolor)(1,:);
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
   for pt=1:cols               %CTH name at top of plot
      v38_subplot(subs(pt));
      ax=axis();
      if erbscale == 1
         ax(3) = min_y;
         ax(4) = max_y;
      end
      axis(ax);
      text(0,ax(4),ptinfo(pt));
   end
   figure(fig,'visible','on');
endfunction
