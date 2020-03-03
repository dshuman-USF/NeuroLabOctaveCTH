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
# there is some info in the var names, parse it
# and return it  
# format for real data is:
#  F_<filename>_<m or p>_<neuron chan>_<total spikes>_<period>_<seq #>
# for archtype CTHs:
#  A_<optional name>_<m or p>_<0>_<0>_<xxx>_<seq #>
#   where m is mean, p is peak, u is unit, n is no  CTH histogram  normalization
#  neu: neuron #
#  tot: total spikes in cth
#  seq: sequence number 1-N
#  These are parsed from the end, since there is no way of knowing
#  how many "_" chars, if any, there may be in the filename. So:
#
#  {end}   == seq#
#  {end-1} == period, 'xxx' for archetypes
#  {end-2} == total spikes, 0 for archetypes
#  {end-3} == neuron channel #, xxx for zeroflat and archetypes
#  {end-4" == type of normaliztion, mean, peak, 
#
#

function pt = getseq(name)
   last = strsplit(name,"_");
   if (strcmp(last(1,columns(last)-3),"xxx"))
      pt = strcat(last(1,columns(last)), "{  }", last(1,columns(last)-2));
   else
      pt = strcat(" #",last(1,columns(last)), "{  }", last(1,columns(last)-2), " spikes");
   end
endfunction
