
function [retval] = ui_prompt (prompt)

   msg = cstrcat('PARAM REQUIRED ',prompt);
   ui_msg(msg);

   [prompt_val,quit] = chk_for_gui_cmd(1);  % wait until response sent by gui
   retval = prompt_val;

endfunction
