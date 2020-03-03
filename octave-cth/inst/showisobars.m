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
% Specialized version of showbars to plot
% all cths in one window using multiple length rows and colors.
%  INPUTS:
%          cnum:       chart # 
%          names:      variable names
%          pts:        pt coordinates, ordered same as names 
%          yvals:      Y coordinates sorted low to high
%          colors:     color table
%          x,y,w,h:    dimensions of window
%          bgnd:       background color of histograms
%         do_isoscale: scale all bar charts to same scale or best fit for each

function fig = showisobars(cnum,names,pts,yvals,colors,x,y,w,h,bgnd,globalmax,do_isoscale)

   rowlim = 16;  % max subplots per row
   fig=figure('position',[x,y,w,h],'visible','off');
   hold on
   set(gcf,'numbertitle','off');
   set(gcf,'name',cnum);
   
     % figure # columns by using r segments, then divide the yvals into that 
     % many regions and determine how many pts fall into each interval
     % We cannot reasonably display 500 cths on a single row, so we will
     % still use ragged rows, but will wrap ones that are over an arbitrary but
     % small limit.
   [rows,cols]=size(pts);
   r=ceil(sqrt(rows+2));   % of segments/bins
   ymin=min(yvals);
   ymax=max(yvals);
   yrange=linspace(ymin,ymax,r+1); % r+1 regions is r segments/bins
   ybins=zeros(1,r);
   for pt=1:r-1
      seg{pt}=find(yvals>=yrange(pt) & yvals < yrange(pt+1));   % pt idx
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

    % scale so plots aren't too tall nor too short,
    % based on how normalized in Y
   max_y=0;
   curr=0;
   norm_str = strsplit(names{1},"_");
   norm_type = norm_str(1,columns(norm_str)-4);
   if norm_type{1} == "m"   # means
        % exclude rows with empty bins, they scale things to be too big
      max_y = max(max(pts(find(all(pts')==1),:)));
      if isempty(max_y)  % if they all had zero bins, best we can do
         max_y = max(max(pts));
      end
   elseif norm_type{1} == "p"   # peak, use largest peak value
      max_y = max(max(pts));
   elseif norm_type{1} == "u"   # unit, already at same scale
      yax = globalmax;
   else
      max_y = globalmax;
   endif

   if norm_type{1} ~= "u"   # unit, 
      yax=ceil((max_y+.5)/10)*10; # y limit
      yax = yax + yax*0.1;   # a little headroom, but not too much
   end

   subidx=1;     % subplot index 
   curr_pt=1;
   currcolor=0;
   color=shift(colors,-currcolor)(1,:);
   for interval=ybins
      for pt=1:interval
         h = drawbar(char(names(curr_pt)),pts(curr_pt,:),nrow,max_c,subidx,cols,yax,color,do_isoscale);
         curr_pt=curr_pt+1;
         subidx=subidx+1;
         if nargin > 10
            set(gca,'color',bgnd);
         end
      end
      if interval==0 || mod(interval,max_c)~=0   % blank interval or have to pad row?
         for filler=1:max_c-mod(interval,max_c);
            blankbar(nrow,max_c,subidx);
            subidx=subidx+1;
         end
      end
      currcolor=currcolor+1;
      color=shift(colors,-currcolor)(1,:);
   end
   figure(fig,'visible','on');
endfunction
