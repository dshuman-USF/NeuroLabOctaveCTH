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
%test some dendogram stuff

function td

x =[ 0.219741   0.309004   0.212650;
   0.865915   0.404592   0.853777;
   0.348305   0.927682   0.502994;
   0.851035   0.991142   0.244072;
   0.407197   0.887130   0.521756;
   0.444846   0.178294   0.754042;
   0.785879   0.971413   0.842209;
   0.709454   0.733612   0.578886;
   0.659556   0.014179   0.375149;
   0.198904   0.628248   0.789184;
];

d = pdist(x);
tree=linkage(d,'complete');
figure
[a,b]=dendogram(tree);

[m n] = size(tree);
inorder=getleaves(tree,m);

end



