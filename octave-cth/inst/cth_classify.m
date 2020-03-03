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
% cth_classify
% Given a set of cth cluster templates and an unknown cth, find the nearest and
% second nearest clusters and optionally display some results.
% INPUTS: clus_centers - matrix of the archetypes N-dimensional coordinates
%         CthVars      - Struct with tons of info about all CTHs
%         clus_centers - 
%         dend         - The main dendrogram (not used for archetype clustering)
%         names        - All non-sparse CTH names
%         namesnof     - All non-flat names
%         flatnames    - All flat names
%         cths         - list of 1 or more CTHs numbers to classify
%         pd_algo      - name of distance metric algorithm
%         pdistalgo    - list of all distance metric algorithm names
%         link_algop   - linkage algorithm to use to create dendrograms
%         colors       - color values for clusters
%         showfig      - if true (the default), create a figure with info
%                        otherwise just return results.
% OUTPUTS: classify  - matrix where each row is:
%                      cthnum | archetype the CTH is nearest to | next nearest archetype
%          figs      - handles to any figure windows we create

function [classify figs] = cth_classify(clus_centers,cths,CthVars,dend,names,namesnof,flatnames,pd_algo,pdistalgo,link_algo,colors,arch_names,arch_nums,used_arch_names, showfig=true)
   classify=[];
   figs=[];
   if isempty(cths)
      return;
   end
%   if rows(clus_centers) < 2
%      ui_msg('There must be at least two clusters to perform CTH classification');
%      return;
%   end
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

   arch_link = strcmp(link_algo,'archetype');
   if arch_link
      type_word = 'Archetype';
   else
      type_word = 'Centroid';
   end
   info6='';
   if strcmp(pd_algo,pdistalgo{1}) == 1 % centroid/archetypes have no custom distance matrix
      info6=sprintf('Note: The %s distance metric is\nnot available for %ss\nSwitching to euclidean distance.',pdistalgo{1},type_word);
      real_pd_algo='euclidean';
      ui_msg(info6);
   else
      real_pd_algo=pd_algo;
   end

   for cthnum=cths
      srch_name=sprintf('_%05d$',cthnum);  # use seq # at end of string
      f_idx = regexp(names,srch_name);
      npos = find(~cellfun('isempty',f_idx));
      if (isempty(npos))  # may be a sparse or out of range or not in file
         continue;
      end

      info0='';
      info1='';
      info2='';
      info3='';
      info4='';
      info5='';
   
      cth = CthVars.(names{npos}).NSpaceCoords;
      bins=length(cth);
      num_clusts = rows(clus_centers);
      last_row=num_clusts+1;
      cth_set = [clus_centers;cth];
      dist_matrix_all = pdist(cth_set,real_pd_algo);
      dm=squareform(dist_matrix_all);
      cthdist=dm(last_row,:);
      cthdist(last_row)=Inf;
      first_near=find(cthdist==min(cthdist));
      first_dist=cthdist(first_near);
      cthdist(first_near)=Inf;
      second_near=find(cthdist==min(cthdist));
      second_dist=cthdist(second_near);
      classify =[classify;[cthnum first_near second_near]];
      if ~showfig
         continue;
      end

      [x y w h] = cascademon1();
      fig = figure('position',[x,y,w,h]);
      figs = [figs fig];
      hold on
      set(gcf,'numbertitle','off');
      info_h=subplot(2,3,1);
      box off;
      set(info_h,'yticklabel','')
      set(info_h,'ytick',[]);
      set(info_h,'xtick',[]);
      set(info_h,'xticklabel','');
      axis(gca,'off');
      grey = [.4 .4 .4];

      f_idx = regexp(flatnames,srch_name); % is this cth in a cluster or a flat?
      npos = find(~cellfun('isempty',f_idx));
      if isempty(npos)                          # in a cluster
         in_clust = true;
      else
         in_clust = false;
         clus_str=' is a Flat ';
      end

      if ~arch_link
         info0 = sprintf('\nUsing %s distance algorithm\nand %s linkage algorithm\nfor CTH # %d\n',real_pd_algo,link_algo,cthnum);
           % show dendrogram of the archetypes
         set(gcf,'name',sprintf('Clustering Using %ss + CTH %d',type_word,cthnum));

          % Show cluster centroids
         subplot(2,3,2);
         box off;
         title(sprintf("%ss Dendrogram",type_word),'fontsize',11);
         dist_matrix_cent = pdist(clus_centers,real_pd_algo);
         tree_cent = loc_linkage(dist_matrix_cent,link_algo);
         adjust=min(tree_cent(:,3)); % 'compress' Y coordinates
         if adjust < 1.0
            adjust = 1.0 + (sign(adjust)*adjust);
            logtree_cent=[tree_cent(:,1),tree_cent(:,2),log(tree_cent(:,3)+adjust)]; 
         else
           logtree_cent=[tree_cent(:,1),tree_cent(:,2),log(tree_cent(:,3))];
         end
         [pd1, td1, permd1, lhd1] = loc_dendrogram(logtree_cent);
         [cent_clus1 cent_dend1] = findclus(tree_cent,num_clusts);

         for setcol = 1:rows(cent_dend1)
            cent_col_idx=cent_dend1(find(cent_dend1(:,1)==setcol),2);
            cent_color= shift(colors,-cent_col_idx+1)(1,:);
            set(lhd1(cent_col_idx),'color',cent_color,'linewidth',4);
         end

          % now do centers + unknown cth
         f_idx = regexp(flatnames,srch_name); % is this cth in a cluster or a flat?
         npos = find(~cellfun('isempty',f_idx));
         if in_clust
            f_idx = regexp(namesnof,srch_name);
            npos = find(~cellfun('isempty',f_idx));  # index in cluster name list
            cth_pts = npos;
            pt_idx = find(dend(:,1)==npos);          # index in dendrogram
            cth_clust = dend(pt_idx,2);              # in this cluster
            cth_color = shift(colors,-cth_clust+1)(1,:);
            clus_str = sprintf(' is in %s Dendrogram\nCluster: %d ',type_word,cth_clust);
         else
            cth_color = shift(colors,-num_clusts)(1,:);
         end
         first_color = shift(colors,-first_near+1)(1,:);
         second_color = shift(colors,-second_near+1)(1,:);

         subplot(2,3,3);
         box off;
         tree_all = loc_linkage(dist_matrix_all,link_algo);
         adjust=min(tree_all(:,3));
         if adjust < 1.0
            adjust = 1.0 + (sign(adjust)*adjust);
         else
            adjust = 0.0;
         end
         logtree_all=[tree_all(:,1),tree_all(:,2),log(tree_all(:,3)+adjust)];

         [pd2, td2, permd2, lhd2] = loc_dendrogram(logtree_all);
         [cent_clus2 cent_dend2] = findclus(tree_all,num_clusts);
         info1 = sprintf('\nNearest cluster: %d,\n%s distance: %.3f\n',first_near,real_pd_algo,log(first_dist'+adjust));
         info2 = sprintf('\nSecond nearest cluster: %d\n%s distance: %.3f\n',second_near,real_pd_algo,log(second_dist'+adjust));

         cth_clust=last_row;
         inclust=find(cent_clus2==cth_clust);
         if length(inclust > 1)   % in existing cluster?
            memberof=cth_clust;
         end
         title(sprintf("%ss + CTH %d Dendrogram\n%d is the leaf of the CTH being categorized",type_word,cthnum,cth_clust),'fontsize',11);

         if cth_clust != last_row  % displaced an existing cluster
            info3 = sprintf("CTH %d is now cluster %d",cthnum,cth_clust);
         end
         for setcol = 1:rows(cent_dend2)
            cent_col_idx=cent_dend2(find(cent_dend2(:,2)==setcol),1);
            if length(cent_col_idx) > 1
               if max(cent_col_idx) == cth_clust
                  info4=sprintf("CTH %d is in cluster %d",cth_clust,min(cent_col_idx));
               else
                  info4 = sprintf("\n%ss clusters %d and %d were merged",type_word,sort(cent_col_idx));
               end 
            end
            c_col_idx=min(cent_col_idx);
            for merged=cent_col_idx'
               cent_color= shift(colors,-c_col_idx+1)(1,:);
               if merged == last_row && length(cent_col_idx)==1 % new cluster
                  set(lhd2(merged),'color','black','linewidth',4);
                  info5 = sprintf('\nCTH # %d creates a new cluster',cthnum);
               else
                  set(lhd2(merged),'color',cent_color,'linewidth',4);
               end
            end
         end
         set(lhd2(cth_clust),'linewidth',6,'linestyle','--');
      else

         % For CTHs in a cluster, use appropriate colors, otherwise, they are
         % flats, use a grey color.
         first_color_idx = find(strcmp(arch_names{first_near},used_arch_names) == 1);
         if (isempty(first_color_idx))
            first_color = grey;
         else
            first_color = shift(colors,-first_color_idx+1)(1,:);
         end
         cth_color = first_color;
         a_name = strsplit(arch_names{second_near},'_');
         second_color_idx = find(strcmp(arch_names{second_near},used_arch_names) == 1);
         if isempty(second_color_idx)
            second_color = grey;
         else
            second_color = shift(colors,-second_color_idx+1)(1,:);
         end

         set(gcf,'name',sprintf('Clustering Using %ss + CTH %d',type_word,cthnum));
         info0 = sprintf('\nUsing %s distance algorithm\nand %s linkage algorithm\nfor CTH # %d\n',real_pd_algo,link_algo,cthnum);
         info1 = sprintf('\nNearest %s: %d,\n%s distance: %.3f\n',type_word,arch_nums(first_near),real_pd_algo,first_dist');
         info2 = sprintf('\nSecond Nearest %s: %d\n%s distance: %.3f\n',type_word,arch_nums(second_near),real_pd_algo,second_dist');
         if in_clust
            clus_str = sprintf(' is in %s\nCluster: %d ',type_word,arch_nums(first_near));
            cth_color = first_color;
         else
            clus_str = sprintf(' is a Flat, not in any cluster');
            cth_color = grey;
         end
      end

      subplot(2,3,4);
      bar(cth,'hist','facecolor', cth_color, 'edgecolor', cth_color);
      set(gca,'fontsize',11,'xticklabelmode','manual','xtick',[1,bins/2,bins],'xticklabel',{'1',num2str(bins/2),num2str(bins)});
      title(sprintf('CTH %d %s',cthnum,clus_str),'fontsize',11);
      box off;

      subplot(2,3,5);
      bar(clus_centers(first_near,:),'hist','facecolor', first_color, 'edgecolor', first_color);
      set(gca,'fontsize',8,'xticklabelmode','manual','xtick',[1,bins/2,bins],'xticklabel',{'1',num2str(bins/2),num2str(bins)});
      if ~arch_link
         if in_clust
            title(sprintf('%s Cluster: %d\n',type_word,first_near),'fontsize',11);
         else
            title(sprintf('Nearest %s Cluster: %d\n',type_word,first_near),'fontsize',11);
         end
      else
         if in_clust
            title(sprintf('%s Cluster: %d\n',type_word,arch_nums(first_near)),'fontsize',11);
          title(sprintf('Nearest %s Cluster: %d\n',type_word,arch_nums(first_near)),'fontsize',11);
         end
      end
      box off;

      subplot(2,3,6);
      bar(clus_centers(second_near,:),'hist','facecolor', second_color, 'edgecolor', second_color);
      set(gca,'fontsize',8,'xticklabelmode','manual','xtick',[1,bins/2,bins],'xticklabel',{'1',num2str(bins/2),num2str(bins)});
      if ~arch_link
         title(sprintf('Second Nearest %s\nCluster: %d',type_word,second_near),'fontsize',11);
      else
         title(sprintf('Second Nearest %s\nCluster: %d',type_word,arch_nums(second_near)),'fontsize',11);
      end
      box off;

      info = sprintf('%s%s%s%s%s%s',info6,info0,info1,info2,info3,info5,info4);
      subplot(2,3,1);

      text(-0.5,1,info,'fontsize',11,'verticalalignment','top','horizontalalignment','left','interpreter','none');

%{ 
%fiddle with this later
     % get fuzzy
   try
      [fcm_cent,softp,itres]=fcm(cth_set,num_clusts,[NaN,200,NaN,0]);
      [val,f_idx]=max(softp);
   catch
   end_try_catch

   for clust = 1:num_clusts
      printf('Cluster %d has these CTH's  ',clust);
      printf(' %d ',find(f_idx==clust));
      printf('\n');
   end
   fuzzycut = 0.1;
   softp2 = softp;
   maxidx=sub2ind(size(softp),f_idx,1:columns(softp));
   softp2(maxidx) = 0;
   [val2,idx2]=max(softp2);
   softcol=0;
   cdiffs=[val-val2];
   diffsclust=[cdiffs' idx2'];   % lookup table
   vdx = find(diffsclust(:,1) < fuzzycut)';
   partcoef = partition_coeff(softp);
   partentr = partition_entropy(softp,2);
   fuzziter = length(itres);
   if ~isempty(vdx)
      msg = sprintf('\nFuzzy C-Means CTHs inside cuttoff\npartition coefficient: %f   partition entropy %f\nCTHs inside cutoff value:  %d   Iterations: %d\nCTH\t1st Membership\t2nd Membership\tDiff',partcoef,partentr,length(vdx),fuzziter);
      ui_msg(msg);
   end
%}
   end
   ui_msg("Done.");

end


