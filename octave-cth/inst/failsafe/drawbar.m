# draw a cth bar graph in current figure
function h = drawbar(name,data,r,c,sub,bins,yax,color,autoscale=0)
   global HIDETHRESH;
   namebits=strsplit(name,'_');
   period=namebits{end-1};
   hsub = v38_subplot(r,c,sub,"align");
   hold on
   box off;
   h = bar(data,'hist','facecolor', color, 'edgecolor', color);
   ax = axis;
   if r < HIDETHRESH    # leave off x tick labels if too many rows
      set(gca,'fontsize',8,'xticklabelmode','manual','xtick',[1,bins/2,bins],'xticklabel',{'1',num2str(bins/2),num2str(bins)});
   else
      set(gca,'xtick',[]);
   end
   if strcmp(period,'xxx') != 1  # archetype CTHs and zero flat not in any period
      pernum = str2num(period);
        # ctl cths have white background, control have a gray bg.
      if (pernum == 2 || pernum == 4 || pernum == 6 || pernum == 8 || pernum == 11 
          || pernum == 13)
         set(hsub,'color',[.8, .8, .8]);
      end
   end
   ptinfo = getseq(name);
   ax = axis;
   if autoscale == 0
      ax(4) = yax;
   end
   axis([0 bins+0.5 0 ax(4)]);
   if r < HIDETHRESH
      set(gca,'ytick',[0,ax(4)]);
   else
      set(gca,'ytick',[0,ax(4)],'fontsize',6);
   end
   text(0,ax(4),ptinfo,'fontsize',10,'verticalalignment','bottom');
endfunction

