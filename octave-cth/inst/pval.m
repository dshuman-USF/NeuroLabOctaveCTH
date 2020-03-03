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
% Cacluate Pearson's chi-squared for some cth elements
%
% INPUTS:  obsv  - set of observations
%          exptd - expected value
%          df    - degrees of freedom
% OUTPUTS: p - probability it is a random distribution
%
% ref: http://en.wikipedia.org/wiki/Pearson's_chi-squared_test 

function [p] = pval(obsv,exptd,df)
  X2 = sum(((obsv-exptd).^2) / exptd);
  p = 1-(chi2cdf(X2,df));
end
