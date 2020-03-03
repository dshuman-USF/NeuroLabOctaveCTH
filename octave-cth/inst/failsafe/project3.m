% Use e1 e2 e3 basis vectors and project pt(s) into the space they determine
% ref: http://math.stackexchange.com/questions/185546/how-to-project-a-n-dimensional-point-onto-a-2-d-subspace
% 

function projpt = project3(e1,e2,e3,pts)
   r=rows(pts);
   projpt=[];
   ve1=ones(r,1)*e1;
   ve2=ones(r,1)*e2;
   ve3=ones(r,1)*e3;
   X = dot(pts,ve1,2) ./ dot(ve1,ve1,2);
   Y = dot(pts,ve2,2) ./ dot(ve2,ve2,2);
   Z = dot(pts,ve3,2) ./ dot(ve3,ve3,2);
   projpt = [X Y Z];
endfunction

