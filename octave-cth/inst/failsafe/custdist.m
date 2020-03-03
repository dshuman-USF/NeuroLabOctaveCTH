function [re_dist]=custdist(CthVars,names)
% (re)create the custom distance matrix from the provided set of point var names
% Inputs:  names: list of pt names in a cell strings
% Output:  distance matrix the custome one from cth_cluster program
%          or the pdist function.
% Assumes: The MeanSclStdErr matrix is:
%           rows = # of bins
%           2 cols:
%           possibly scaled mean rate      scaled std err

   dim=size(names)(1);

   re_dist = zeros(dim,dim);
   % extract info we need from points
   for idx=1:dim
      m_s{idx}=CthVars.(names{idx}).MeanSclStdErr;
   end
   total_bins = size(m_s{1})(1);

   % okay, do what we're here for
   for row0 = 1:dim-1
      for row1 = row0+1:dim
         sumsqr = 0;
         for idx=1:total_bins
            mr0   = m_s{row0}(idx,1);
            sserr0 = m_s{row0}(idx,2);
            mr1   = m_s{row1}(idx,1);
            sserr1 = m_s{row1}(idx,2);
            if sserr0 == 0 && sserr1 == 0
               continue;
            end
                  % our distance metric               
            subd  = (mr0 - mr1) / sqrt(sserr0*sserr0 + sserr1*sserr1);
            sumsqr += subd*subd;
         end
         d = sqrt(sumsqr);
         re_dist(row0,row1) = d;  % add to matrix
         re_dist(row1,row0) = d;
      end
   end
end



