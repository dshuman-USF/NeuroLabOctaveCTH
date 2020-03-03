% name2period
% Utility function to turn a period number into corresponding string.  
% Input:
% A period name to look up
% Returns: period number as text
% This couples with the cth_cluster and brainstem programs. Changes to any of
% these may require changes here.

function pnum = name2period(pname)
   if strcmp(pname,"CONTROL")
         pnum = "0";
   elseif strcmp(pname,"CC02CTL")
      pnum = "1";
   elseif strcmp(pname,"CC02STIM")
      pnum = "2";
   elseif strcmp(pname,"VCO2CTL")
      pnum = "3";
   elseif strcmp(pname,"VCO2STIM")
      pnum = "4";
   elseif strcmp(pname,"TBCGHCTL")
      pnum = "5";
   elseif strcmp(pname,"TBCGHSTIM")
      pnum = "6";
   elseif strcmp(pname,"LARCGHCTL")
      pnum = "7";
   elseif strcmp(pname,"LARCGHSTIM")
      pnum = "8";
   elseif strcmp(pname,"LARCGHSTIM")
      pnum = "8";
   elseif strcmp(pname,"CS-DELTA")
      pnum = "9";
   elseif strcmp(pname,"SWALLOW1CTL")
      pnum = "10";
   elseif strcmp(pname,"SWALLOW1STIM")
      pnum = "11";
   elseif strcmp(pname,"LAREFLEXCTL")
      pnum = "12";
   elseif strcmp(pname,"LAREFLEXSTIM")
      pnum = "13";
   elseif strcmp(pname,"UNKN")
      pnum = "100";
   else
      pnum = "100";
   end
end
