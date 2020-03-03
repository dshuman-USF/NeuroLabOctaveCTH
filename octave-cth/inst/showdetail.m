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
% Utility to show a subset of pts/cths and stats in a window
% Inputs:  points to show
% Outputs: Handle to window, 0 if user bails out

function hand = showdetail(varargin )
global names;
global stats;
   [numpts,~] = size(names);
   [~, bins] = size(evalin('caller',names{1}));

   multi=[];
   for mul=1:max(size(varargin))
      multi=[multi varargin{mul}];
   end
   if isempty(multi) || min(multi) < 1 || max(multi) > numpts
      ui_msg("ERROR WARNpoint numbers out of range");
      retur;
   end

   r = 2;
   c = columns(multi);
   hand = figure('position',[13,400,1800,480]);
   set(hand,'numbertitle','off');
   plt=1;
   for pt=multi
      v38_subplot(r,c,plt,"align");
      data=evalin('caller',names{pt},'hist');
      h = bar(data,'hist');
      set(gca,'xticklabelmode','manual');
      set(gca,'xtick',[1,bins/2,bins]);
      set(gca,'xticklabel',{'1',num2str(bins/2),num2str(bins)});
      ax = axis;
      axis([0 bins ax(3) ax(4)+1],'tight','autoy');
      ptinfo = getseq(names{pt});
      title(ptinfo);

      eb = evalin('caller',stats(pt));
      v38_subplot(r,c,plt+c,"align");
      ebh = errorbar(eb(:,1),eb(:,2),'.');
      set(gca,'xticklabelmode','manual');
      set(gca,'xtick',[1,bins/2,bins]);
      set(gca,'xticklabel',{'1',num2str(bins/2),num2str(bins)});
      ax = axis;
      axis([0 bins+0.5 ax(3) ax(4)]);
      plt = plt + 1;
   end
endfunction

