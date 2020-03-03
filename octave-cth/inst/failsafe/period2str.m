% period2str
% Utility function to turn a period number into corresponding string.  Input:
% text or scaler that is period 
% Returns: string that is name of the period.
% This couples with the cth_cluster and brainstem programs. Changes to any of
% these may require changes here.

function pname = period2str(period)
   if (length(find(period=='x')))  % types don't have periods
      pnum = 100;
   elseif ischar(period)
      pnum = str2num(period);
   elseif isscalar(period)
      pnum = period;
   else
      pnum = 100;
   end
   if pnum == 0
      pname="CONTROL";
   elseif pnum == 1
      pname = "CCO2CTL";
   elseif pnum == 2
      pname = "CCO2STIM";
   elseif pnum == 3
      pname = "VCO2CTL";
   elseif pnum == 4
      pname = "VCO2STIM";
   elseif pnum == 5
      pname = "TBCGHCTL";
   elseif pnum == 6
      pname = "TBCGHSTIM";
   elseif pnum == 7
      pname = "LARCGHCTL";
   elseif pnum == 8
      pname = "LARCGHSTIM";
   elseif pnum == 9
      pname = "CS-DELTA";
   elseif pnum == 10
      pname = "CONTROL";
   elseif pnum == 11
      pname = "SWALLOW1STIM";
   elseif pnum == 12
      pname = "CONTROL";
   elseif pnum == 13
      pname = "LAREFLEXSTIM";
   else
      pname = "UNKN";
   end
end
