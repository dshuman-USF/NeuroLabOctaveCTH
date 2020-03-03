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
