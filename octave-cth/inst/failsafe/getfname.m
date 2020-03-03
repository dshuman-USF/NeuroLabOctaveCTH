% prompt for file name, use default on just ENTER

function name = getfname(default='');
   have_name = 0;
   while have_name == 0
      tmp = input("File to load: ","s");
      tmp = strtrim(tmp);
      if length(tmp) != 0
           name = tmp;
           have_name = 1;
      else
        disp('No file name entered, try again');
      end
   end
endfunction
