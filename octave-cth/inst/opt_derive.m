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
%% Function to calculate y axis scaling factors to ensure 90%
%% of the points are visible.  Many of the deriviative plots
%% at little more than a flat line with a narrow spike or two.
%% This happens because close knots in the fitted curve result
%% in large delta Y values.  There are generally very few of these points.
%% This finds y min and max values that zoom in on the points that 
%% are mostly on a line at the expense of clipping the narrow spikes.
%% Returns ymin and ymax unless the derivative is all the same value,
%% in which case the caller can let autoscale draw the straight line that
%% is the derivative and scale as the plot function sees fit.

function [ymin ymax] = opt_derive(deriv)

   [n,x] = hist(deriv,50);
   incl_pts = length(deriv)*.9;  % 90% of pts
   [s_el,s_idx] = sort(n,'descend');
   idx = [];
   tot = 0;
   for subpts = 1:length(s_el)
      tot = tot + s_el(subpts);
      idx = [idx s_idx(subpts)];
      if tot >= incl_pts
         break;
      end
   end

   wid = (x(2)-x(1))/2;
   dsamp=[];
   for subpts=1:length(idx)
      dsamp = [dsamp deriv(find(deriv > x(idx(subpts))-wid & deriv < x(idx(subpts))+wid))];
   end
   if min(dsamp) < max(dsamp)   # sometime derive is all the same value
      ymin = min(dsamp);
      ymax = max(dsamp);
   else
      ymin = NaN;
      ymax = NaN;
   end
end
