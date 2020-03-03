% This is mainly to avoid a lot of clutter early in the cth_project.m file.  

function [color, colorbgnd, cb_friendly, graybgnd, pdistalgo, menu_pdistalgo, linkalgo, menu_linkalgo] = init_consts

color = [
255.0    0.0     0.0;  % clus 1
  0.0  255.0     0.0;  % clus 2
  0.0    0.0   255.0;  % clus 3

255.0    0.0   255.0;  % clus 4
  0.0  255.0   255.0;  % clus 5
204.0  204.0     0.0   % cus 6 (pure yellow hard to see on light bg)

255.0  120.0     0.0;  % clus 7
  0.0  255.0   192.0;  % clus 8
255.0  192.0     0.0;  % clus 9

192.0    0.0   255.0;  % clus 10
  0.0  192.0   255.0;  % clus 11
192.0  255.0     0.0;  % clus 12

255.0  150.0   255.0;  % clus 13
192.0  255.0   255.0;  % clus 14
255.0  255.0    60.0;  % clus 15

150.0  150.0   255.0;  % clus 16
150.0  255.0   150.0;  % clus 17
255.0  250.0   125.0;  % clus 18

179.0  102.0   255.0;  % clus 19
160.0  255.0    66.0;  % clus 20
 27.0  172.0   254.0;  % clus 21

250.0   76.0   252.0;  % clus 22
  0.0  204.0   102.0;  % clus 23
252.0  187.0   226.0;  % clus 24

255.0  123.0     7.0;  % clus 25
213.0    7.0   255.0   % clus 26
255.0  174.0    14.0   % clus 27

255.0   42.0    42.0   % clus 28
 38.0  255.0    56.0;  % clus 29
 72.0   35.0   255.0   % clus 30

193.0   10.0   250.0;  % clus 31
120.0   24.0   250.0   % clus 32
213.0  156.0   219.0   % clus 33
 
% the bstem program equates colors with clusters.
% if we wrap around, it can not tell clusters apart.
% So, "wrap around" the table but change the values by just 1
% to pad the table with numerically (but probably not visually)
% unique colors. At this moment, the max is around 38.

254.0    0.0     0.0;  % clus 34
  0.0  254.0     0.0;  % clus 35
  0.0    0.0   254.0;  % clus 36

254.0    0.0   254.0;  % clus 37
  0.0  254.0   254.0;  % clus 38
203.0  203.0     0.0   % cus  39

254.0  120.0     0.0;  % clus 40
  0.0  254.0   192.0;  % clus 41
254.0  192.0     0.0;  % clus 42

192.0    0.0   254.0;  % clus 43
  0.0  192.0   254.0;  % clus 44
192.0  254.0     0.0;  % clus 45

254.0  150.0   254.0;  % clus 46 
192.0  254.0   254.0;  % clus 47 
254.0  254.0    60.0;  % clus 48

150.0  149.0   254.0;  % clus 49
150.0  254.0   150.0;  % clus 50
238.0  240.0   118.0;  % clus 51

194.0  132.0   254.0;  % clus 52 
172.0  247.0    58.0;  % clus 53
 29.0  162.0   240.0;  % clus 54
] / 255.0;


[~,ind]=unique(color,'rows');
duplicate=setdiff(1:size(color,1),ind);
if ~isempty(duplicate)
   ui_msg("Warning, duplicate colors in color table\n");
end
% this also padded with almost-dups, see above
colorbgnd=[1 1 1];

cb_friendly = [ 
0 0 255.0;
0 73.0 73.0;
0 146.0 146.0;
255.0 109.0 182.0;
255.0 182.0 119.0;
73.0 0.0 146.0;
0.0 109.0 219.0;
182.0 109.0 255.0;
109.0 182.0 255.0;
182.0 218.0 255.0;
146.0 0.0 0.0;
146.0 73.0 0.0;
219.0 209.0 0.0;
36.0 255.0 36.0;
255.0 255.0 109.0;
0 0 254.0;
0 72.0 73.0;
0 145.0 146.0;
254.0 109.0 182.0;
254.0 182.0 119.0;
72.0 0.0 146.0;
0.0 108.0 219.0;
181.0 109.0 255.0;
108.0 182.0 255.0;
181.0 218.0 255.0;
145.0 0.0 0.0;
145.0 73.0 0.0;
218.0 209.0 0.0;
35.0 255.0 36.0;
254.0 255.0 109.0;
0 0 253.0;
0 71.0 73.0;
0 144.0 146.0;
253.0 109.0 182.0;
253.0 182.0 119.0;
71.0 0.0 146.0;
0.0 107.0 219.0;
180.0 109.0 255.0;
107.0 182.0 255.0;
180.0 218.0 255.0;
144.0 0.0 0.0;
144.0 73.0 0.0;
217.0 209.0 0.0;
34.0 255.0 36.0;
253.0 255.0 109.0;
0 0 252.0;
0 70.0 73.0;
0 143.0 146.0;
252.0 109.0 182.0;
252.0 182.0 119.0;
70.0 0.0 146.0;
0.0 106.0 219.0;
179.0 109.0 255.0;
106.0 182.0 255.0;
179.0 218.0 255.0;
143.0 0.0 0.0;
143.0 73.0 0.0;
216.0 209.0 0.0;
33.0 255.0 36.0;
252.0 255.0 109.0;
] / 255.0;
[~,ind]=unique(cb_friendly,'rows');
duplicate=setdiff(1:size(cb_friendly,1),ind);
if ~isempty(duplicate)
   ui_msg("Warning, duplicate colors in color table\n");
end

graybgnd=[.95 .95 .95];

pdistalgo={'custom from file','euclidean','seuclidean','cityblock','cosine','correlation','spearman','chebychev'};

menu_pdistalgo={'custom from file*','euclidean','seuclidean','cityblock','cosine','correlation','spearman','chebychev'};

% todo archetype not supported for cmd line, we choose too late in flow
linkalgo={'single','complete','average','weighted','centroid','median','ward','archetype'};
menu_linkalgo={'single','complete*','average','weighted','centroid','median','ward'};


end
