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
% Function to calculate and display a goodness-of-clustering for the
% archetype clustering algorithm.
% For each archetype A:
%    calculate distance to all of A's members
%    for each other archetype Bn
%       calculate the distance from A to Bn members 
%       figure out some number of distance bins
%       plot each of these as a kind of histogram, like so:
%
%    *     *                                          *
%    *  *  *                                       *  *
%    *  *  *                                    *  *  *
%    *  *  * *  *  *                 * *        *  *  *
%    __________________________________________________________
%    A  A members distance from A    Bn members    |distance from A                  
%                                            note Bn may be closer than
%                                            some of its members
%

%function compare_types(CthVars,clust_list,arch_nums,namesnof,names,
%   a_centers,dend,colors,maxdist,have_swall,swall_nums=[],swall_centers=[])
function compare_types(CthVars,clust_list,namesnof,names,dend,colors,maxdist,arch)
   arch_ranges = archnums();
   num_clusts = length(clust_list);
   std_list=[];
   swall1_list=[];
   lareflex_list=[];

   if arch.std.have 
      std_list=clust_list(find(clust_list >= arch_ranges.std(1) & clust_list < arch_ranges.swallow(1)));
   end
   if arch.swall1.have 
      swall1_list=clust_list(find(clust_list >= arch_ranges.swallow(1) & clust_list < arch_ranges.lareflex(1)));
   end
   if arch.laref.have
      lareflex_list=clust_list(find(clust_list >= arch_ranges.lareflex(1)));
   end

   subs = (num_clusts*(num_clusts-1))/2;
   subs = subs/3;
   [sub_r,sub_c] = subplotdim(subs);
   use_fig2 = false;
   use_fig3 = false;
   tot_wins = 1;

   win = plot_wins(1,1);
   win = win(1);   % screen 1
   shrink = 80;
   fig1=figure('position', [win.xorg+2*win.left_w win.yorg+shrink-2*win.top_h win.width-shrink win.height-shrink],'visible',false);
   set(fig1,'numbertitle','off');
   hold on;

   next_bar = 1;
   tot_bars = 1;
   x_bins = linspace(0,maxdist,20);

   for a_clust = 1:num_clusts - 1
        % distance matrix of all pts in a_clust
      a_in_type = find(dend(:,2) == clust_list(a_clust))';
      a_names = dend(a_in_type,1);
      a_arch_num = clust_list(a_clust);
      switch a_arch_num
         case std_list(find(a_arch_num==std_list))
            a_type = arch.std.centers(find(a_arch_num==arch.std.nums),:);
         case swall1_list(find(a_arch_num==swall1_list))
            a_type = arch.swall1.centers(find(a_arch_num==arch.swall1.nums),:);
         case lareflex_list(find(a_arch_num==lareflex_list))
            a_type = arch.laref.centers(find(a_arch_num==arch.laref.nums),:);
         otherwise
            continue;
      end
      a_pts = a_type;
      for pt = a_names'
         a_pts=[a_pts;CthVars.(namesnof{pt}).NSpaceCoords];
      end
      dist_matrix_a = squareform(loc_pdist(a_pts,'euclidean'),'tomatrix'); 
       % create dist matrices for distances to pts in all the other clusters
      for b_clust = a_clust+1:num_clusts   % 100 101 200 303  600 602  1000 1002a
            % compare std with std, swall with swall, etc
         b_arch_num = clust_list(b_clust);
         if find(a_arch_num==std_list) && isempty(find(b_arch_num==std_list))
            break;
         elseif find(a_arch_num==swall1_list) && isempty(find(b_arch_num==swall1_list))
            break;
         elseif find(a_arch_num==lareflex_list) && isempty(find(b_arch_num==lareflex_list))
            break;
         end
         b_in_type = find(dend(:,2) == clust_list(b_clust))';
         b_names = dend(b_in_type,1);
         b_pts = a_type;
         for pt = b_names'
            b_pts=[b_pts;CthVars.(namesnof{pt}).NSpaceCoords];
         end
         dist_matrix_b = squareform(loc_pdist(b_pts,'euclidean'),'tomatrix'); 
         switch b_arch_num
            case std_list(find(b_arch_num==std_list))
               b_type = arch.std.centers(find(b_arch_num==arch.std.nums),:);
            case swall1_list(find(b_arch_num==swall1_list))
               b_type = arch.swall1.centers(find(b_arch_num==arch.swall1.nums),:);
            case lareflex_list(find(b_arch_num==lareflex_list))
               b_type = arch.laref.centers(find(b_arch_num==arch.laref.nums),:);
            otherwise
               continue;
         end

         arch_dist = distancePoints(a_type, b_type);
         dist_matrix_b(1,1)= arch_dist;

         hsub = v38_subplot(sub_r,sub_c,next_bar,"align");
         hold on;
         % we need to make a matrix with the 3 columns with same # of rows
         % use 0 for placeholder values
         dm_a_rows=rows(dist_matrix_a);
         dm_b_rows=rows(dist_matrix_b);

         diffs1 = [dist_matrix_a(:,1);dist_matrix_b(:,1)];
         diffs2 = [diffs1 diffs1 diffs1];

         diffs2(dm_a_rows+1:end,1)=0;  % just a vals in col 1, zero out b vals
         diffs2(1,2)=arch_dist;        % arch a to arch b distance in col 2
         diffs2(2:end,2)=0;
         diffs2(1:dm_a_rows+1,3)=0;    % b values in col 3
         nn = hist(diffs2,x_bins);
         nn(1)=1;
         nn(1,2:3)=0;
         nn(:,3)=-nn(:,3);
         h=bar(x_bins,nn,1.4,'histc');
         cth_color = shift(colors,-a_clust+1)(1,:);
         set(h(1),'facecolor',cth_color);
         cth_color = shift(colors,-b_clust+1)(1,:);
         set(h(2),'facecolor',cth_color);
         set(h(3),'facecolor',cth_color);
         ax=axis;
         set(gca,'fontsize',8,'xticklabelmode','manual','xtick',[0,ax(2)],'xticklabel',           {'0',num2str(ax(2))});
         y_range=abs(max(max(nn)));
         ylim([-y_range,y_range]);
         msg = sprintf('Type # %d  Type # %d',clust_list(a_clust),clust_list(b_clust));
         title(msg);

         next_bar = next_bar + 1; 
         tot_bars = tot_bars + 1; 
         if ~use_fig2 && tot_bars >  sub_r * sub_c
            fig2=figure('position', [win.xorg+win.left_w win.yorg+shrink-win.top_h win.width-shrink win.height-shrink],'visible',false);
            set(fig2,'numbertitle','off');
            hold on;
            use_fig2 = true;
            next_bar = 1;
            tot_wins = tot_wins+1;
         elseif ~use_fig3 && tot_bars > 2 * sub_r * sub_c
            fig3=figure('position', [win.xorg win.yorg+shrink win.width-shrink win.height-shrink],'visible',false);
            set(fig3,'numbertitle','off');
            hold on;
            use_fig3 = true;
            next_bar = 1;
            tot_wins = tot_wins+1;
         end
      end
   end

   info = {'The left-most bar is the first', 'CTH Archetype. The bars in the', 'same color above', 'the line are CTHs','in the first cluster.', '', 'The bar of a different', 'color above the line', 'is the second CTH archetype.', 'The bars below the', 'line are CTHs in', 'the second cluster.'};

   if use_fig3
      set(fig3,'name',sprintf('Archetype to Archetype Distance Comparisons  Window 3 of %d',tot_wins));
      set(fig3,'visible',true);
      drawnow();
      annotation(fig3,'textbox',[.001 .7 .1 .1],'string',info ,'fitboxtotext','on','edgecolor','w','fontsize',12);
   end
   if use_fig2
      set(fig2,'name',sprintf('Archetype to Archetype Distance Comparisons  Window 2 of %d',tot_wins));
      set(fig2,'visible',true);
      drawnow();
      annotation(fig2,'textbox',[.001 .7 .1 .1],'string',info ,'fitboxtotext','on','edgecolor','w','fontsize',12);
   end
   set(fig1,'name',sprintf('Archetype to Archetype Distance Comparisons  Window 1 of %d',tot_wins));
   set(fig1,'visible',true);
   drawnow();
   annotation(fig1,'textbox',[.001 .7 .1 .1],'string',info ,'fitboxtotext','on','edgecolor','w','fontsize',12);
end


