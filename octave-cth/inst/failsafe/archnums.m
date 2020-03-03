% to avoid having lots of magic numbers for archetype cths
% in the code, this function puts all the magic in one place.
function [arch] = archnums()
   arch=struct;
   arch.std=[100,200,300];
   arch.flat=[400];
   arch.swallow=[600,700,800];
   arch.lareflex=[1000,1100,1200];
end
