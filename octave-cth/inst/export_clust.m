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
% Function to export cluster information so the atlas program
% and other programs, can display the clusters as points in 
% the cat 3d brain atlas.
%  INPUTS:  
%   names:  struct with point names in them
%   coords: struct with info we need to export
%   one and only one of:
%     dend:   the dendrogram indexes, which pts are in the cluster, or []
%     kidx:   kmeans cluster indexes, or []
%     fidx:   fuzzy cmeans cluster indexes, or []
%   fname:  name to save to
%   colors: current color palette
%  OUTPUTS: 0 for failure, 1 for success
%
function [val] = export_clust(CthVars,names,namesnof,flatnames,coords,dend,kidx,fidx,fname,colors,pd_algo,link_algo,archetype=0)
   val = 0;
   have_dend = ~isempty(dend);
   have_kmeans = ~isempty(kidx);
   have_fuzzy = ~isempty(fidx);
   if have_dend + have_kmeans + have_fuzzy != 1
      ui_msg("Multple or no indices in export_clust, clusters not saved");
      return;
   end
   fname = strcat(fname,".csv");
   [fdout fmsg] = fopen(fname,'wt');
   if fdout == -1
      ui_msg(fmsg);
      ui_msg("ERROR WARNFile has not been saved");
      return;
   end
     % header
   nbins = columns(CthVars.(namesnof{1}).NSpaceCoords);
   fprintf(fdout,"name,mchan,ap,rl,dp,dchan,ref,r,g,b,ap_atlas,rl_atlas,dp_atlas,expname,period,archetype");
   for (bin=1:nbins)
      fprintf(fdout,"%s",sprintf(",cth%04d",bin))
   end
   for (bin=1:nbins)
      fprintf(fdout,"%s",sprintf(",normcth%04d",bin))
   end
   fprintf(fdout,"\n");

   # the first line is not CTH-specific info, but info global to all the CTHs.
   sprdline = sprintf("GLOBALS:,%s,%s,%d\n", pd_algo,link_algo,nbins);
   fprintf(fdout,"%s", sprdline);
   flatlist=[];
   pairlist=[];
   if archetype
      unique_clus = unique(dend(:,2));
   end
   if have_dend 
      if archetype
         num_clusts=rows(unique_clus);
      else
         num_clusts=max(dend(:,2));
      end
   elseif have_kmeans
      num_clusts=max(kidx);
   else
      fidx=fidx';
      num_clusts=max(fidx);
   end

   color_idx = 0;
   for idx=1:num_clusts
      if have_dend
         if archetype
            clus_idx=unique_clus(idx);
         else
            clus_idx=idx;
         end
         n_idx=find(dend(:,2)==clus_idx);
         c_idx=dend(n_idx,1);
      elseif have_kmeans
         c_idx=find(kidx==clus_idx);
      else
         c_idx=find(fidx==clus_idx);
      end
      if isempty(n_idx)   % archetype clustering may skip idx values
         continue;        % which results in incorrect colors
      end
      color_idx = color_idx+1;

      clust_color = shift(colors,-(color_idx-1))(1,:);
      for i = c_idx'        % the dend idx is index into namesnof
         cell = namesnof{i};
         ptinfo=coords(i);
         cellparts = strsplit(cell,'_');
         pname = period2str(cellparts{end-1});
           # two classes of names, start with letter, start with num
         exp = CthVars.(namesnof{i}).RealCoords.expname;
         if strcmpi(exp,"not_available") == 1
            continue;
         end
         # a flat that actually has spikes will have a color. Flats that are blanks
         # will always be black.
         # todo:  this does not handle case where both ctl and stim are flats
         # because they are not in any cluster. Do we need to even show these?
         currseq=str2num(cellparts{end});
         sib=findsibs(currseq,CthVars,names);
         for chksib=sib
            srch_name=sprintf("_%05d$",chksib);  # use seq # at end of string
            f_idx = regexp(flatnames,srch_name);
            pos = find(~cellfun('isempty',f_idx));
            if !isempty(pos)  
               flatlist=[flatlist pos];  % index into flatnames
            end
         end
         if isdigit(exp(1))   # YYYY-MM-DD_EXP
            fparts = strsplit(exp,{'-','_'});
            expbase = sprintf("%s-%s-%s_%s",fparts{1},fparts{2},fparts{3},fparts{4});
         else   %  kxxmy, or sxxmy, maybe others. Y is the expbase
            fparts = strsplit(exp,'m');
            if length(fparts) >= 2
               expbase = sprintf("%s_%s",fparts{1},fparts{2});
            else
               expbase="NO EXP";  % must be archetype cth, no experiment for it.
            end                   % there are no coordinates, either, so bstem
         end                      % will not have anything to display
         pairlist = [pairlist;findpair(currseq,CthVars,names)];
         [dtpath dtname dtext] = fileparts(CthVars.(namesnof{i}).ExpFileName);
         if archetype
            archvalue=clus_idx;
         else
            archvalue=0;
         end
         sprdline = sprintf("%s,%s,%f,%f,%f,%s_%s,%s_%s,%f,%f,%f,%f,%f,%f,%s,%s,%d", 
                            ptinfo.name,
                            cellparts{end-3},
                            ptinfo.ap,
                            ptinfo.rl,
                            ptinfo.dp,
                            expbase,
                            ptinfo.dchan,
                            expbase,
                            ptinfo.ref,
                            clust_color(1),clust_color(2),clust_color(3),
                            ptinfo.ap_atlas, 
                            ptinfo.rl_atlas, 
                            ptinfo.dp_atlas,
                            dtname,
                            pname,
                            archvalue);
        fprintf(fdout,"%s", sprdline);
        for (bin=1:nbins)
           fprintf(fdout,",%f", CthVars.(namesnof{i}).NSpaceCoords(bin));
        end
        binmax = max(CthVars.(namesnof{i}).NSpaceCoords);
        if binmax != 0
           normbins= CthVars.(namesnof{i}).NSpaceCoords / binmax;
        else
           normbins = zeros(1,nbins);
        end
        for (bin=1:nbins)
           fprintf(fdout,",%f", normbins(bin));
        end
        fprintf(fdout,"\n");
      end
   end

     % any sibs that are flats?
   if ~isempty(flatlist)
      color_idx = color_idx + 1;
      clust_color = shift(colors,-(color_idx-1))(1,:);
      for i = flatlist
         cell = flatnames{i};
         ptinfo= CthVars.(flatnames{i}).RealCoords;
         cellparts = strsplit(cell,'_');
         pname = period2str(cellparts{end-1});
         exp = CthVars.(flatnames{i}).RealCoords.expname;
         if strcmpi(exp,"not_available") == 1
            continue;
         end
         if isdigit(exp(1))   # YYYY-MM-DD_EXP
            fparts = strsplit(exp,{'-','_'});
            expbase = sprintf("%s-%s-%s_%s",fparts{1},fparts{2},fparts{3},fparts{4});
         else  
            fparts = strsplit(exp,'m');
            expbase = sprintf("%s_%s",fparts{1},fparts{2});
         end
         [dtpath dtname dtext] = fileparts(CthVars.(flatnames{i}).ExpFileName);
         sprdline = sprintf("%s,%s,%f,%f,%f,%s_%s,%s_%s,%f,%f,%f,%f,%f,%f,%s,%s,%d", 
                            ptinfo.name,
                            cellparts{end-3},
                            ptinfo.ap,
                            ptinfo.rl,
                            ptinfo.dp,
                            expbase,
                            ptinfo.dchan,
                            expbase,
                            ptinfo.ref,
                            clust_color(1),clust_color(2),clust_color(3),
                            ptinfo.ap_atlas, 
                            ptinfo.rl_atlas, 
                            ptinfo.dp_atlas,
                            dtname,
                            pname,
                            400);
        fprintf(fdout,"%s", sprdline);
        for (bin=1:nbins)
           fprintf(fdout,",%f", CthVars.(flatnames{i}).NSpaceCoords(bin));
        end
        binmax = max(CthVars.(flatnames{i}).NSpaceCoords);
        if binmax != 0
           normbins= CthVars.(flatnames{i}).NSpaceCoords / binmax;
        else
           normbins = zeros(1,nbins);
        end
        for (bin=1:nbins)
           fprintf(fdout,",%f", normbins(bin));
        end
        fprintf(fdout,"\n");
      end
   end
   % generate CTH deltas for ctl/stim pairs
   pairlist = sort(pairlist,2);
   pairlist = unique(pairlist,"rows");
   clust_color = ones(1,3) * -1;  #no colors, brainstem will create them

   CS_DELTA = 9;   % this is CS-DELTA "cluster" in c++ code
   pname = period2str(CS_DELTA);
   for pair = 1:rows(pairlist)
      us=pairlist(pair,1);
      them=pairlist(pair,2);
      cell = names{us};
      ptinfo= CthVars.(names{us}).RealCoords;
      cellparts = strsplit(cell,'_');
        # two classes of names, start with letter, start with num
      exp = CthVars.(names{us}).RealCoords.expname;
      currseq=str2num(cellparts{end});
      if isdigit(exp(1))   # YYYY-MM-DD_EXP
         fparts = strsplit(exp,{'-','_'});
         expbase = sprintf("%s-%s-%s_%s",fparts{1},fparts{2},fparts{3},fparts{4});
      else  
         fparts = strsplit(exp,'m');
         expbase = sprintf("%s_%s",fparts{1},fparts{2});
      end
      [dtpath dtname dtext] = fileparts(CthVars.(names{us}).ExpFileName);
      sprdline = sprintf("%s,%s,%f,%f,%f,%s_%s,%s_%s,%f,%f,%f,%f,%f,%f,%s,%s,%d", 
                         ptinfo.name,
                         cellparts{end-3},
                         ptinfo.ap,
                         ptinfo.rl,
                         ptinfo.dp,
                         expbase,
                         ptinfo.dchan,
                         expbase,
                         ptinfo.ref,
                         clust_color(1),clust_color(2),clust_color(3),
                         ptinfo.ap_atlas, 
                         ptinfo.rl_atlas, 
                         ptinfo.dp_atlas,
                         dtname,
                         pname,
                         0);
     fprintf(fdout,"%s", sprdline);

     bindelta = CthVars.(names{us}).NSpaceCoords - CthVars.(names{them}).NSpaceCoords;

     for (bin=1:nbins)
        fprintf(fdout,",%f", bindelta(bin));
     end
     maxbin = max(abs(bindelta));
     if maxbin != 0
        normbins = bindelta / maxbin;
     else
        normbins = zeros(1,nbins);
     end
     for (bin=1:nbins)
        fprintf(fdout,",%f", normbins(bin));
     end
     fprintf(fdout,"\n");
   end

   fclose(fdout);
   ui_msg(sprintf("File %s saved",fname));
   val = 1;
end
