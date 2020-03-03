% Try to connect to gui
% if not started with a port arg, get a random port, start the gui process
% with the port# then listen for the gui process to connect to us until it
% does

function guiconn(port)
global client;
global termUI;
   if (port == 0)    % no port arg
      port = getport();
      cmd = sprintf("cthgui -p %d",port);
      disp("Launching gui. . .");
      fflush(stdout);
      status = system(cmd,[],"async");
      disp("Launched");
   end
   disp("Waiting for gui to connect. . .");
   fflush(stdout);
   client = guicomm(port);
   if (client < 0)
      disp("Listen for gui failed, falling back to local terminal UI.")
      termUI=1;
   else
      disp("Connected. . .");
      fflush(stdout);
   end
end
