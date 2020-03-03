% The cth_project file is getting entirely too big.  The isomap calculation and 
% plotting is done here.
% Input: Entirely too many things
%         D            - distance matrix in vector form
%         names        - var names
%         pts          - coordinates in same order as names
%         stats        - array of stats for each cth, in same order as names
%         numbins      - array of stats for each cth, in same order as names
%         isoh         - holds any existing plot handles, we add to it and return it
%         x1,y1,w1,h1  - current plot slot, we may use some  
%         colors,bkgnd - current palette
%         globalmax    - max area/peak value, used for scaling
%         num_runs     - current pass
%         do_isover    - overlay graph on isomap pts
%         do_isembed   - show first 5 embedding dimensions
%         do_isocolor  - show 3D color plot using color spectrum
%         do_errb      - show error bar plots for cths
%         do_errbscale - how to scale error bar plots
%         do_isocolor  - show 3D projection color spectrum plots
%         do_isoscale  - scale all bar charts to same scale or best fit for each
%
% Output: The outputs from the isomap function (see it for what these are)
%         and the handle to the isomap figure.
%         As a side effect, if we use display slots, we leave the current slot
%         to be the last one we used.  The caller has to call the tilemon1d1
%         function to move to and get the next slot.

function [Y,R,E,C,isoh]= isoplots(D,names,pts,stats,isoh,x1,y1,w1,h1,colors,bkgnd,globalmax,num_runs,do_isoover,do_isoembed,do_errb,do_errbscale,do_isocolor,do_isoscale)
   Y=[];
   R=[];
   E=[];
   C=[];

   if min(min(D)) <= 0   % non-positive distances crash the isomap functions
      ui_msg(sprintf("ERROR WARNThe selected distance algorithm %s has negative distances.\nThis crashes the isomap functions, so isomap plots skipped for this pass.",pd_algo));
      return;
   end
   [~,numbins]=size(pts);
   if numbins < 3   % really can't do much with 2D data
      ui_msg("ERROR WARNIsomapping of 2D data not supported.");
      return;
   elseif numbins <= 20
      isodims=numbins;
      plotdims=min(5,numbins);  % 3-5
   else
      isodims=20; % large # of bins/embedding dimensions doesn't seem to  
      plotdims=5; % affect results, but take forever to calculate for large #
   end
   options.dims = 1:isodims;
   options.verbose = 0;
   options.display = 0;
   options.overlay = do_isoover;

   DD=squareform(D);
   sumR=Inf;
   lowidx=0;
   saveR=[];
   ui_msg("Calculating optimum isomap k for this data set. . .");
   figure('position',[x1,y1,w1,h1],'name',sprintf("ISOMAP BEST k for %d embedding dimensions   Run: %d",isodims,num_runs));
   set(gcf,'numbertitle','off');
   xlabel("k value");
   ylabel("variance for k");
   hold on
   hmul='';
   for n_neigh=2:isodims
      try
         [Y,R,E,C]=IsomapII(DD, 'k' ,n_neigh, options);
         saveR=[saveR ; R];
         if C == 1 && sumR > sum(R) % if outliers deleted, more than one 
            sumR = sum(R);          % connected region, reject the k
            lowidx=n_neigh;
         end
         if C > 1
            hmul=plot(n_neigh,sum(saveR(n_neigh-1,:)),'rx','linewidth',2); % multiple regions
         end
      catch
         ui_msg("ERROR WARNThere was an error calculating the isomap, operation aborted.");
         return;
      end_try_catch
   end
   ui_msg(sprintf('Optimum k is %d',lowidx));
   plot(2:isodims,sum(saveR'));
   hsing=plot(lowidx,sum(saveR(lowidx-1,:)),'o','linewidth',2);
   if isempty(hmul)
      [iso1,iso2,iso3,iso4]=legend(hsing,"optimum value","location","northwest");
   else
      [iso1,iso2,iso3,iso4]=legend([hmul hsing],"multiple regions, not used for k","optimum value","location","northwest");
   end 
   if size(iso2)(2) >= 2
      set(iso2(2),'linewidth',2);
   end
   if size(iso2)(2) >= 4
      set(iso2(4),'linewidth',2);
   end
   [x1,y1,w1,h1] = tilemon1d1();  % for next plot
   hold off 

   [Y,R,E,C]=IsomapII(DD, 'k' ,lowidx, options);
   figure('position',[x1,y1,w1,h1],'name',sprintf('ISOMAP  Run: %d',num_runs));
   set(gcf,'numbertitle','off');
   hold on
   plot(options.dims, R, 'bo');
   plot(options.dims, R, 'b-');
   ylabel('Residual variance');
   xlabel('Isomap dimensionality');
   hold off
   [x1,y1,w1,h1] = tilemon1d1();  % for next plot

    % Scatter plot of 3-D embedding
   tmph=figure('position',[x1,y1,w1,h1],'name',sprintf('ISOMAP Projection using %d neighbors  Run: %d',lowidx,num_runs));
   set(gcf,'numbertitle','off');
   isoh=[isoh tmph];
   hold on;
   isoz=Y.coords{3};
   if do_isoover && ~isempty(E)   % connect the dots
      gplot3(E(Y.index, Y.index), [isoz(1,:);isoz(2,:);isoz(3,:)]','color','k'); 
   end  
   clear DD;
   if do_isoembed || do_isocolor || do_errb
      leg=[];
      [x1,y1,w1,h1] = tilemon1d1();  % for next plot
       f1=figure('position',[x1,y1,w1,h1],'name',sprintf('Single axis values min-max,  Run: %d',num_runs));
      set(f1,'numbertitle','off');
      for p=1:plotdims
         [v1,v2]=sort(Y.coords{plotdims}(p,:));
         title=sprintf("ISOMAP Dimension %d of %dD embedding  Run: %d",p,plotdims,num_runs);
         if do_isoembed
            [x1,y1,w1,h1] = tilemon1d1();  % for next plot
            showisobars(title,{names{v2}},pts(v2,:),v1,colors,x1,y1,w1,h1,bkgnd,globalmax,do_isoscale);
         end
         if do_isocolor
            [x1,y1,w1,h1] = tilemon1d1();  % for next plot
            showisoscatt(title,{names{v2}},Y.coords{3}'(v2,:),v1,colors,x1,y1,w1,h1);
         end
         if do_errb
            [x1,y1,w1,h1] = tilemon1d1();  % for next plot
            showisostats(title,{names{v2}},stats(v2),v1,colors,x1,y1,w1,h1,bkgnd,do_errbscale);
         end

         figure(f1);
         hold on;
         htmp=plot(v1,'linewidth',2);
         set(htmp,'color',colors(p,:));
         leg=[leg htmp];
      end
      [h1,h2,h3,h4]=legend([leg],'Dim 1','Dim 2','Dim 3','Dim 4','Dim 5',"location","northwest");
      set(h2,'linewidth',2);
   end
end
