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
% Given a list of 1 or more cth sequence numbers, return any siblings.
%  INPUTS:
%          lookup:    Vector of cth sequence numbers that are the last field in
%                     the cth data structure and also the index into same.
%          CthVars:   Contents of CTH file(s), in cth seq # order.
%          names:     All cth var names in seq # order
% OUTPUT: Vector of sequence numbers of siblings found. The input seq #s are 
%         not included in the list.

function [cthlist] = findsibs(lookup,CthVars,names)
   cthlist=[];
   if isempty(lookup)
      return;
   end

   % look up any and all control/ctl/stim CTHs for the channel number(s) in the
   % requested CTH sequence number(s) in the same experiment
   for basecth=lookup
      srch_name=sprintf("_%05d$",basecth);  # use seq # at end of string
      f_idx = regexp(names,srch_name);
      npos = find(~cellfun('isempty',f_idx));
      if (isempty(npos))  # may be a sparse or out of range 
         continue;        # (note: sparses always included in ctl/stim .cth files)
      end
       % get chan # and exp name
      tmpsplt=strsplit(names{npos},'_');
      seq = str2num(tmpsplt{end});
      chan = str2double(tmpsplt{end-3});
      if chan == NaN  % archetypes don't have siblings, this field is not a number
         return;
      end
      expname=CthVars.(names{npos}).ExpFileName;
      all_inst=sprintf("_%d_(.*)_(.*)_(.*)$",chan);
      f_idx = regexp(names,all_inst);
      npos = find(~cellfun('isempty',f_idx));
      npos=npos';

      for seq=npos       %% grab sequence # at end of name
         seqname=names{seq};
         seqnum=str2num(strsplit(seqname,'_')(end){1});
         if ((seqnum!=basecth) && (strcmp(CthVars.(names{seq}).ExpFileName,expname) == 1))
            cthlist=[cthlist,seqnum];
         end
      end
   end
   if ~isempty(cthlist)
      cthlist=unique(cthlist); % may be duplicates in list for some callers
   end
endfunction
