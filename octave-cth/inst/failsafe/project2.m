# do a projection of vect onto plane subspace e1 and e2 as basis 
% Use e1 e2 basis vectors and project pt(s) into the plane they determine
% ref: http://math.stackexchange.com/questions/185546/how-to-project-a-n-dimensional-point-onto-a-2-d-subspace

function projpt = project2(e1,e2,pts)
   r=rows(pts);
   projpt=[];
   ve1=ones(r,1)*e1;
   ve2=ones(r,1)*e2;
   X = dot(pts,ve1,2) ./ dot(ve1,ve1,2);
   Y = dot(pts,ve2,2) ./ dot(ve2,ve2,2);
   projpt = [X Y];
endfunction

