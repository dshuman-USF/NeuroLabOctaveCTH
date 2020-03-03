function out = dfun(in)
% test function

global X

out = L2_distance(X,X(:,in)); 
out = out'; 
end
