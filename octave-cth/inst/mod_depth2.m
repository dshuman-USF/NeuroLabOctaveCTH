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
% function [hi_start hi_width mod_depth] = mod_depth2(cth)
% Find high rate and low rate region for set of 1 or more cths
%   how to determine 1 high and 1 low rate region, the mark II version
%   arbitrary rule:  if bin == mean, include it with high rate bins
%   find mean of cth
%   find incursions, which is where bin goes from above/below mean to
%   below/above mean and conversely. 
%   If num regions > 2
%      Find lowest incursion.
%      if in high, include it with low rate set, remove from high
%      if in low, include it with high rate set, remove from low
%      continue until num regions == 2
%
%   start bin is first bin in high rate region. (don't forget about wrap around)
%   calculate modulation 
%      mod_depth = (hi_rate-lo_rate) ./ (hi_rate+lo_rate);
% INPUTS:
%          matrix of points [rows numbins]
% OUTPUTS:
%          vector [rows 1] start bin for high rate split
%          vector [rows 1] width of high rate split
%          vector [rows 1] modululation depth 
%          vector [rows 1] error stat, measure of how much we had to
%                          tweak regions to merge to 2.
%          vector [rows 1] error stat, histogram of # of merges


function [hi_start hi_width mod_depth, errstat, nummerg] = mod_depth2(cth)
   [numrows,numbins]=size(cth);
   cols=columns(cth(1,:));
   if mod(cols,2) ~= 0
      ui_msg("Warning: number of bins is not even.  mod_depth2 results will not be correct.");
   end
   hi_start=zeros(numrows,1);
   hi_width=zeros(numrows,1);
   mod_depth=zeros(numrows,1);
   errstat=zeros(numrows,1);
   nummerg=zeros(cols/2,1);

   for pt=1:numrows
      pm = mean(cth(pt,:));
      ptm=cth(pt,:) - pm;
      ptmsum=sum(abs(ptm));
      ptcopy=cth(pt,:);

       % if more than 2 regions, force smallest hi or lo to be in lo or hi region
       % will take at most cols/2 attempts to merge the regions
      for passes=1:cols/2;
         hlreg = zeros(1,cols);
         hlreg(find(ptcopy>=pm)) = 1;  % mark hi/lo regions
         num_reg = 1;
         reg = zeros(1,cols);   % reg == regions by number
         reg(1)=num_reg;
         in_hi = ptcopy(1) >= pm;
         for idx = 2:cols
            if in_hi == 1 && ptcopy(idx) >= pm
               reg(idx)= num_reg;
            elseif in_hi == 1 && ptcopy(idx) < pm
               num_reg = num_reg + 1;
               reg(idx)= num_reg;
               in_hi = 0;
            elseif in_hi == 0 && ptcopy(idx) >= pm
               num_reg = num_reg + 1;
               reg(idx)= num_reg;
               in_hi = 1;
            elseif in_hi == 0 && ptcopy(idx) < pm
               reg(idx)= num_reg;
            end
         end
         % Wrap around.  If last region is same lo/hi as first, 
         % put its bin(s) into the first bin's region
         if ptcopy(end) >= pm && ptcopy(1) >= pm
            reg(find(reg==num_reg)) = reg(1);
         elseif ptcopy(cols) < pm && ptcopy(1) < pm
            reg(find(reg==num_reg)) = reg(1);
         end

         num_reg = max(reg);   % how many did we find?
         if num_reg <= 2
            break;
         end
           % more than two regions, figure out what to merge
         regsums=[];
           % find sum of pt-mean for each region
         for freq=1:num_reg
            regsums=[regsums abs(sum(ptm(find(reg==freq))))];
         end
         % region with lowest incursion value
         [~,lowreg]=min(regsums);
         hilo=find(reg==lowreg);
         if hlreg(hilo)(1) == 1          % force this bin into hi or lo region
            ptcopy(hilo) = min(ptcopy);  % in the copy
         else
            ptcopy(hilo) = max(ptcopy);
         end
         errstat(pt) = errstat(pt) + abs(min(regsums));
      end
      nummerg(passes) = nummerg(passes)+1;

      if num_reg == 1  % the Zero Flat has only one region
         hi_start(pt) = 1;
         hi_width(pt) = cols;
         mod_depth(pt) = 0;
      else
         lo_idx=find(hlreg==0);
         hi_idx=find(hlreg==1);
         lomean=mean(cth(pt,:)(lo_idx));
         himean=mean(cth(pt,:)(hi_idx));
         hi_start(pt) = find(ptcopy==max(ptcopy))(1);
%         hi_start(pt) = hi_idx(1);
         hi_width(pt) = sum(hlreg);
         mod_depth(pt) = (himean-lomean) / (himean+lomean);
         if errstat(pt) ~= 0
            errstat(pt) = errstat(pt) / ptmsum;
         end
      end
   end
endfunction

