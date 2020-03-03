% Produce a list of what ctl/stim pairs changed clusters
% This only works for dendrogram and archetype clustering

function [pairlist] =ctlstim_clust(CthVars,names,namesnof,flatnames,dend,pd_algo,link_algo,colors,dist,zname,infname,outfname,archetype=0)
   pairlist=[];
   ctl_test = strsplit(names{1},'_');
   ui_msg("Saving Control/Stim CTHs that changed clusters. This may take a while. . .");
   ui_msg("Finding pairs. . .");

   unique_clus = unique(dend(:,2));
   num_clusts=rows(unique_clus);

   for idx=1:num_clusts
      if archetype
         clus_idx=unique_clus(idx);
      else
         clus_idx=idx;
      end
      n_idx=find(dend(:,2)==clus_idx);
      if isempty(n_idx)   % archetype clustering may skip idx values, skip it
         continue;
      end
      c_idx=dend(n_idx,1);

      for i = c_idx'        % the idx is index into namesnof
         our_dend = i;
         sib_dend = 0;
         cell = namesnof{i};
         cellparts = strsplit(cell,'_');
           # two classes of names, start with letter, start with num
         exp = CthVars.(namesnof{i}).RealCoords.expname;
         if strcmpi(exp,"not_available") == 1
            continue;
         end

         currseq=str2num(cellparts{end});
         sib=findsibs(currseq,CthVars,names); % should be one
         if ~isempty(sib)
            srch_name=sprintf("_%05d$",currseq);     # use seq # at end of string
            all_idx = regexp(names,srch_name);  % index into complete name list
            our_allpos = find(~cellfun('isempty',all_idx));
            srch_name=sprintf("_%05d$",sib);  # use seq # at end of string
            all_idx = regexp(names,srch_name);  % index into complete name list
            sib_allpos = find(~cellfun('isempty',all_idx));
            s_idx = regexp(flatnames,srch_name);  % this a flat?
            pos = find(~cellfun('isempty',s_idx));
            if !isempty(pos)  
               sib_clus = 400;  % "archetype" for flats
               sib_dend = 0;
            else
               s_idx = regexp(namesnof,srch_name);
               all_idx = regexp(namesnof,srch_name);
               pos = find(~cellfun('isempty',s_idx));
               if ~isempty(pos)
                  sib_clus = dend(find(dend(:,1)==pos),2);
                  sib_dend = pos;
               end
            end
         else
            ui_msg("Unexpected failure to find sibling");
            sib_clus = 0;
            continue;
         end
         pairlist_cth =findpair(currseq,CthVars,names); % list of idxes into names
         if ~isempty(pairlist)
            if isempty(find(pairlist(:,1) == pairlist_cth)) 
               add_new = true;  % not in list
            else
               add_new = false; % one of pair already in list
            end
         else
            add_new = true;   % first time
         end
         if add_new
            if pairlist_cth(1) < pairlist_cth(2)   % order ctl - stim
               pairlist = [pairlist; pairlist_cth(1) our_allpos our_dend clus_idx pairlist_cth(2) sib_allpos sib_dend sib_clus];
            elseif pairlist_cth(1) > pairlist_cth(2)
               pairlist = [pairlist; pairlist_cth(2) sib_allpos sib_dend sib_clus pairlist_cth(1) our_allpos our_dend clus_idx];
            end
         end
      end
   end
     % make list of cths that changed clusters
   pairlist_diff = pairlist((pairlist(:,4)!=pairlist(:,8)),:);
   ui_msg(sprintf("Found %d CTHs that changed cluster",rows(pairlist_diff)));

     % Part two: create .cth file
   fdin = fopen(infname,'r');
   if fdin == -1
      val = -1;
      return;
   end
   outfname_cth=cstrcat(outfname,'_ctlstim','.cth');
   ui_msg(sprintf("Saving %s . . .",outfname_cth));

   lin_list = [pairlist_diff(:,1:4);pairlist_diff(:,5:8)];
   lin_list = sortrows(lin_list,2);         % sort by names
   c_idx = lin_list(:,2);

   sections={names{c_idx}};
   sections(numel(sections)+1) = zname;    % add zero flat name to list
   sections(numel(sections)+1) = 'CTH_VERSION'; % version string, couples with cth_cluster.[cpp,h]
   sections(numel(sections)+1) = 'EXP_NAME';    % experiment name
   c_idx_cth=[c_idx;rows(dist)];     % add in index for zero flat, last row/column

   if ~isempty(dist)
      meandist=dist(c_idx_cth,c_idx_cth');
   else
      meandist=[];
   end
   fdout = fopen(outfname_cth,'w');
   instart = false;
   while true
      nextline = fgets(fdin);
      if nextline == -1   % eof or error
         break;
      end
      if strfind(nextline, '% START MARK') ~= 0
         instart = true;
         in_list=strfind(nextline,sections); % in our list?  read in, write out this block
         if sum(cellfun(@length,in_list)) > 0
            inblock = true;
            fwrite(fdout,nextline);
            while inblock == true
               nextline = fgets(fdin);
               fwrite(fdout,nextline);
               if strfind(nextline,'% END MARK') ~= 0
                  inblock = false;
               end
            end
         end
      end
   end 
   fclose(fdin);
   fclose(fdout);
   save('-append',outfname_cth,'meandist');

  % Part three, save deltas
   outfname_csv=cstrcat(outfname,'_ctlstim','.csv');
   ui_msg(sprintf("Saving %s for brainstem. . .",outfname_csv));
   [fdout fmsg] = fopen(outfname_csv,'wt');
   if fdout == -1
      ui_msg(fmsg);
      ui_msg("ERROR WARNFile has not been saved");
      return;
   end
     % header
   nbins = columns(CthVars.(names{1}).NSpaceCoords);
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

     % build color table
   clus_with_flat=[unique_clus;400];
   num_clusf = rows(clus_with_flat);
   num_colors = rows(colors);
   cthcolor=struct();
   for color=1:num_clusf
      col_idx=mod(color,num_colors);
      cthcolor.(int2str(clus_with_flat(color)))=colors(col_idx,:);
   end

   % brainstem wants clusters in color order
   lin_list_csv=sortrows(lin_list,4);
   num_clusts = rows(lin_list_csv);
   for idx=lin_list_csv'
      cell = names{idx(1)};
      ptinfo= CthVars.(cell).RealCoords;
      cellparts = strsplit(cell,'_');
      pname = period2str(cellparts{end-1});
        # two classes of names, start with letter, start with num
      exp = CthVars.(cell).RealCoords.expname;
      if strcmpi(exp,"not_available") == 1
         continue;
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
      end                      % will not have anything todisplay
      [dtpath dtname dtext] = fileparts(CthVars.(cell).ExpFileName);
      archvalue=idx(4);
      clust_color = getfield(cthcolor,num2str(archvalue));
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
        fprintf(fdout,",%f", CthVars.(cell).NSpaceCoords(bin));
     end
     binmax = max(CthVars.(cell).NSpaceCoords);
     if binmax != 0
        normbins= CthVars.(cell).NSpaceCoords / binmax;
     else
        normbins = zeros(1,nbins);
     end
     for (bin=1:nbins)
        fprintf(fdout,",%f", normbins(bin));
     end
     fprintf(fdout,"\n");
   end
   % generate CTH deltas for ctl/stim pairs
   pairlist0 = sortrows(pairlist_diff,1);
   clust_color = ones(1,3) * -1;  #no colors, brainstem will create them
   CS_DELTA = 9;   % this is CS-DELTA in c++ code
   pname = period2str(CS_DELTA);
   for pair = 1:rows(pairlist0)
      us=pairlist0(pair,1);
      them=pairlist0(pair,5);
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
   val = 1;

% for devel, just print out list
  % Part four, save diffs as a csv for excel, etc.
   if ~isempty(pairlist_diff)
      outfname_csv=cstrcat(outfname,'_ctlstim_forspread','.csv');
      ui_msg(sprintf("Saving pairs to %s for spreadsheet. . .",outfname_csv));
      [fdout fmsg] = fopen(outfname_csv,'wt');
      if fdout == -1
         ui_msg(fmsg);
         ui_msg("ERROR WARNFile has not been saved");
         return;
      end
      fprintf(fdout,"CONTROL CTH,CLUSTER,STIM CTH,CLUSTER\n");
      pairlist_diff = sortrows(pairlist_diff,2);
      for pair = 1:rows(pairlist_diff)
         if pairlist_diff(pair,4) != pairlist_diff(pair,8)
            clust1=num2str(pairlist_diff(pair,4));
            clust2=num2str(pairlist_diff(pair,8));
            if pairlist_diff(pair,4) == 400
               clust1="Flat";
            end
            if pairlist_diff(pair,8) == 400
               clust2="Flat";
            end
            fprintf(fdout,"%5d,%4s,%5d,%4s\n", pairlist_diff(pair,1), clust1, pairlist_diff(pair,5), clust2);
         end
      end
      fclose(fdout);
   end
   ui_msg("Done.");
end
