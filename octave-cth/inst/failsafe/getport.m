% get a random port that is probably not in use 
% (race condition is possible but very unlikely)
% return port
function [guiport] = getport
haveport = 0;
while haveport == 0
   guiport=randi([49152,65535]);
   portchk = sprintf("netstat -an | grep -q %d",guiport);
   inuse=system(portchk);
   if inuse == 1
      haveport = 1;
   endif
endwhile
