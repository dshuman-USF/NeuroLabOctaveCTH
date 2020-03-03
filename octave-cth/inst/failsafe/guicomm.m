# establish a connection with  the gui
# we become the server, the gui sends us info

function [client] = guicomm(port)
%   s = socket(AF_INET,SOCK_STREAM,0);
   s = socket(2,1,0);
   if (s < 0)
      disp("could not open socket")
      client = -1;
      return
   endif

   res = bind(s,port);
   if res < 0
      disp("failed to bind to port")
      client = -1;
      return
   endif

   res=listen(s,0);
   if (res < 0)
      disp("listen failed")
      client = -1;
      return
   endif

   [client,info] = accept(s);
   disconnect(s);  % don't need this any more, client is the connection

endfunction
