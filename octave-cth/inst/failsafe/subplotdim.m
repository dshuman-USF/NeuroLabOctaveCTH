% Calculate the best fit for subplots given the number of subplots we are going
% to have to display.  This assumes it needs to leave room for a blank subplot
% and then the mean subplot.  Even for subplots that do not have these, we
% assume they do so sibling plots correspond to each other.

function [r,c] = subplotdim(subs)
   totsubs = subs + 2;     % space + mean subplot
   c = ceil(sqrt(totsubs));
   r = ceil((totsubs)/c);
end

