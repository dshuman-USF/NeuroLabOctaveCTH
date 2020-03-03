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
%  Create a figure and display spline curves fitted to cths.
%  These are generated by an R program (cth_para.R at this time)
%  INPUTS:
%          cnum      - chart title text
%          dnum      - optional derivative title text
%          names     - variable names 
%          curve     - array of structs holding curves, ordered same as name
%          colors    - bar color 
%          x,y,w,h   - dimensions of window
%          bgnd      - background color of histograms
%          scale     - 1 for manual scale, 2 for autoscale
%          do_derive - Calculate derivatvies for curves and show in derivative window
%          The last three elements of each curve are not points to plot,
%          they are:
%          p value
%          dispersion value
%          number of knots the spline fitter used
%  OUTPUT: 
%         fig - handle to figure 
function [fig_c,fig_d] = showcurves(cnum,dnum,names,curve,colors,x,y,w,h,xd,yd,wd,hd,bgnd,scale,do_derive)
   global HIDETHRESH;
   yax = 0;
   subs_c=[];
   subs_d=[];
   ptinfo={};
   min_y = 0;
   max_y = 0;
   pval = 0.0;
   dispersion = 0.0;
   knts = 0;

   [~,cols] = size(names);
   [r,c] = subplotdim(cols);
   fig_c = figure('position',[x,y,w,h],'visible','off');
   hold on
   set(fig_c,'numbertitle','off');
   set(fig_c,'name',cnum);
   if do_derive
      fig_d = figure('position',[xd,yd,wd,hd],'visible','off');
      hold on
      set(fig_d,'numbertitle','off');
      set(fig_d,'name',dnum);
   else
      fig_d=[];
   end
   for pt=1:cols
      eb = [curve(pt).curve];
      bins=columns(eb);
      pval = eb(bins-2);
      dispersion = eb(bins-1);
      knts = eb(bins);
      bins = bins - 3;
      xvals=linspace(1,bins,bins);
      figure(fig_c,'visible','off');
      s_tmp = v38_subplot(r,c,pt,"align");
      subs_c=[subs_c s_tmp];
      hold on
      eb1=eb(1:bins);
      if do_derive
         deriv=diff(eb1);   # derivative
         dx_vals=(1:length(deriv));
      end
      plot(xvals,eb1,'linewidth',2','color',colors);
      if r < HIDETHRESH    # leave off x tick labels if too many rows
         set(gca,'fontsize',8,'xticklabelmode','manual','xtick',[1,bins/2,bins],'xticklabel','');

      else
         set(gca,'xtick',[]);
      end
      set(s_tmp,'yticklabel','')
      set(s_tmp,'ytick',[])
      set(gca,'ticklength',[0.05 .001])
      axis([0 bins+1]);
      box off;
      ptinfo(pt) = getseq(names{pt});  % save for maybe later

      if do_derive
         figure(fig_d,'visible','off');
         s_tmp = v38_subplot(r,c,pt,"align");
         hold on
         subs_d=[subs_d s_tmp];
         [ymin,ymax] = opt_derive(deriv);
         if ~isnan(ymin) 
            ylim([ymin ymax],'manual');
         end
         h_dx = plot(deriv);
         set(h_dx,'color',colors,'linewidth',2);

         if r < HIDETHRESH    # leave off x tick labels if too many rows
            set(gca,'fontsize',8,'xticklabelmode','manual','xtick',[1,bins/2,bins],'xticklabel','');

         else
            set(gca,'xtick',[]);
         end
         set(gca,'yticklabel','')
         set(gca,'ytick',[])
         set(gca,'yticklabel','')
         set(gca,'ytick',[])
         set(gca,'ticklength',[0.05 .001])
         axis([0 bins+1]);
         box off;
      end
   end

   if scale == 1
      for pt=1:cols              % min and max
         ax=axis(subs_c(pt));
         if min_y > ax(3)
            min_y = ax(3);
         end
         if max_y < ax(4)
            max_y = ax(4);
         end
      end
   else
      for pt=1:cols              % y range is 0 to a bit less than max to make
         v38_subplot(subs_c(pt));  % room for text
         ax=axis();
         axis(ax);
      end
   end

   for pt=1:cols               % info at top of plot
      figure(fig_c,'visible','off');
      v38_subplot(subs_c(pt));
      ax=axis();
      if scale == 1
         ax(3) = min_y;
         ax(4) = max_y;
      end
      axis(ax);
      text(0,ax(4),ptinfo(pt),'fontsize',8,'verticalalignment','bottom');
      if do_derive
         figure(fig_d,'visible','off');
         v38_subplot(subs_d(pt));
         ax=axis();
         if scale == 1
            ax(3) = min_y;
            ax(4) = max_y;
         end
         axis(ax);
         text(0,ax(4),ptinfo(pt),'fontsize',8,'verticalalignment','bottom');
      end
   end
   figure(fig_c,'visible','on');
   if do_derive
      figure(fig_d,'visible','on');
   end
endfunction
