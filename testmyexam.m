%This script is for testing myexam
%Use leftclick to place normal particles, rightclick for special ones.
tend  = 2; %Set endtime

p_path = 0; %0 for particles 1 for path
%Set the four walls reaction, 0 for closed, 1 for open 2 for periodic
wall_left = 0;
wall_right = 0;
wall_top = 0;
wall_buttom = 0;

force = 0; %set forcemodel, 0 for no force, 1 for constant, 2 for lin. increasing

nr = 4; %Set nr of objects you will place

col = 0; %Set 0 for no collision between balls, 1 for collisions

ref = 0.9; %Wall reflectivity, 1 for all speed is kept

obj = 2; %Nr of balls placed per object

r = 0.1; %Radius of balls, set to something small if you dont care about collisons

killr = 1; %radius within which special balls kill normal ones, 
%should be atleast 2*r, or no balls will be killed

myexam(tend,p_path,wall_left,wall_right,wall_top,wall_buttom,force,nr,col,ref,obj,r,killr)
