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
% Show the selected clusters in the stereotaxic cluster plot
%
%

function show_stereo(stereoh, stereo_clusts, clusts)

   if isempty(clusts)
      return;
   end

   figure(stereoh);
   if ~isempty(find(clusts == 0))  % special case, turn all on
      set(stereo_clusts,'visible','on');
      return;
   end

   set(stereo_clusts,'visible','off');
   maxclust=numel(stereo_clusts);  % assumes clusters 1-n
   cl_len = numel(clusts);
   for cl=1:cl_len
      if clusts(cl) >= 1 && clusts(cl) <= maxclust
         set(stereo_clusts(clusts(cl)),'visible','on');
      end
   end
   drawnow;
end
