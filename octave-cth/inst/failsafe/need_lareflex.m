% Utility to see if the current file has lareflex CTHs in it.
% See getseq.m for an explanation of the code below.

function found = need_lareflex(CthVars)
   found = false;
   for [val,key]=CthVars
       namefields = strsplit(key,"_");
       period = namefields{end-1};
       if strcmp(period,"13")
          found = true;
          break;
       end
   end
end
