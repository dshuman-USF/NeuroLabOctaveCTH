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


