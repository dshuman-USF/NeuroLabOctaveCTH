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
% save_centroids
% Function to save a set of CTHs to 
% a file that looks like the input file to cth_project.m.
% The CTHs are typically a set of dendrogram centroids, but can also be
% centroids from other types of clustering.
% These are general referred to as archetypes to avoid confusion with
% the centroid linkage algorithm.
%
% INPUTS:  
%  cth_list  a set of CTH values
%  outfname  name to save to
%  cth histogram normaliztion
%  distance algorithm
%  linkage algorithm
%  It also create a copy with a .type extension, which is intended to be used
%  for auto-classifying cths.
% This couples strongly with cth_cluster.cpp in the content of the output file

function [val] = save_archetypes(cth_list,outfname,norm,pd_algo='',link_algo='')
   val = 0;
   outfname = strcat(outfname,".type");
   fdout = fopen(outfname,'w');

   bins=columns(cth_list);
   fake_var_expname='ExpFileName';
   fake_expname='GeneratedArchetypes.edt';
   base_name='expbasename';
   fake_ticks=zeros(1,bins);
   fake_ticks(bins/2)=-1;
   fake_curve=zeros(1,bins+3);
   fake_stats=zeros(bins,2);
   name="";
   seq=1;
   if ~isempty(pd_algo) && ~isempty(link_algo)
      expinfo=sprintf('DENDROGRAM_DISTANCE_%s_LINKAGE_%s',pd_algo,link_algo); 
      expinfo=strrep(expinfo,' ','_');
   elseif !isempty(pd_algo)
      expinfo=sprintf('CLUSTERING_TYPE_%s',pd_algo); 
      expinfo=strrep(expinfo,' ','_');
   else % just don't know
      expinfo=("unknown_clustering_type");
   end

    % zero flat
   max_cth= max(max(cth_list));
   zerocth=ones(1,bins)*max_cth;
   zerostats=[zerocth;zeros(1,bins)]';

   cth_list=[cth_list;zerocth];   % other software expects Z flat to be last

   version='CTH file version 2.0';
   fprintf(fdout, "%s\n",    "% START MARK CTH_VERSION");
   fprintf(fdout, "%s\n",    "% name: CTH_VERSION");
   fprintf(fdout, "%s\n",    "% type: string");
   fprintf(fdout, "%s\n",    "% elements: 1");
   fprintf(fdout, "%s %d\n", "% length: ", length(version));
   fprintf(fdout, "%s\n",    version);
   fprintf(fdout, "%s\n",    "% END MARK\n");

   fprintf(fdout, "%s\n",    "% START MARK EXP_NAME");
   fprintf(fdout, "%s\n",    "% name: ExpName_0001");
   fprintf(fdout, "%s\n",    "% type: string");
   fprintf(fdout, "%s\n",    "% elements: 1");
   fprintf(fdout, "%s %d\n", "% length: ",length(expinfo));
   fprintf(fdout, "%s\n",    expinfo);
   fprintf(fdout, "%s\n",    "% END MARK\n");

   for cth = 1:rows(cth_list)
      curr_cth = cth_list(cth,:);
      if cth < rows(cth_list)    
         name = sprintf("A_%s_xxx_0_xxx_%05d",norm,seq);
      else
         name = sprintf("ZeroFlat_%s_xxx_%d_0_%05d",norm,ceil(max_cth),seq); 
      end
      seq = seq+1;
      fprintf(fdout, '%s %s\n',    '% START MARK', name);
      fprintf(fdout, '%s %s\n',    '% name:', name);
      fprintf(fdout, '%s\n',       '% type: scalar struct');
      fprintf(fdout, '%s\n',       '% ndims: 2');
      fprintf(fdout, '%s\n',       ' 1 1');
      fprintf(fdout, '%s\n',       '% length: 8');
      fprintf(fdout, '%s %s\n',    '% name:',fake_var_expname);
      fprintf(fdout, '%s\n',       '% type: string');
      fprintf(fdout, '%s\n',       '% elements: 1');
      fprintf(fdout, '%s %d\n',    '% length:',length(fake_expname));
      fprintf(fdout, '%s\n',       fake_expname);

      fprintf(fdout, '%s\n',       '% name: IsSparse');
      fprintf(fdout, '%s\n',       '% type: scalar');
      fprintf(fdout, '%s\n',       '0');
      fprintf(fdout, '\n');

      fprintf(fdout, '%s\n',       '% name: NSpaceCoords');
      fprintf(fdout, '%s\n',       '% type: matrix');
      fprintf(fdout, '%s\n',       '% rows: 1');
      fprintf(fdout, '%s %d\n',    '% columns:',columns(curr_cth));
      fprintf(fdout, ' %f',curr_cth);
      fprintf(fdout, '\n');

      fprintf(fdout, '%s\n',       '% name: Cthstat');
      fprintf(fdout, '%s\n',       '% type: matrix');
      fprintf(fdout, '%s %d\n',    '% rows:', rows(fake_stats));
      fprintf(fdout, '%s %d\n',    '% columns:',columns(fake_stats));
      fprintf(fdout, ' %f %f\n',   fake_stats);
      fprintf(fdout, '\n');

      fprintf(fdout, '%s\n',       '% name: RealCoords');
      fprintf(fdout, '%s\n',       '% type: scalar struct');
      fprintf(fdout, '%s\n',       '% ndims: 2');
      fprintf(fdout, '%s\n',       '% 1 1');
      fprintf(fdout, '%s\n',       '%length 12');
      fprintf(fdout, '%s\n',       '% name: expname');
      fprintf(fdout, '%s\n',       '% type: string');
      fprintf(fdout, '%s\n',       '% elements: 1');
      fprintf(fdout, '%s %d\n',    '% length:',length(expinfo));
      fprintf(fdout, '%s\n',       expinfo);
      fprintf(fdout, '%s %s\n',    '% name:',base_name);
      fprintf(fdout, '%s\n',       '% type: string');
      fprintf(fdout, '%s\n',       '% elements: 1');
      fprintf(fdout, '%s %d\n',    '% length:',length(expinfo));
      fprintf(fdout, '%s\n',       expinfo);
      fprintf(fdout, '%s\n',       '% name: name');
      fprintf(fdout, '%s\n',       '% type: string');
      fprintf(fdout, '%s\n',       '% elements: 1');
      fprintf(fdout, '%s\n',       '% length: 1');
      fprintf(fdout, '%s\n',       '0');
      fprintf(fdout, '%s\n',       '% name: mchan');
      fprintf(fdout, '%s\n',       '% type: string');
      fprintf(fdout, '%s\n',       '% elements: 1');
      fprintf(fdout, '%s\n',       '% length: 1');
      fprintf(fdout, '%s\n',       '0');
      fprintf(fdout, '%s\n',       '% name: dchan');
      fprintf(fdout, '%s\n',       '% type: string');
      fprintf(fdout, '%s\n',       '% elements: 1');
      fprintf(fdout, '%s\n',       '% length: 1');
      fprintf(fdout, '%s\n',       '0');
      fprintf(fdout, '%s\n',       '% name: ref');
      fprintf(fdout, '%s\n',       '% type: string');
      fprintf(fdout, '%s\n',       '% elements: 1');
      fprintf(fdout, '%s\n',       '% length: 1');
      fprintf(fdout, '%s\n',       '0');
      fprintf(fdout, '%s\n',       '% name: rl');
      fprintf(fdout, '%s\n',       '% type: scalar');
      fprintf(fdout, '%s\n',       '0');
      fprintf(fdout, '%s\n',       '% name: dp');
      fprintf(fdout, '%s\n',       '% type: scalar');
      fprintf(fdout, '%s\n',       '0');
      fprintf(fdout, '%s\n',       '% name: ap');
      fprintf(fdout, '%s\n',       '% type: scalar');
      fprintf(fdout, '%s\n',       '0');
      fprintf(fdout, '%s\n',       '% name: ap_atlas');
      fprintf(fdout, '%s\n',       '% type: scalar');
      fprintf(fdout, '%s\n',       '0');
      fprintf(fdout, '%s\n',       '% name: rl_atlas');
      fprintf(fdout, '%s\n',       '% type: scalar');
      fprintf(fdout, '%s\n',       '0');
      fprintf(fdout, '%s\n',       '% name: dp_atlas');
      fprintf(fdout, '%s\n',       '% type: scalar');
      fprintf(fdout, '%s\n',       '0');
      fprintf(fdout, '%s\n',       '% name: MeanSclStdErr');
      fprintf(fdout, '%s\n',       '% type: matrix');
      fprintf(fdout, '%s %d\n',    '% rows:', rows(fake_stats));
      fprintf(fdout, '%s %d\n',    '% columns:',columns(fake_stats));
      fprintf(fdout, ' %f %f\n',   fake_stats);
      fprintf(fdout, '\n');

      fprintf(fdout, '%s\n',       '% name: OneTicks');
      fprintf(fdout, '%s\n',       '% type: matrix');
      fprintf(fdout, '%s %d\n',    '% rows:', rows(fake_ticks));
      fprintf(fdout, '%s %d\n',    '% columns:',columns(fake_ticks));
      fprintf(fdout, ' %d',        fake_ticks);
      fprintf(fdout, '\n\n');

      fprintf(fdout, '%s\n',       '% name: Curve');
      fprintf(fdout, '%s\n',       '% type: matrix');
      fprintf(fdout, '%s\n',       '% rows: 1');
      fprintf(fdout, '%s %d\n',    '% columns:',columns(fake_curve));
      fprintf(fdout, ' %d',        fake_curve);
      fprintf(fdout, '\n');

      fprintf(fdout, '%s\n',    '% END MARK');
   end

   ui_msg(sprintf("File %s saved",outfname));

   fclose(fdout);
end
