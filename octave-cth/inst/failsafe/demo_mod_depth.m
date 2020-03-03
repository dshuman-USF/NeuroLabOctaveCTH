close all
clear all

% pt 31 cth_selected20
pt1 =[ 6.8689 3.6317 3.3337 13.414  37.69 68.661 96.385 120.92  165.2 214.66 258.05  217.3 165.89 129.19 76.042 41.348 11.871 3.6799 1.5062 3.7541];

% pt 77 cth_selected20
pt2 = [1.0552 8.2173 40.229 84.001  136.2 184.72 211.96 235.71 257.19  256.9 178.58 35.066 4.3145 0.49121 0.78544 0.54773 0.86201 0.83735 0.53077  1.1815];

% pt 37 cth_selected20
pt3 =[ 214.35  205.98  188.75  173.16  157.82  146.12  134.11   122.9  108.05  61.528  3.9041 0 0 0 0 0 0 0.22401 11.409 111.09];

%pt 10 cth_1file20
pt4=[ 89.1973022936948 72.7960114977806 70.9506010006838 69.8251832643101 66.736629472867 62.828376441131 55.6835083044809 51.6365822612196 44.6750471153692 41.4052890816654 19.8228214132014 27.6904871478182 35.9107836905915 42.5665261192248 48.3509144606215 52.1762337342181 57.89722986903 62.7639762289267 68.6359704396319 84.1448456834995];

%pt 01010 cth_large20
%pt5= [111.451424701972 98.6568496638619 54.4678597607759 85.0340696437482 128.113793696947 74.5843270562844 115.756746788856 80.677436041547 43.2434944991432 75.0452360585204 111.329010101539 101.683901932781 240.045234067943 187.452635261815 213.192145327129 158.652596623694 84.4474150577793 228.437157925732 135.171627390404 128.750377739576];
%pt5= [111.451424701972 98.6568496638619 54.4678597607759 85.0340696437482 128.113793696947 74.5843270562844 115.756746788856 80.677436041547 43.2434944991432 75.0452360585204 111.329010101539 101.683901932781 240.045234067943 187.452635261815 213.192145327129 158.652596623694 84.4474150577793 228.437157925732 95.171627390404 108.750377739576];

pt5= [111.451424701972 98.6568496638619 54.4678597607759 85.0340696437482 128.113793696947 128.5843270562844 115.756746788856 80.677436041547 43.2434944991432 75.0452360585204 111.329010101539 101.683901932781 240.045234067943 187.452635261815 213.192145327129 158.652596623694 84.4474150577793 228.437157925732 95.171627390404 108.750377739576];

%pt 00126 cth_large20
pt6= [167.40578526398 220.645202186799 97.5585774208735 233.393517464533 205.480818030001 267.811091831053 271.764464488097 174.580893481871 173.61796116042 127.878435714054 11.2971120048464 0 0 38.6651618217844 61.3852164116579 79.5963996389622 59.654598952092 90.6598831724891 71.7527597063053 103.045460590231];


%pt 00630 cth_large20
pt7=[4.74832832772718 0.0756846934886866 0.0797104750572337 1.13768296382614 4.28125212467039 14.6589726983082 33.1099383034189 56.7039050479432 66.0029545982398 97.1421489238974 210.899952185384 225.930271757524 230.010033304158 236.052340494851 237.733462836013 241.240381927494 232.584862131453 223.812170067617 202.282747545729 137.706538933248];

% pt 00021 cth_large1p
pt8=[ 119.831216760887 126.31358482791 128.606410847674 131.434998950755 134.064287593292 131.641156974774 133.790483082012 129.719325423351 130.997189006274 134.963678938312 122.854434690835 118.858477329843 119.536229823958 116.780521775917 114.218530918312 112.413383160418 110.540650440676 111.357736195167 111.608975990826 116.662066608855];


% pt 00292 cth_large1p
pt9=[ 125.52727135962 123.526690337252 122.244305047329 121.721711192343 118.98012529689 120.395315204324 115.550565808303 117.102320823886 115.30741585481 114.883621223702 124.240133658022 129.726794552733 128.328691686047 126.72320502074 124.533120096168 124.20773401151 123.967901823438 125.928853454024 126.787169027015 126.510393861893];

% name: Cthstat_00308
pt10=[110.651500937521 106.773514477668 112.602357065419 121.288066855284 115.318992317307 122.194063247011 122.297557769111 134.112839339351 124.15776475651 139.530825376924 143.535365558879 124.835505243221 130.702584043792 130.900589210998 126.87077704187 131.483743760414 122.514925006777 119.798763669351 111.022839444981 105.600764217659];

pt11=[ 100 200 100 200 100 200 100 200 100 200 100 200 100 200 100 200 100 200 100 200 ]; 
pt12=[ 200 100 200 100 200 100 200 100 200 100 200 100 200 100 200 100 200 100 200 100 ]; 


   cth=[pt1;pt2;pt3;pt4;pt5;pt6;pt7;pt8;pt9;pt10;pt11;pt12];
   len=columns(pt1);
   cols=columns(pt1);
   r=rows(cth);
   pm = mean(pt5);
   pt5m=pt5-pm;

   fig1=figure('position',[1000,500,800,400]);
   bar(pt5m);
   subs=ceil(sqrt(r));

   fig2 = figure('position',[46,53,900,450]);
   hold on
   for s=1:r
      subh(s)=v38_subplot(subs,subs,s);
      hold on
      h = bar(cth(s,:),'g',.2);
      set(gca,'xticklabelmode','manual');
      set(gca,'xtick',[1,cols/2,cols]);
      set(gca,'xticklabel',{'1',num2str(cols/2),num2str(cols)});
      box off;
      ax=axis(); 
      axis([0 cols ax(3) ax(4)]);
      m1=mean(cth(s,:));
      line([0 cols],[m1 m1],'color','k','linewidth',1.5);
   end
   
   fig3 = figure('position',[46,530,900,450]);
   for s=5
      hold on
      h = bar(cth(s,:),'g',.2);
      set(gca,'xtick',[1:cols]);
      box off;
      ax=axis(); 
      axis([0 cols ax(3) ax(4)]);
      m1=mean(cth(s,:));
      line([0 cols],[m1 m1],'color','k','linewidth',2);
   end

   for pt=1:r
      ptcopy=cth(pt,:);
      pm=mean(cth(pt,:));
      ptm=cth(pt,:)-pm;
      errstat=0;

       % assuming even # of columns, there will at most be cols/2 regions
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
#   keyboard;
         num_reg = max(reg);   % how many?
         if num_reg == 2   
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
         errstat = errstat + abs(min(regsums));
      end
#keyboard;
      lo_idx=find(hlreg==0);
      hi_idx=find(hlreg==1);
      lomean=mean(cth(pt,:)(lo_idx));
      himean=mean(cth(pt,:)(hi_idx));
      startbin = hi_idx(1);
      binwidth = sum(hlreg);
      mod_depth = (himean-lomean) / (himean+lomean);
      if errstat != 0
         errstat = errstat / sum(abs(ptm));
      end
      figure(fig2);
      v38_subplot(subh(pt));
      res=sprintf("strt=%d  wid=%d\ndepth=%2.3f  err=%2.3f", startbin,binwidth,mod_depth,errstat);
      title(res);

   end

%{
   how to determine 1 high and 1 low rate region, the mark II version
   arbitrary rule:  if bin == mean, include it with high rate bins
   find mean of cth
   find incursions, which is where bin goes from above/below mean to
   below/above mean and conversely. 
   If num regions > 2
      Find lowest incursion.
      if in high, include it with low rate set, remove from high
      if in low, include it with high rate set, remove from low
      continue until num regions == 2

   start bin is first bin in high rate region. (don't forget about wrap around)
   calculate modulation 
      mod_depth = (hi_rate-lo_rate) ./ (hi_rate+lo_rate);
%}
