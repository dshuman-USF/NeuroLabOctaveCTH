%    Copyright (C) 2014-2020 K. F. Morris

%    This file is part of the USF CTH Clustering software suite.
%    This software is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.

%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.

%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <https://www.gnu.org/licenses/>.
%
%
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
