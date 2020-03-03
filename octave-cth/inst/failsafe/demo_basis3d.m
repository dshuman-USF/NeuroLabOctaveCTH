#!/usr/bin/octave -qf

# this is a demo showing how to take 3 points in 3 space,
# create a basis with them, and then
# project some points into the plane formed by the basis

# vector math fun for the CTH project
pkg load general
pkg load geometry

clc
home
graphics_toolkit fltk
#graphics_toolkit gnuplot

# non-colinear
A = [3,8,8];
B = [4,9,-6];
C = [-4,8,9];

#XY plane
#A = [2,3,0];
#B = [1,4,0];
#C = [4,5,0];

# colinear
#A = [3,8,10];
#B = [6,16,20];
#C = [12,32,40];


# to test for colinear, use triangle inequality
# for two vects ||AB + BC|| <= ||AB|| + ||BC||
# if ==, then on same line

#keyboard("Hi!\n");

CB = B - C;
CA = A - C;

lhs = norm(CB + CA);
rhs = norm(CB) + norm(CA);

if (abs(rhs - lhs) < eps)
{
   printf("Degenerate case, no plane possible\n");
   exit(1);
}
else
   printf("Non-colinear\n");
endif
printf("******************************************\n");

# From Russ's notes:
#unit vector for CB 
# (C is origin)


#normalized CB
n_CB = (CB / norm(CB));
#CA component on CB
ca_comp = dot(n_CB,CA);
# vect perpindiculat ro CB
perp_to_cb = CA - ca_comp * n_CB;
# normalized of same
normalize_perp = perp_to_cb / norm(perp_to_cb);

disp "normalised basis for the plane:\n"
ne1 = normalize_perp ;
ne2 = n_CB;

dot(ne1, ne2);
dot(CB, perp_to_cb);
dot(CB, normalize_perp);


#if this zero (or close), they are orthogonal
if (abs(dot(ne1, ne2)) <= eps)
   printf("Vectors orthogonal\n")
else
   printf("Vectors not orthogonal\n")
endif

function mylim()

set(gca(),"xlim",[-10,10]);
set(gca(),"ylim",[-10,10]);
set(gca(),"zlim",[-10,10]);
endfunction


# do a projection of vect onto plane subspace e1 and e2 as basis 
function proj_vect = project(e1,e2,vect)
   proj_vect = ((dot(vect,e1) / dot(e1,e1)) * e1) + ((dot(vect,e2) / dot(e2,e2))) * e2;
   line([vect(1) proj_vect(1)],[vect(2) proj_vect(2)],[vect(3) proj_vect(3)]);
   scatter3(proj_vect(1),proj_vect(2),proj_vect(3),"filled");
   scatter3(vect(1),vect(2),vect(3),'r');
endfunction


# test to see if pts in plane, that is,
# is vect from origin to pt a linear combination of ne1 and ne2
function test_pt(e1,e2,pt,name)
   a = [e1' e2'];
   p = [pt'];
   b = [a p];

rank(a);
rank(b);

  if (rank(a) == rank(b))
     printf("%s is in the plane\n",name);
   else
     printf("%s is NOT in the plane\n",name);
   endif
endfunction



# plot stuff
cla
hold on
mylim
xlabel("X");
ylabel("Y");
zlabel("Z");

figure(1,'position',[70,100,1800,1100]);

#origin
scatter3(0,0,0,10,[0,0,0],"filled");

#original 3 pts, 2 vects
scatter3(A(1),A(2),A(3),8,'b');
scatter3(B(1),B(2),B(3),8,'b');
scatter3(C(1),C(2),C(3),8,'b');
hc1 = line([C(1),A(1)],[C(2),A(2)],[C(3),A(3)]);
hc2 = line([C(1),B(1)],[C(2),B(2)],[C(3),B(3)]);
set(hc1,'linewidth',1,'color','b','linestyle',"--");
set(hc2,'linewidth',1,'color','b','linestyle',"--");

# use C as new origin, translate to it
hc1 = line([0,CA(1)],[0,CA(2)],[0,CA(3)]);
hc2 = line([0,CB(1)],[0,CB(2)],[0,CB(3)]);
set(hc1,'linewidth',2,'color','b','linestyle',"--");
set(hc2,'linewidth',2,'color','b','linestyle',"--");


hc3 = line([0,n_CB(1)],[0,n_CB(2)],[0,n_CB(3)]);
set(hc3,'linewidth',4,'color','r');

hc3a = line([0,normalize_perp(1)],[0,normalize_perp(2)],[0,normalize_perp(3)]);
set(hc3a,'linewidth',4,'color','r');



#perp_to_cb 
scatter3(perp_to_cb(1),perp_to_cb(2),perp_to_cb(3),8,'g',"filled");
hc4 = line([0    perp_to_cb(1)],[0    perp_to_cb(2)],[0    perp_to_cb(3)]);
set(hc4,'linewidth',1,'color','g','linestyle',"--");



P1 = [-4,0,8];
P2 = [7,-2,-4];
P3 = [1,9,7];

proj1 = project(ne1,ne2,P1);
proj2 = project(ne1,ne2,P2);
proj3 = project(ne1,ne2,P3);

patch( [proj1(1)
        proj2(1)
        proj3(1)],
       [proj1(2)
        proj2(2)
        proj3(2)],
       [proj1(3)
        proj2(3)
        proj3(3)],[.7,.4,.5] );




test_pt(ne1,ne2,P1,"P1");
test_pt(ne1,ne2,proj1,"proj1");
test_pt(ne1,ne2,P1,"P2");
test_pt(ne1,ne2,proj1,"proj2");
test_pt(ne1,ne2,P1,"P3");
test_pt(ne1,ne2,proj1,"proj3");


for pt=1:10
   next = 10  * rand(3,1) .* sign(randn(3,1));
   proj = project(ne1,ne2,next);
   test_pt(ne1,ne2,proj,"pt");
   test_pt(ne1,ne2,next',"next");
endfor
  



#scatter3(e1(1),e1(2),e1(3))
#scatter3(e2(1),e2(2),e2(3))

#he1 = line([C(1),e1(1)],[C(2),e1(2)],[C(3),e1(3)])
#he2= line([C(1),e2(1)],[C(2),e2(2)],[C(3),e2(3)])

#set(he1,'color','r')
#set(he2,'color','r')

#he3 = line([C(1),ne1(1)],[C(2),ne1(2)],[C(3),ne1(3)])
#he4= line([C(1),ne2(1)],[C(2),ne2(2)],[C(3),ne2(3)])
#set(he3,'color','g')
#set(he4,'color','g')


#line([0,ne1(1)],[0,ne1(2)],[0,ne1(3)])
#line([0,ne2(1)],[0,ne2(2)],[0,ne2(3)])
#line([0,e1(1)],[0,e1(2)],[0,e1(3)])
#line([0,e2(1)],[0,e2(2)],[0,e2(3)])

#line([0,ne1(1)],[0,ne1(2)],[0,ne1(3)])
#line([0,ne2(1)],[0,ne2(2)],[0,ne2(3)])


#scatter3(ne2(1),ne2(2),ne2(3),10,200)
#scatter3(ne1(1),ne1(2),ne1(3),10,200)

#D0 projected into ne1,ne2 basis

#scatter3(proj_d0_ne(1),proj_d0_ne(2),proj_d0_ne(3),16,30,'filled')
#scatter3(D0(1),D0(2),D0(3),16,20,'filled')

#h1 = line([D0(1),proj_d0_ne(1)], [D0(2),proj_d0_ne(2)], [D0(3),proj_d0_ne(3)])
#set(h1,'linewidth',3)





#  simul equs:  eg:
#  x+y=4
# 2x+y=10
# f1=[1 1;2 1]
# f2=[4;10]
# solution is f1 \ f2, or  6
#                          2 

# proj1 = c1*ne1 + c2*ne2
# j


