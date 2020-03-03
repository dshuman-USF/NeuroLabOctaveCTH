% test poisson fitting

function poifit(pts)

   bins=size(pts)(1);
   figure
   hist(pts, bins);
   [hist_data_y, hist_data_x] = hist(pts, bins);

   n=bins;
   m=1;
   guess = [n, m];

   [f, p, kvg, iter, corp, covp, covr, stdresid, Z, r2] = leasqr(hist_data_x', hist_data_y', guess, @f_it);
   figure
   hold on
   hist(pts,bins)

   plot(hist_data_x, f, "r");

end

%function val =f_it(u, x)
%   size(u)
%   size(x)
%
%  val = u .^x * exp(-u) ./ gamma(x+1);
%end

%function [val] = f_it(x, p)
%   size(x)
%   size(p)
%  val = x .^2 + p(1) .* x +p(2);
%end


