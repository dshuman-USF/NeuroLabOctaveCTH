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
% Utility function to see if a CTH is a flat
% INPUTS: cth:       cth number
%         namesnof:  name list of non-flat cths
%         flatnames: name list of flat cths
%
% OUTPUTS exists:  true if there is such cth. It could be a sparse or
%                  not in the dataseta
%                  false if we can't find it
%         flat:    if exists is true, this is true if it is a flat, false otherwise. 

function [exists flat] = is_flat(cth,namesnof,flatnames)
   srch_name=sprintf("_%05d$",cth);  % use seq # at end of string
   f_idx = regexp(flatnames,srch_name);   % a flat name?
   pos = find(~cellfun('isempty',f_idx));
   if ~isempty(pos)
      exists = true;
      flat = true;
   else
      f_idx = regexp(namesnof,srch_name);   % not a flat name?
      pos = find(~cellfun('isempty',f_idx));
      if ~isempty(pos)
         exists = true;
         flat = false;
      else
         exists = false;   % does not exist.
         flat = false;
      end
   end
end
