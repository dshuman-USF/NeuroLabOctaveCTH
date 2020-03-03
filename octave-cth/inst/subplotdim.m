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
% Calculate the best fit for subplots given the number of subplots we are going
% to have to display.  This assumes it needs to leave room for a blank subplot
% and then the mean subplot.  Even for subplots that do not have these, we
% assume they do so sibling plots correspond to each other.

function [r,c] = subplotdim(subs)
   totsubs = subs + 2;     % space + mean subplot
   c = ceil(sqrt(totsubs));
   r = ceil((totsubs)/c);
end

