% showisoscatt - show scatter plot for isomap, coloring based on
%                magnitude of the axis.  That is, map a spectrum onto the
%                points ordered from min to max.
%  INPUTS:
%          cnum:      chart # 
%          names:     variable names
%          pts:       pt coordinates, ordered same as names 
%          yvals:     Y coordinates sorted low to high
%          colors:    color table
%          x,y,w,h:   dimensions of window

function fig = showisoscatt(cnum,names,pts,yvals,colors,x,y,w,h)
   fig=figure('position',[x,y,w,h],'visible','off');
   hold on
   set(gcf,'numbertitle','off');
   set(gcf,'name',cnum);
   
   [r,~]=size(colors);  % # of colors == # intervals
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

   c_idx=1;
   for s=seg
         pt=s{1}; 
         if ~isempty(pt)
#            scatter3(pts(pt,1),pts(pt,2),pts(pt,3),4,colors(c_idx,:),'filled');
            plot3(pts(pt,1),pts(pt,2),pts(pt,3),'o','markersize',4,'markerfacecolor',colors(c_idx,:),'markeredgecolor',colors(c_idx,:));
            c_idx=c_idx+1;
         end
   end
   figure(fig,'visible','on');
   ui_msg(sprintf("Used %d colors",c_idx));
endfunction
