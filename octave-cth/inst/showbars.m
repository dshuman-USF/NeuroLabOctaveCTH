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
% Plot one or more cth's as subplots in a plot window
%  INPUTS:
%          cnum:      chart # 
%          names:     variable names
%          pts:       pt coordinates, ordered same as names 
%          colors:    bar color 
%          x,y,w,h:   dimensions of window
%          bgnd:      background color of histograms
%          meanbar:   optional histogram, expected to be
%                     the centroid of the set
%          autoscale: use same fixed max Y for all plots, or autoscale each

function fig = showbars(cnum,names,pts,colors,x,y,w,h,bgnd,globalmax,meanbar,autoscale,archetype,archnum)
   fig = figure('position',[x,y,w,h],'visible','off');
   hold on

   if exist('meanbar') && ~isempty(meanbar) % do we have a mean cth?
      havemean = true;
        % mean bars not included in globalmax calcs, can be greater
      mean_max=max(meanbar);
      mean_y=ceil((mean_max+.5)/10)*10;  # y limit
      mean_y = mean_y + mean_y*0.1;      # a little headroom, but not too much
   else
      havemean = false;
   end
   set(gcf,'numbertitle','off');
   set(gcf,'name',cnum);

   [rows,cols]=size(pts);
   [r,c] = subplotdim(rows);

   if rows != 0 && cols != 0    % Kmeans, fuzzy cmeans, and archetype clusters
                                % sometimes have empty clusters
       % scale so plots aren't too tall nor too short,
       % based on how normalized in Y
      yax = 0;
      max_y = 0;
      curr = 0;
      norm_str = strsplit(names{1},"_");
      norm_type = norm_str(1,columns(norm_str)-4);
      if norm_type{1} == "m"   # means
           % exclude rows with empty bins, they scale things to be too big
         max_y = max(max(pts(find(all(pts')==1),:)));
         if isempty(max_y)  % if they all had zero bins, best we can do
            max_y = max(max(pts));
         end
      elseif norm_type{1} == "p"   # peak, use largest peak value for this set
         max_y = max(max(pts));
      elseif norm_type{1} == "u"   # unit scale
         max_y = globalmax;
         yax = globalmax + 0.2;    # all already at same scale
      else
         max_y = globalmax;
      endif

      if norm_type{1} ~= 'u'
         yax=ceil((max_y+.5)/10)*10; # y limit
         yax = yax + yax*0.1;        # a little headroom, but not too much
      end
      for pt=1:rows
         figure(fig,'visible','off'); # defeat user impatiently clicking on another window
         h = drawbar(char(names(pt)),pts(pt,:),r,c,pt,cols,yax,colors,autoscale);
      endfor

      if havemean
         pt = pt + 1;
         meancolor=[.4 .4 .4];
         blankbar(r,c,pt);  % assume we have room
         pt = pt + 1;
         if archetype
            title_str = sprintf("xxx_xxx_xxx_%d_xxx_Archetype",archnum);
            h = drawbar(title_str,meanbar,r,c,pt,cols,max(yax,mean_y),meancolor,autoscale);
         else
            h = drawbar("xxx_xxx_xxx_xxx_xxx_MEAN",meanbar,r,c,pt,cols,max(yax,mean_y),meancolor,autoscale);
         end
         set(gca,'color',bgnd);
      endif
   else
      v38_subplot(2,1,1,"align");
      axis;
      axis off;
      text(.1,.5,"NOTE: No members in this cluster.\nThis can happen with K-Means,\nFuzzy C-Means or archetype clustering.", info,'fontsize',12,'verticalalignment','top','interpreter','none');
      if havemean
         meancolor=[.4 .4 .4];
         [rows,cols]=size(meanbar);
         drawbar("xxx_xxx_xxx_xxx_xxx_MEAN",meanbar,2,4,6,cols,mean_y,meancolor,autoscale);
      end
   endif
   figure(fig,'visible','on');
endfunction
