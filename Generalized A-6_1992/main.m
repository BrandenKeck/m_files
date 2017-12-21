% Putnam Problem A6 (1992) states that:
%       "Four points are chosen at random on the surface of a sphere.
%        What is the probability that the center of the sphere lies inside the tetrahedron whose vertices are at the four points?
%        (It is understood that each point is independently chosen relative to a uniform distribution on the sphere.)"
%
% The following script was created by Branden Keck to generalize this
% concept to a polyhedron with "n" points and "n" sides
%       Program is Stochastic and calculates a running probability over a
%       user-specified number of attempts to create a polyhedron with the
%       center of the unit circle within
%       1.  Choose "n" - the size of the polyhedron
%       2.  Choose total number of cycles
%       3.  Choose the number of cycles before probability is recalculated
%       and displayed to the user
%      

function main
    % Allow the user to select degree of the obj
    k = input('The 3-D object should have how many points: ');
    
    % Simple Error Checking...
    if(floor(k)~=k || k<4)
        error('Number of points must be an integer greater than or equal to 4');
    end

    % Allow the user to select the number of iterations
    iter = input('How many cycles do you want to run: ');
    
    % Simple Error Checking...
    if(floor(iter)~=iter)
        error('Only integer arguments are acceptable');
    end
    
    % Allow the user to select how often output is displayed
    ness = input('How often do you want to print:  ');
    
    % Simple Error Checking...
    if(ness>=iter)
        error('Cannot print less frequently than the total number of iterations');
    end
    if(floor(ness)~= ness)
       error('Only integer arguments are acceptable');
    end

    % Create the figure and "global" variables
    figure('NumberTitle', 'off','units','normalized','outerposition',[0 0 1 1]);
    hold on;
    t = 0; f = 0;
    
    % Begin iterations
    i = 1;
    while(i<iter)
        % Create random tetrahedron points
        for(pts=1:k)
            A(pts,:) = generatePoint();
        end
        b = linspace(1, length(A), length(A));
        C = combnk(b, 3);
        quads = combnk(b, 4);

        % Check if (0,0,0) is in the tetrahedron
        % Update true/false counters
        q = isValid(A, quads);
        if(q)
            t = t + 1;
        else
            f = f + 1;
        end
        
        % Calculate percentage of times the origin was inside the
        % polyhedron
        % Update cycle number and overall percentage
        percent = (t/(t+f));
        x(i) = i;
        y(i) = percent;
        
        % Set next iteration number
        i = i + 1;
        
        % Print to figure if cycle is of number specified by the user
        if(mod(i,ness)==0)
            redraw(A,C,x,y,i,ness, iter);
            pause;
        end
    end
end


% Function that updates the figure
function redraw(A, C, x, y, i, ness, iter)
    %clear figure
    clf;
    
    %Set title of total plot
    if(i==iter)
        message = sprintf('Simulation Ended\n\n');
    else
        message = sprintf('Simulation Running... Press Any Key to Step Forward\n\n');
    end
    annotation('textbox', [0 0.9 1 0.1], ...
    'String', message, ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center',...
    'FontSize', 20);
    
    %subplot with the graphical representation of the tetrahedron
    subplot(1,2,1);
    
    %visualize the unit sphere
    [sph_x, sph_y, sph_z] = sphere;
    mesh(sph_x,sph_y,sph_z, 'edgecolor', 'b');
    hold('on');

    % Visualization of the polyhedron
    % All three point combinations are filled-in
    % All points and the origin are graphed
    plot3(0,0,0, 'go', 'linewidth',8);
    for pt=1:length(A)
        plot3(A(pt,1),A(pt,2),A(pt,3), 'ro', 'linewidth',8);
    end
    for com=1:length(C)
        fill3([A(C(com,1),1),A(C(com,2),1),A(C(com,3),1)],...
            [A(C(com,1),2),A(C(com,2),2),A(C(com,3),2)],...
            [A(C(com,1),3),A(C(com,2),3),A(C(com,3),3)],'r'); 
    end
    alpha(.4);
    
    title('Current Configuration (Click & Drag to Rotate)',...
        'FontSize', 15);
    
    % Subplot containing statistics
    % Grave of average probability per cycle
    subplot(1,2,2);
    
    plot(x,y)
    xlim([(i-ness),i]);
    text((i - ness/2), y(length(y)), "Overall Average :" + num2str(mean(y)),...
        'BackgroundColor', 'white', 'FontSize', 10);
    xlabel("Cycle",...
        'FontSize', 10);
    ylabel("Probability polyhedron contains origin",...
        'FontSize', 10);
    title("Statistics (Last Set of Cycles)",...
        'FontSize', 15);

    % Only the first subplot should be rotatable
    % Update the drawing
    rotate3d(subplot(1,2,1), 'on');
    drawnow;
end


% Function to determine if the point is within a tetrahedron
% See http://steve.hollasch.net/cgindex/geometry/ptintet.html
% For a polyhedron composed of "n" vertices, "n-1" tetrahedrons are tested
function bool = isValid(A, q)
    [n, m] = size(q);

    bool = false;
    for j = 1:n

        a = A(q(j,1),:);
        b = A(q(j,2),:);
        c = A(q(j,3),:);
        d = A(q(j,4),:);
        
        D0 = det([a(1) a(2) a(3) 1; b(1) b(2) b(3) 1; c(1) c(2) c(3) 1; d(1) d(2) d(3) 1]);
        D1 = det([0 0 0 1; b(1) b(2) b(3) 1; c(1) c(2) c(3) 1; d(1) d(2) d(3) 1]);
        D2 = det([a(1) a(2) a(3) 1; 0 0 0 1; c(1) c(2) c(3) 1; d(1) d(2) d(3) 1]);
        D3 = det([a(1) a(2) a(3) 1; b(1) b(2) b(3) 1; 0 0 0 1; d(1) d(2) d(3) 1]);
        D4 = det([a(1) a(2) a(3) 1; b(1) b(2) b(3) 1; c(1) c(2) c(3) 1; 0 0 0 1]);

        if(D0>0 && D1>0 && D2>0 && D3>0 && D4>0)
            bool = true;
            return
        elseif(D0<0 && D1<0 && D2<0 && D3<0 && D4<0)
            bool = true;
            return
        end
    end
end


% function to generate random points
function p = generatePoint()
    % Repeat until point is valid in real space
    cont = true;
    while(cont)
        x = rand;
        y = rand;
        z = sqrt(1-x^2-y^2);
        if(isreal(z))  cont = false;  end
    end
    
    % Decide if a coordinate is negative or positive
    if(rand>0.5)  x = -x;  end
    if(rand>0.5)  y = -y;  end
    if(rand>0.5)  z = -z;  end
    
    p = [x,y,z];
end