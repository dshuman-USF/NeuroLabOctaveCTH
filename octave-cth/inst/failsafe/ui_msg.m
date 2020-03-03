% Display info.
% If using the gui, send it via the socket interface.
% If using local ui, send it to the terminal.
% Since text can be fragmented, we add a delimter to the end of the
% passed-in text.  Embedded newlines are okay, it does not have to 
% be just one line of text.  The gui program will accumulate the text
% until it sees the delimiter, then display it.

function ui_msg(msg)
global termUI;
global client;
if termUI == 0
   guimsg=strcat(msg,"__END__");   % cthgui program expects this at end of text
   send(client,guimsg);
else
   disp(msg);
   fflush(1);
endif
