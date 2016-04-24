function [] = myexam(tend,p_path,wallleft,wallright,walltop,wallbuttom,force,nr,col,ref,obj,rad,killr)
%Made by
%Lasse Skaaning Husbjerg, 2711932235 gbl314

%This program shows several moving objects, depending on your variables you
%can make them able to collide with oneanother, pass through eachother and
%you can plot their current location or their full path.
%
%Table creation begins here
x_length = 25;%Length in x dimension
y_length = 25;%Length of table in y
table = [x_length, y_length];       % Size of the table (m)

plot([0, table(1)], [0, 0], 'black'); % Bottom
hold on
plot([0, 0], [0, table(2)], 'black'); % Left side
plot([0, table(1)], [table(2), table(2)], 'black'); % Top
plot([table(1), table(1)], [0, table(2)], 'black'); % Right side
axis equal;
axis([-1, table(1)+1, -1, table(2)+1]); % Create our table inside the plot, makes it easier to see what is happening

%Table creation ends here


dt = 0.01; % Time step (s)
weird = true; %Do weird balls exist?

t = 0;
counter = 0;


%%%%%%%Changeable variables begin here
tmax = tend; %End time

nrprobj = obj; % nr of bbbals per object

plot_on_off = 1; %Should we plot this?

%Do we plot the path of the particles or the particles themselves? 0 for
%the position 1 for the path they take
plot_path = p_path; 

%Can the particles collide with eachother? For 0, they cannot and for 1
%they are given a specific radius.
collision = col;
%Set wall values, 0 = closed, 1 = open 2 = periodic

wall_left = wallleft;
wall_right = wallright;
wall_top = walltop;
wall_buttom = wallbuttom;

%Set outside force
%If k = 0, outside force is 0, if k = 1 outside force is a constant
%vector, if k = 2, outside force is linearly increasing in a constant
%direction
k = force;

%How much speed is lost for each time it hits a closed wall? Set between 0
%and 1 (Over 1 to gain speed)
reflectivity = ref;

%Nr of objects
n = nr; 
%Run through n times before path is plotted.

plot_per_n = 5;

%%%%%%%Changeable variables end here

%%%%%%%Balls creation begins here
balls = struct;

balls.v = zeros(1,n);
balls.acc = zeros(1,n);
balls.accd = zeros(1,n);
balls.color = zeros(1,n);
balls.weird = zeros(1,n);
[x,y,button] = ginput(n);
q = nrprobj; %For some reason my calcultions only work for c=q
c = q;

for l = 1:q*n %Set all balls to normal
balls(l).weird = 0;
balls(l).kill = 0;
end

for i = 1:n
    if button(i) == 1 %Normal ball pos, for leftclick
         for a=1:q
           balls(a+(i-1)*q).pos = [x(i),y(i)];
         end
    elseif button(i) == 3 %Weird ball pos, for rightclick
         for a=1:c
           balls(a+(i-1)*c).pos = [x(i),y(i)];
         end
    end

    if weird == true && button(i) == 3; %Give weird balls their weirdness and killingpower
        for a = 1:c
        balls(a+(i-1)*c).weird = true;
        balls(a+(i-1)*c).kill = killr;
        end
    end
end

for z = 1:q*n %Give all balls their other attributes (Also only works for q=c)
balls(z).v = randn(2,1)'.*10;        % Ball-z's velocity (m/s))
balls(z).r = rad;          % Ball-z's radius (m)
balls(z).acc = [0 0];
balls(z).accd = [0 0];
balls(z).color = [0.25+0.5.*rand 0.25+0.5.*rand 0.25+0.5.*rand]; %Choose a random color from the RGB spectrum, in an appropiate range
    if balls(z).weird ==  true;
    balls(z).color = [0 0 0]; %Choose black for special balls
    end
if k == 0; %Set acc for different forcevalues, this is no outside force
    balls(z).acc = [0 0];
    balls(z).accd = [0 0];
elseif k == 1; %Constant outside force
    balls(z).acc = randn(2,1)';
    balls(z).accd = [0 0];
elseif k == 2; %Increasing outside force
    s = randn(2,1)';
    balls(z).acc = s;
    balls(z).accd = s;
else
disp('Force value outside valid spectrum')
end

end
%%%%%%%Ball creation ends here





while t<tmax % As long as we want to

    for a = 1:length(balls) % Update values for each ball

        if k == 2; %Ensure the increasing outside force increases with time
            for i = 1:length(balls)
            balls(i).acc = balls(i).acc + balls(i).accd.*dt;
            end
        end

%%%%%%%The calculations for moving forward in space start here
           if t == 0           
                balls(a).pos = balls(a).pos + balls(a).v .* dt+1/2.*balls(a).acc.*dt.^2;
                balls(a).v = balls(a).v+balls(a).acc.*dt;
                t=t+dt;
             elseif t == dt;
                  balls(a).pos = balls(a).pos + balls(a).v .* dt+1/2.*balls(a).acc.*dt.^2;
                  balls(a).v = balls(a).v+balls(a).acc.*dt;
                  t=t+dt;
            else    
                balls(a).pos = balls(a).pos + balls(a).v .* dt+...
                1/2.*balls(a).acc.*dt.^2+1/6.*balls(a).accd.*dt.^3;%sæt p hvor p(i+1)=v(i+1) + 1/2*a*dt^2+1/6*a*dt^3
                balls(a).v = balls(a).v+balls(a).acc.*dt +... %find v, hvor v(i+1)=v(i)+1/2*a_d*dt^2
                1/2.*balls(a).accd.*dt.^2;%+1/6.*a_d.*dt.^3;
           end
    end
%%%%%%%The calculation for moving forward in space end here

%%%%%%%Wall collision calculations start here
for a = 1:length(balls)
      
%Closed wall starts here
        %This is for closed left wall
        if (balls(a).pos(1)-balls(a).r <= 0 && balls(a).v(1) < 0 && wall_left == 0)
           % Then reverse the horizontal component of the balls speed
            balls(a).v(1) = -balls(a).v(1).*reflectivity;
            balls(a).pos(1) = table(1)-(table(1)-balls(a).r);
        end
        %This is for closed right wall
        if (balls(a).pos(1)+balls(a).r >= table(1) && balls(a).v(1) > 0 && wall_right == 0)
           % Then reverse the horizontal component of the balls speedq
            balls(a).v(1) = -balls(a).v(1).*reflectivity;
            balls(a).pos(1) = table(1)-balls(a).r;
        end


        %This is for closed buttom wall
        if (balls(a).pos(2)-balls(a).r  <= 0 && balls(a).v(2) < 0 && wall_buttom == 0)
            % Then reverse the vertical component of the balls speed
            balls(a).v(2) = -balls(a).v(2).*reflectivity;
            balls(a).pos(2) = table(1)-(table(1)-balls(a).r);
        end
        %This is for closed top wall
        if (balls(a).pos(2)+balls(a).r >= table(2) && balls(a).v(2) > 0 && wall_top == 0)
            % Then reverse the vertical component of the balls speed
            balls(a).v(2) = -balls(a).v(2).*reflectivity;
            balls(a).pos(2) = table(1)-balls(a).r;
        end
%Closed wall ends here

%Open wall starts here
        %This is for open left wall
        if (balls(a).pos(1)-balls(a).r <= 0 && balls(a).v(1) < 0 && wall_left == 1)
            balls(a).pos = nan(1,2); 
        end
        %This is for open right wall
        if (balls(a).pos(1)+balls(a).r >= table(1) && balls(a).v(1) > 0 && wall_right == 1) 
            balls(a).pos = nan(1,2);
        end

        %This is for open top wall
        if (balls(a).pos(2)+balls(a).r >= table(2) && balls(a).v(2) > 0 && wall_top == 1)           
            balls(a).pos = nan(1,2);
        end

        %This is for open buttom wall 
        if (balls(a).pos(2)-balls(a).r  <= 0 && balls(a).v(2) < 0 && wall_buttom == 1)                          
            balls(a).pos = nan(1,2);
        end
%Open wall ends here


%Periodic wall starts here
        %This is for periodic left wall
        if (balls(a).pos(1)-balls(a).r <= 0 && balls(a).v(1) < 0 && wall_left == 2)
            balls(a).pos(1) = table(1)-balls(1).r; 
        end

        %This is for periodic right wall
        if (balls(a).pos(1)+balls(a).r >= table(1) && balls(a).v(1) > 0 && wall_right == 2)
            balls(a).pos(1) = table(1)-(table(1)-balls(1).r);
        end


        %This is for periodic top wall    
        if (balls(a).pos(2)+balls(a).r >= table(2) && balls(a).v(2) > 0 && wall_top == 2)                          
            balls(a).pos(2) = table(2)-(table(2)-balls(2).r);
        end

        %This is for periodic buttom wall 
        if (balls(a).pos(2)-balls(a).r  <= 0 && balls(a).v(2) < 0 && wall_buttom == 2)                          
            balls(a).pos(2) = table(1)-balls(1).r; 
        end
%Periodic wall ends here

%%%%%%%Wall collision calculations end here



%%%%%%%Kill radius calculations begin here
        
    for b = a+1:length(balls) % Compare the current ball to all with a higher index
       if (norm(balls(b).pos - balls(a).pos) <= balls(b).kill) || ... %Is any ball within killing radius
          (norm(balls(b).pos - balls(a).pos) <= balls(a).kill)
           %Then only kill if one is weird and one is not
            if balls(b).weird == true && balls(a).weird == true 
                balls(a).pos = balls(a).pos; 
                balls(b).pos = balls(b).pos; 
            elseif balls(b).weird ==  true;
                balls(a).pos = nan(1,2);
                balls(a).v = nan(1,2);
            elseif balls(a).weird ==  true;
                balls(b).pos = nan(1,2);
                balls(b).v = nan(1,2);
            end
       end

%%%%%%%Kill radius calculations end here


%%%%%%% Ball collision calculations begin here

% If the distance between the the balls is less than their
% combined radius we may have a collision
if collision == true;
    if norm(balls(b).pos - balls(a).pos) <= balls(b).r + balls(a).r
        un = (balls(b).pos - balls(a).pos) ./ norm(balls(b).pos - balls(a).pos);
        % Project velocity vectors into normal-coordinats
        v_an = dot(un,balls(a).v);
        v_bn = dot(un,balls(b).v);
        if v_an - v_bn > 0 % We only have a collision if the two 
            % balls are headed for each other
            % Rest of the calculations are only needed if we have
            % collision
            ut = [-un(2), un(1)]; % Unit tangent
            % Project velocity vectors into (normal,tangent)-coordinats
            v_at = dot(ut,balls(a).v);
            v_bt = dot(ut,balls(b).v);
            % Find velocities after collision
            v_anp = v_bn.*un;
            v_atp = v_at.*ut;
            v_bnp = v_an.*un;
            v_btp = v_bt.*ut;
            % Add up the components for the resulting velocity
            % Especially: only save the result if we have a
            % collision
            balls(a).v = v_anp + v_atp;
            balls(b).v = v_bnp + v_btp;

        end 
    end
end
    end
%%%%%%%Ball collision calculations end here
 
end
t=t+dt; %After all calculations regarding the particles are done, go forward in time


%%%%%%%Plotting starts here
    if plot_on_off == true; 
        
        % Draw table 
        plot([0, table(1)], [0, 0], 'black'); % Bottom
        hold on
        plot([0, 0], [0, table(2)], 'black'); % Left side
        plot([0, table(1)], [table(2), table(2)], 'black'); % Top
        plot([table(1), table(1)], [0, table(2)], 'black'); % Right side

        if plot_path == false %With this we plot only the current position of our particles
        % we also draw their radius, this makes it easier to
        %see what happens
            % Draw the balls
            for b = 1:length(balls)

            [x,y] = cylinder(balls(b).r); %Make our balls real
            plot(balls(b).pos(1) + x(1,:),balls(b).pos(2) + y(1,:),'color', balls(b).color)
            end

            axis equal;
            axis([-1, table(1)+1, -1, table(2)+1]);
            title(['My Particles at time ',num2str(t,'%6.2f')],'color',[1 1 1]) %Write in white to suite the GUI
            drawnow
            hold off
            %Here we draw the path of our particle, useful if its
            %radius is small, or colisions are disabled
        elseif plot_path == true && mod(counter,plot_per_n)==1; %plot ever n runthrough;
            for i = 1:length(balls)

                hold on
                drawnow
                h = plot(balls(i).pos(1),balls(i).pos(2),'color',balls(i).color,'marker','*');
                title(['My Path at time ',num2str(t,'%6.2f')],'color',[1 1 1]) %Write in white to suite the GUI
            end
        end
    end
%%%%%%%Plotting ends here

counter = counter + 1; %Now increase counter
end

hold off %Hold off my figure so that the next time we run the program we dont plot on top of our
% other figure
end