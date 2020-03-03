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
% Given a sequence number, if it is part of a ctl/stim pair, return the other 
% member of the pair if it exists.
%  INPUTS:
%          seqnum:    A cth seq num.  
%          CthVars:   Contents of CTH file(s), in cth seq # order.
%          names:     All cth var names in seq # order
% OUTPUT: [1x2] vector of the original pair and its sibling, or an empty vector

function [pairlist] = findpair(seqnum,CthVars,names)
   pairlist=[];

   % look up any and all control/ctl/stim CTHs for the channel number(s) in the
   % requested CTH sequence number(s) in the same experiment
   srch_name=sprintf("_%05d$",seqnum);  # use seq # at end of string
   f_idx = regexp(names,srch_name);
   npos = find(~cellfun('isempty',f_idx));
   if (isempty(npos))  # may be a sparse,  out of range, or no siblings 
      return;
   end
      % get chan # and exp name
   if length(npos) > 1   % something wrong, should only be one match
      ui_msg("There is an error in findpair, should only be one pair");
   end
   tmpsplt=strsplit(names{npos},'_');
   seq = str2num(tmpsplt{end});
   chan = str2double(tmpsplt{end-3});
   if isnan(chan)   % templates have channel #, hence, no pairs
      return;
   end
   period = str2num(tmpsplt{end-1});
   expname=CthVars.(names{npos}).ExpFileName;
     % find all chans in same exp
   explen=length(tmpsplt)-4;
   lookupname='';
   for rebuild=1:explen
      lookupname = strcat(lookupname,tmpsplt{rebuild});
      lookupname = strcat(lookupname,'_');
   end
   all_inst=sprintf("%s%d_(.*)_(.*)_(.*)$",lookupname,chan);
   f_idx = regexp(names,all_inst);
   npos = find(~cellfun('isempty',f_idx));
   npos=npos';
   for seq=npos       %% grab sequence # at end of name
      seqname=names{seq};
      tmpsplt=strsplit(seqname,'_');
      sibseq=str2num(tmpsplt(end){1});
      sibper=str2num(tmpsplt(end-1){1});
      if ( (strcmp(CthVars.(names{seq}).ExpFileName,expname) == 1) &&
          (period == 1 && sibper == 2)   ||   % CCO2
          (period == 2 && sibper == 1)   ||
          (period == 3 && sibper == 4)   ||   % VCO2
          (period == 4 && sibper == 3)   ||
          (period == 5 && sibper == 6)   ||   % TB_CGH 
          (period == 6 && sibper == 5)   ||
          (period == 7 && sibper == 8)   ||   % LAR_CGH 
          (period == 8 && sibper == 7)   ||
          (period == 11 && sibper == 10) ||   % SWALL1
          (period == 10 && sibper == 11) ||
          (period == 13 && sibper == 12) ||   % LAREFLEX
          (period == 12 && sibper == 13))
         pairlist=[seqnum sibseq];
         break;   % there can only be one
      end
   end
endfunction
