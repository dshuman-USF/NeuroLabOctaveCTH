function [h] = figure1(varargin)
% test func
%{
sleep(5)
   [val,txt]=system("wmctrl -a :ACTIVE: -v 2>&1");
   res=strsplit(txt)
   h = figure(varargin{:});
   fflush(stdout)
   [val,txt]=system("wmctrl -a :ACTIVE: -v 2>&1")
   strsplit(txt)

   disp("make console active")
   cmd = sprintf("wmctrl -i -a %s -v 2>&1",res{5})
   fflush(stdout)
   [val,txt]=system(cmd);
   strsplit(txt)
%}
end
