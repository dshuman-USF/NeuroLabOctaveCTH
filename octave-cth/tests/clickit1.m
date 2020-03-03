%{
function clickit1(obj,event)
% callback function used to return the handle of the 
% just-clicked-on cth bar chart subplot

global subcth=0;
global mousepos=[];
global have_click=0;

function clickit1(obj,event)
   global subcth;
   global mousepos;
   global have_click;

   have_click=1;
   subcth=gca;
   mouse=get(subcth,'currentpoint');
end


function [have,hand,mouse]=have_click1
   global subcth;
   global mousepos;
   global have_click;

   if have_click == 1
      have = 1;
      hand = subcth;
      mouse = mousepos;
      have_click = 0;
   else
      have = 0;
      hand = 0;
      mouse = [];
   end
end
%}

