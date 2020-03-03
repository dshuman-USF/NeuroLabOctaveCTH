% Utility to see if the current file has swallow 1 CTHs in it.
% See getseq.m for an explanation of the code below.

function found = need_swall1(CthVars)
   found = false;
   for [val,key]=CthVars
       namefields = strsplit(key,"_");
       period = namefields{end-1};
       if strcmp(period,"11")
          found = true;
          break;
       end
   end
end
