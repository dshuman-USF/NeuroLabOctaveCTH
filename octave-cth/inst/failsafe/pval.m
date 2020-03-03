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
