% function [hi_start hi_width mod_depth] = mod_depth1(cth)
% Find high rate and low rate region for set of 1 or more cths
% for all possible widths and all possible starting points 
% Will be numbins starting points and numbins-1 possible widths
% numbins*(nimbins-1) possible splits
% Determine which split has the maximum mean high rate:
%   mean rate = sum of bin values in split / num bins in split
%   For that split, calculate modulation depth:
%   (mean_high_rate-mean_lo_rate) / (mean_high_rate+mean_lo_rate) 
% INPUTS:
%          matrix of points [rows numbins]
% OUTPUTS:
%          vector [rows 1] start bin for high rate split
%          vector [rows 1] width of high rate split
%          vector [rows 1] modululation depth 
%

function [hi_start hi_width mod_depth] = mod_depth1(cth)

   [numrows,numbins]=size(cth);
   hi_start=zeros(numrows,1);
   hi_width=zeros(numrows,1);
   mod_depth=zeros(numrows,1);
   maxrate=zeros(numrows,1);
   hi_rate=zeros(numrows,1);
   lo_rate=zeros(numrows,1);
   diffs=zeros(numrows,1);
   newmax1=[];
   newmax2=[];
   binsel=1:numbins; %  create  [1 2 3...numbins]

   for bins=1:numbins
      widths=zeros(1,numbins);  % split selection mask
      widths(1)=1;
      for w=1:numbins-1
         split1=binsel(binsel&widths);
         split2=binsel(binsel&~widths);
         curr1 = sum(cth(:,:)(:,split1),2)/sum(widths);  % for all rows
         curr2 = sum(cth(:,:)(:,split2),2)/sum(~widths);
         diffs=abs(curr1-curr2);
         [idxsp1h,~] = find(curr1-curr2>0);  % sp1 is hi, sp2 lo
         [idxsp2h,~] = find(curr1-curr2<=0); % sp2 is hi, sp1 lo
         maxes=find((diffs-maxrate)>0); % new maximums (if any)
         if rows(idxsp1h) > 0
            newmax1=intersect(maxes,idxsp1h);
         end
         if rows(idxsp2h) > 0
            newmax2=intersect(maxes,idxsp2h);
         end
         if rows(newmax1) > 0
            maxrate(newmax1)=diffs(newmax1);
            hi_rate(newmax1)=curr1(newmax1);
            lo_rate(newmax1)=curr2(newmax1);
            hi_width(newmax1)=sum(widths);
            hi_start(newmax1)=split1(1);
         end
         if rows(newmax2) > 0
            maxrate(newmax2)=diffs(newmax2);
            hi_rate(newmax2)=curr2(newmax2);
            lo_rate(newmax2)=curr1(newmax2);
            hi_width(newmax2)=sum(~widths);
            hi_start(newmax2)=split2(1);
         end
         widths=shift(widths,1);
         widths(1)=1;
      end
      binsel=shift(binsel,-1);
   end
   mod_depth = (hi_rate-lo_rate) ./ (hi_rate+lo_rate);
endfunction

