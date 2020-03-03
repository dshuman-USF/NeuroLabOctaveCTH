% prompt for a number and wait until you get one.
% use default value on just ENTER

function num = getnum(prompt,default)
done = 0;
while done == 0
   if nargin == 2
      def = default;
   else
      def = [];
   end
   tmp=input(prompt,'s');
   if length(tmp) != 0
       num = str2num(tmp);
       if ~isempty(num)
          done = 1;
       else
          disp("Not a number, try again");
       end
   elseif ~isempty(def)
       num= def;
       done = 1;
   else
       disp("No value entered, try again");
   endif
endwhile
endfunction
