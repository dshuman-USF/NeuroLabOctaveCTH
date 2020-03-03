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
% Output a CSV file that contains information so that the cths can be
% compared to hand-sorted/clustered information contained in databases.
%  INPUTS:
%          CthVars:    Contents of CTH file(s), in cth number order.
%          SparseVars: The sparse CTH's that we removed from the original CthVars
%          names:      All non-sparse cth var names in seq # order
%          namesnof:   The names of non-flats in seq# order
%          flatnames:  Flats names in seq# order
%          dend:       Dendogram clusters info 

function export_db(CthVars,SparseVars,names,namesnof,flatnames,dend,fname,archetype)
   if isempty(CthVars)
      return;
   end
   if isempty(dend)
      ui_msg("ERROR WARNExporting CTHs not supported for non-dendrogram clustering.");
      return
   end
  fname = strcat(fname,".db.csv");
   [fdout fmsg] = fopen(fname,'wt');
   if fdout == -1
      ui_msg(fmsg);
      ui_msg("ERROR WARNThe DB file has not been saved");
      return;
   end
     % header
   fprintf(fdout,"expname,cthnum,chan,cluster,row,col,period\n");
   sparsenames=fieldnames(SparseVars);

   numpts = length(namesnof);
   for npos=1:numpts
      name = namesnof{npos};
      name_str = strsplit(name,"_");
      curr = CthVars.(name);
      expbase = CthVars.(name).RealCoords.expbasename;
      pt_idx = find(dend(:,1)==npos);          % index in dendrogram
      clust = dend(pt_idx,2);                 % in this cluster
      pos = find(find(dend(:,2)==clust)==pt_idx);  % offset in the cluster
      cluster=num2str(clust);
      inclust = length(find(dend(:,2)==clust)); % how many in cluster
      [r,c] = subplotdim(inclust);
      x = fix((pos-1)/c+1);   % 1-based row, column location
      y = mod((pos-1),c)+1;
      seq = str2num(name_str{end});
      chan = name_str{end-3};
      period = name_str{end-1};
      exp = curr.ExpFileName;
      fprintf(fdout,"%s,%d,%s,%s,%d,%d,%s\n",expbase,seq,chan,cluster,x,y,period);
   end

   numpts = length(flatnames);
   for npos=1:numpts
      cluster="F";   % brainstem program will look for this
      name = flatnames{npos};
      name_str = strsplit(name,"_");
      curr = CthVars.(name);
      expbase = CthVars.(name).RealCoords.expbasename;
      pos = find(~cellfun('isempty',{npos}));
      [r,c] = subplotdim(length(flatnames));
      x = fix((pos-1)/c+1);   % 1-based row, column location
      y = mod((pos-1),c)+1;
      seq = str2num(name_str{end});
      chan = name_str{end-3};
      period = name_str{end-1};
      exp = curr.ExpFileName;
      fprintf(fdout,"%s,%d,%s,%s,%d,%d,%s\n",expbase,seq,chan,cluster,x,y,period);
   end

   numpts = length(sparsenames);
   for npos=1:numpts
      cluster="S";
      name = sparsenames{npos};
      name_str = strsplit(name,"_");
      curr = SparseVars.(name);
      expbase = SparseVars.(name).RealCoords.expbasename;
      x = -1;
      y = -1;
      seq = str2num(name_str{end});
      chan = name_str{end-3};
      period = name_str{end-1};
      exp = curr.ExpFileName;
      fprintf(fdout,"%s,%d,%s,%s,%d,%d,%s\n",expbase,seq,chan,cluster,x,y,period);
   end

   fclose(fdout);
   ui_msg(sprintf("File %s saved",fname));
endfunction

