% Function to save a subset of points in the given cluster to
% a file that looks like the input file to cth_project.m.
% The goal is to select a subset, e.g., a bunch of near-flats,
% and to attempt to create clusters from just those points in a later run.
%
%  INPUTS:  
%   names  struct with point names in them, in same order as distz
%   distz  distance matrix of all non-flats plus the zero flat
%   cnum   cluster number(s) to select (could be several)
%   dend   the dendrogram indexes, which pts are in the cluster
%   infname  name to read from
%   outfname  name to save to
% This expects to find % START MARK and % END MARK markers in the
% text input file.  The START MARK line will also have other text
% that we can match (such as var name).  This copies everything 
% between the START and END mark lines, including them.

function [val] = save_clust(names,distz,cnum,zname,dend,kidx,fidx,infname,outfname)
   val = 0;
   have_dend = ~isempty(dend);
   have_kmeans = ~isempty(kidx);
   have_fuzzy = ~isempty(fidx);
   if have_dend + have_kmeans + have_fuzzy != 1
      ui_msg("Multple or no indices in save_clust, clusters not saved");
      return;
   end
   fdin = fopen(infname,'r');
   if fdin == -1
      val = -1;
      return;
   end
   outfname=cstrcat(outfname,'.cth');

   c_idx=[];
   if have_dend
      for idx=1:numel(cnum)
         c_idx=[c_idx;find(dend(:,2)==cnum(idx))];
      end
      c_idx=dend(c_idx);
   elseif have_kmeans
      for idx=1:numel(cnum)
         c_idx=[c_idx;find(kidx==cnum(idx))];
      end
   elseif have_fuzzy
      for idx=1:numel(cnum)
         c_idx=[c_idx;find(fidx==cnum(idx))];
      end
   end

   sections={names{c_idx}};
   sections(numel(sections)+1) = zname;    % add zero flat name to list
   sections(numel(sections)+1) = 'CTH_VERSION'; % version string, couples with cth_cluster.[cpp,h]
   sections(numel(sections)+1) = 'EXP_NAME';    % experiment name
   c_idx=[c_idx;rows(distz)];     % add in index for zero flat, last row/column
   c_idx=sort(c_idx);             % put into distz order
   meandist=distz(c_idx,c_idx');
   fdout = fopen(outfname,'w');
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
   save('-append',outfname,'meandist');
end
