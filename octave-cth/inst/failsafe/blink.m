% Blink the passed in point(s) by drawing a white circle or
% sphere around the point(s).

function h = blink(p,num_blinks=5)
   if num_blinks == 0
      if (columns(p) == 3)
         h = drawPoint3d(p,'marker','o','markersize',12,'markerfacecolor','w');
      else
         h = drawPoint(p,'marker','o','markersize',12,'markerfacecolor','w');
      end
      return
   end

   for i =1:num_blinks
      if (columns(p) == 3)
         htmp = drawPoint3d(p,'marker','o','markersize',12,'markerfacecolor','w');
      else
         htmp = drawPoint(p,'marker','o','markersize',12,'markerfacecolor','w');
      end
      drawnow;
      pause(.5);
      if i ~= num_blinks
         delete(htmp);
         drawnow;
         pause(.3);
      else
         h = htmp;
      end
   end
endfunction
