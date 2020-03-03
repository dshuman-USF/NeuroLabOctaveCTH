% Show interesting info about some CTHs
%  INPUTS:
%          cths:      Vector of cth numbers.  These are the sequence numbers
%                     that are the last field in the cth data structure, and
%                     also the index into same.
%          CthVars:   Contents of CTH file(s), in cth number order.
%          names:     All cth var names in seq # order
%          namesnof:  The names of non-flats in seq# order
%          flatnames: Flats names in seq# order
%          dend:      Dendogram clusters info 
%          plot_fig:  Handle of the projection figure
%          proj_nof:  Array of projected points
%          colors:    Current color array
%          archetype: Flag for using archtype linkage
%          cluster_list: If archetype, used to look up offset into color table   
%  OUTPUTS: handles for figure windows this function creates;

function [info_hands] = cthinfo(cths,CthVars,names,namesnof,flatnames,dend,plot_fig,proj_nof,colors,archetype,cluster_list)
   global tot_pts
   persistent blinks=[];
   info_hands=[];

   if isempty(cths)
      return;
   end

   if cths(1) == 0  % cth 0 means remove highlights from main projection window
      blinks=blinks(ishandle(blinks));  # windows may have been close
      if (~isempty(blinks))   
         ui_msg("Removing highlights from N SPACE PROJECTION window.");
         curfig=gcf();
         figure(plot_fig);
         delete(blinks);
         figure(curfig);
         blinks=[];
      end
      return;
   end 

   if isempty(dend)
      ui_msg("Info for individual CTHs only supported for dendrogram and archetype clustering.");
      return
   end

   sub_rows = 3;
   sub_cols = 4;
   info_idx = 1;
   cth_idx = 2;
   ebar_idx = 3;
   curve_idx = 4;
   raw_idx = 7;
   derive_idx = 8; 
   proj_idx = [5 6 9 10];
   sraw_idx = 11;
   zderive_idx = 12; 

   % if a -1 in the input (was a "*" in the GUI), then we are going to look up
   % any and all control/ctl/stim CTHs for the channel number(s) in the
   % requested CTH sequence number(s) in the same experiment.
   lookup=find(cths==-1);
   if ~isempty(lookup)
      cthcpy=[];
      cths = cths(find(cths!=-1));
      cths = [cths,findsibs(cths,CthVars,names)]; 
      cths = sort(cths);
   end
   ctl_cth=[];
   stim_cth=[];
   ctl_cth_num = 0;
   stim_cth_num = 0;

   for this_one=cths
         % common to all CTHs
      srch_name=sprintf("_%05d$",this_one);  # use seq # at end of string
      f_idx = regexp(names,srch_name);
      npos = find(~cellfun('isempty',f_idx));
      if (isempty(npos))  # may be a sparse or out of range
         ui_msg(sprintf("CTH %d is a sparse CTH or is not in the file, skipping. . .",this_one));
         continue;
      else
         ui_msg(sprintf("Displaying detailed information and plots for CTH %d.",this_one));
      end
      name_str = strsplit(names{npos},"_");
      curr = CthVars.(names{npos});
      seq    = name_str{end};
      period = name_str{end-1};
      spikes = name_str{end-2};
      chan   = name_str{end-3};
      norm   = name_str{end-4};
      f_type = name_str{end-5};
      exp = curr.ExpFileName;
      knots = curr.Curve(end);
      disp = curr.Curve(end-1);
      prob = curr.Curve(end-2);
      name = names{npos};
      expbase = CthVars.(names{npos}).RealCoords.expbasename;
      data = curr.NSpaceCoords;
      bins=columns(data);
      if lookup
         curr_cth=str2double(period);
         if isnan(curr_cth)  % if cth is archetype, this happens
            ctl_cth = data;
            ctl_cth_num = this_one;
            stim_cth = [];
            stim_cth_num = [];
         elseif find (curr_cth == [0,1,3,5,7,10,12]) % use to be odd/even,swall ctl is 10
            ctl_cth = data;                       % swall stim is 11, lareflex is 13,
            ctl_cth_num = this_one;               % too late to change
         else
            stim_cth = data;
            stim_cth_num = this_one;
         end
      end

      if (strcmp(f_type,'edt'))
         ticks =   sprintf("Bins in one tick intervals of 0.1 ms");
      else
         ticks =   sprintf("Bins in one tick intervals of 0.5 ms");
      end
      s_ticks = sprintf("Scaled one tick bins with equal phase durations");

       % is this cth in a cluster or a flat?
      f_idx = regexp(flatnames,srch_name);
      pos = find(~cellfun('isempty',f_idx));

      if isempty(pos)                          # in a cluster
         in_clust = true;
      else
         in_clust = false;
      end

      if in_clust
         f_idx = regexp(namesnof,srch_name);
         pos = find(~cellfun('isempty',f_idx));  # index in cluster name list
         cth_pts=pos;
         pt_idx = find(dend(:,1)==pos);          # index in dendrogram
         clust = dend(pt_idx,2);                 # in this cluster
         pos = find(find(dend(:,2)==clust)==pt_idx);  # offset in the cluster
         cluster=num2str(clust);
         inclust = length(find(dend(:,2)==clust)); # how many in cluster
         [r,c] = subplotdim(inclust);
         if archetype
            clust_col = find(cluster_list==clust);
            plotcol = shift(colors,-clust_col+1)(1,:);
            typestr="Archetype: ";
         else
            plotcol = shift(colors,-(str2num(cluster)-1))(1,:);
            typestr="Cluster #: ";
         end
      else 
         cluster="flat plot";
         pos = find(~cellfun('isempty',f_idx));
         [r,c] = subplotdim(length(flatnames));
         plotcol = [.4 .4 .4];
         typestr=" ";
      end

      cth_row = fix((pos-1)/c+1);   % 1-based row, column location
      cth_col = mod((pos-1),c)+1;

        % now show interesting stuff
      [x y w h] = cascademon1();
      fig = figure('position',[x,y,w,h]);
      info_hands=[info_hands fig];
      set(gcf,'numbertitle','off');
      set(gcf,'name',sprintf('Detailed Information And Plots for CTH %d',this_one));

         % info
      period = period2str(period);
      sub_h = subplot(sub_rows,sub_cols,info_idx);   % just a box with text
      set(sub_h,'yticklabel','')
      set(sub_h,'ytick',[]);
      set(sub_h,'xtick',[]);
      set(sub_h,'xticklabel','');
      info = sprintf("CTH#: %s\nExperiment: %s\nExperiment File:\n%s\n%s %s   Row: %d  Col: %d\nPeriod: %s\nSpikes: %s  Chan: %s\nKnots: %d\nDispersion: %f P: %f",seq,expbase,exp,typestr,cluster,cth_row,cth_col,period,spikes,chan,knots,disp,prob);
      axis off;
      text(-0.7,1,info,'fontsize',11,'verticalalignment','top','interpreter','none');

        % CTH
      maxy = max(data);
      if maxy == 0
         maxy = 1;
      end
      cth_h=drawbar(name,data,sub_rows,sub_cols,cth_idx,bins,maxy,plotcol);
      xlabel("Bins");
      ylabel("Spikes/Second");
      drawnow;

        % errorbars
      stats=curr.Cthstat;
      subplot(sub_rows,sub_cols,ebar_idx);
      e_tmp = errorbar(stats(:,1),stats(:,2));
      set(e_tmp,'color',plotcol);
      axis([0 bins+0.5]);
      set(gca,'fontsize',8,'xticklabelmode','manual','xtick',[1,bins/2,bins],'xticklabel',{'1',num2str(bins/2),num2str(bins)});
      title("Scaled Standard Error");
      xlabel('Bins');
      ylabel('Mean Rate');
      box off;
      drawnow;

         % curve
      curve=curr.Curve;
      curve=curve(1:(end-3));
      subplot(sub_rows,sub_cols,curve_idx);
      plot(curve,'color',plotcol,'linewidth',2);
      set(gca,'yticklabel','')
      set(gca,'ytick',[]);
      set(gca,'xtick',[]);
      set(gca,'xticklabel','');
      title("Circular B Spline Curve");
      box off;
      
        % raw data
      one_t = curr.OneTicks;
      phase = find(one_t == -1);
      one_t(phase) = -0.5;
      subplot(sub_rows,sub_cols,raw_idx);
      box on;
      hold on;
        % If we plot 30,000 vertical lines, the plotting machinery
        % creates 30,000 child objects, which takes forever.
        % What we do here is do a single plot of x = [1 1 1 2 2 2 ...]
        % and y =[ 0 y0 0   0 y1 0 . . .]
        % That is, we draw a vertical line from x axis up to y, then back down
        % to x axis then move right to next x, and do it again.  The first way
        % takes 45 seconds to draw the lines.  The second way happens too fast to
        % notice because there is only one child object.
      one_t_c = columns(one_t);
      xvals = repmat(1:one_t_c,3,1);
      xvals = xvals(:);
      yvals = repmat(one_t,3,1);
      yvals = yvals(:);
      ymask = repmat([0 1 0],1,one_t_c);
      ymask = ymask(:);
      yvals = yvals .* ymask;
      plot(xvals,yvals,'color',plotcol);
      set(gca,'fontsize',8,'xticklabelmode','manual','xtick',[1,phase,length(one_t)],'xticklabel',{'1',num2str(phase),num2str(length(one_t))});
      box('off')
      title(sprintf('%s %s %s','Raw data   ',spikes,' spikes'));
      ax=axis;
      line([phase,phase],[0,ax(3)*0.5],'color','black')
      text(phase,ax(3)*0.5,'Phase boundary','horizontalalignment','center','verticalalignment','top');
      xlabel(ticks);
      ylabel('Spikes per bin');

         % derivative
      deriv=diff(curve);
      subplot(sub_rows,sub_cols,derive_idx);
      plot(deriv,'color',plotcol,'linewidth',2);
      set(gca,'yticklabel','')
      set(gca,'ytick',[]);
      set(gca,'xtick',[]);
      set(gca,'xticklabel','');
      title("Derivative of Curve");
      box off;

        % scaled raw data
        % which phase is bigger, i or e? (usually e)
        % scale x axis to squish larger phase
        % if swallow or lareflex, will be the same
      if (phase-1)*2 == length(one_t)  % same size
         xpts=[1:phase,phase+1:length(one_t)];
      elseif length(one_t) - phase >= phase % e is bigger, squish it
         xpts = [1:phase, linspace(phase+1,phase*2,length(one_t)-phase)]; 
      else
         newphase=length(one_t)-phase;
         xpts = [linspace(1,newphase,phase), (newphase+1):(newphase*2)];
         phase=newphase;
      end
      subplot(sub_rows,sub_cols,sraw_idx);
      hold on;
      xvals = repmat(xpts,3,1);  % already have yvals, xvals different for this
      xvals = xvals(:);
      plot(xvals,yvals,'color',plotcol);
      set(gca,'fontsize',8,'xticklabelmode','manual','xtick',[1,phase,xpts(end)],'xticklabel',{'1',num2str(phase),num2str(xpts(end))});
      box('off')
      title('Scaled to equal I and E bins');
      line([phase,phase],[0,ax(3)*0.5],'color','black')
      text(phase,ax(3)*0.5,'Phase boundary','horizontalalignment','center','verticalalignment','top');
      xlabel(s_ticks);
      ylabel('Spikes per bin');

         % zoomed derivative
      [ymin,ymax]=opt_derive(deriv);
      subplot(sub_rows,sub_cols,zderive_idx);
      hold on;
      if !isnan(ymin)
         ylim([ymin ymax],'manual');
      end
      plot(deriv,'color',plotcol,'linewidth',2);
      set(gca,'yticklabel','')
      set(gca,'ytick',[]);
      set(gca,'xtick',[]);
      set(gca,'xticklabel','');
      title("Zoomed Derivative of Curve");
      box off;
      drawnow;

      if in_clust
         pt0 = proj_nof(cth_pts,:);
           % mark in main plot
         curfig=gcf();
         figure(plot_fig);
         blinks = [blinks blink(pt0,0)];
         figure(curfig);
            % dup the plot fig, shrink all markers except this point
         newobjs=[];
         sub_h = subplot(sub_rows,sub_cols,proj_idx,'visible','off');
         hold on;
         box on;
         txt_h = text(.2,.5,'WORKING','fontsize',12);
         drawnow;
         plot_ax = get(plot_fig,'CurrentAxes');
         curr_gca = gca();
         plot_lim=axis(plot_ax);
         axis(curr_gca,plot_lim,'manual');
         axch=allchild(plot_ax);              % copy
         axch = axch(!ismember(axch,blinks)); % don't copy already marked pts
         for hnd = 1:length(axch)
            newobjs = [newobjs;copyobj(axch(hnd),curr_gca)];
         end
         set(fig,'CurrentAxes',sub_h);        % adjust sizes
         tags = get(newobjs,'tag');
         tagpts = newobjs(strcmp(tags,'points'));
         tagline = newobjs(strcmp(tags,'line'));
         tagcent = newobjs(strcmp(tags,'center'));
         set(tagpts,'markersize',2.5);
         set(tagline,'linewidth',1);
         set(tagcent,'linewidth',1);
         set(tagcent,'markersize',14);
         blinks=[blinks blink(pt0,0)];
         if (columns(pt0) == 3)
            drawPoint3d(pt0,'marker','o','markersize',6,'markeredgecolor',plotcol,'markerfacecolor',plotcol);
         else
            drawPoint(pt0,'marker','o','markersize',6,'markeredgecolor',plotcol,'markerfacecolor',plotcol);
         end
         delete(txt_h);
         axis(curr_gca,'auto');
         set(sub_h,'visible','on');
         drawnow;
      else
         subplot(sub_rows,sub_cols,proj_idx,'visible','off');
         text(-.1, .5,'THIS IS A FLAT CTH, NOT IN THE PROJECTION PLOT','fontsize',12);
      end

      if lookup && ~isempty(ctl_cth) && ~isempty(stim_cth)
         [x y w h] = cascademon1();
         fig = figure('position',[x,y,w,h]);
         info_hands=[info_hands fig];
         set(gcf,'numbertitle','off');
         set(gcf,'name',sprintf('Control Stim Delta Plots for CTH %d and CTH %d',ctl_cth_num,stim_cth_num));
         subplot(3,1,1:2);
         h1 = bar(ctl_cth,1,'linewidth',1.5,'facecolor',[1 1 1],'edgecolor',[0 0 0]);
         hold on
         box off;
         set(gca,'xticklabelmode','manual','xtick',[1,bins/2,bins],'xticklabel',{'1',num2str(bins/2),num2str(bins)});
         h2=bar(stim_cth,.3,'facecolor','r', 'edgecolor','r');
         ax1 = axis();
         axis([0 bins+0.5 ax1(3) ax1(4)]);
         [a b c d]=legend([h1 h2],"Control","Stim",'location','northwest');
         subplot(3,1,3);
         h3 = bar(stim_cth-ctl_cth);
         hold on;
         box off;
         set(gca,'xticklabelmode','manual','xtick',[1,bins/2,bins],'xticklabel',{'1',num2str(bins/2),num2str(bins)});
         ax2 = axis();
         axis([0 bins+0.5 ax2(3) ax2(4)]);
         text(1,ax2(4)+12,"DELTA = STIM CTH - CONTROL CTH");
         ctl_cth=[];
         stim_cth=[];
      end
   end
endfunction
