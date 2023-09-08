
clc;
clear;
clf;

hold on;

% State probabilities
state_prob = [0,1,0,0,0,0];

% State change probabilities
state_change_prob = [0,  0, 0;          %U_
                    0,  0.4, 0;         %UD
                    0.2, 0.1, 0.2;      %DU
                    0,   0.3, 0;        %DT
                    0.2, 0.1, 0.2;      %TD
                    0,   0,   0.2;      %TE
                    1,   1,   0.1;      %ET
                    0,   0,   0.3;];    %EH


% Waypoints (2 options)

waypoints =  [14, 4.3;
        17, 10.5;
        20, 15.56;
        31, 20.6;
        35, 25.56;
        41, 21.4;
        37.4, 12.35;
        29.2, 4.75];

waypoints = [15, 4.3;
            16, 10.5;
            17, 15.56;
            18, 20.6;
            26, 20;
            42, 22;
            40, 15;
            45, 14];


all_points=[];

% Divide waypoints and add to array
for index = 1:length(waypoints)-1
    all_points = [all_points, add_points_and_plot(waypoints(index,:), waypoints(index + 1,:), 5);];
end

area_points = [20, 18 ; 42, 15 ; 37, 28];

fprintf('Enter area distances: ')
prompt = "Weapon: ";
weapon_distance = input(prompt);

prompt = "Sensor: ";
sensor_distance = input(prompt);

plot_circles(area_points,weapon_distance,sensor_distance);

% Define area point by point
for aircraft_point = 1:length(all_points)
    which_side = 'outside';
    for area_point = 1:length(area_points)
        
        distance = check_distance(all_points(:,aircraft_point), ...
                        area_points(area_point,:));
        if distance < weapon_distance
            which_side = 'weapon';
        elseif distance < sensor_distance && ~strcmp(which_side,'weapon')
            which_side = 'sensor';
        elseif ~strcmp(which_side,'weapon') && ~strcmp(which_side,'sensor')
            which_side = 'outside';        
        end
  
    end
    
    % Calculate according to side
    if strcmp(which_side,'weapon')
            state_prob = calculate_state_prob(state_prob,state_change_prob(:,3));
            
    elseif strcmp(which_side,'sensor')
            state_prob = calculate_state_prob(state_prob,state_change_prob(:,2));
    else
            state_prob = calculate_state_prob(state_prob,state_change_prob(:,1));
    end

    display(state_prob)
end

% Result
sprintf('Survivability: %% %.4g' , (1-state_prob(end))*100)
axis equal;




function new_points = add_points_and_plot(wpA, wpB, new_points_count)

    % Internet
    dx = (wpB(1) - wpA(1)) / (new_points_count + 1);
    dy = (wpB(2) - wpA(2)) / (new_points_count + 1);


    new_points = [(wpA(1) + dx) : dx : (wpB(1) - dx); 
                  (wpA(2) + dy) : dy : (wpB(2) - dy)];

    new_points = [wpA(1), new_points(1,:), wpB(1); 
                  wpA(2), new_points(2,:), wpB(2)];

    plot(new_points(1,:), new_points(2,:), 'ro-'); 
    hold on;
    plot([wpA(1), wpB(1)], [wpA(2), wpB(2)], 'bo');

    xlabel('X');
    ylabel('Y');
    grid on;
    
end

function plot_circles(area_points,weapon_distance,sensor_distance)
    for index = 1:length(area_points)
        viscircles([area_points(index, :)], weapon_distance,'EdgeColor', 'red')
        viscircles([area_points(index, :)], sensor_distance,'EdgeColor', 'blue')
    end
end

function distance = check_distance(p1,p2)
    distance = sqrt((p2(1) - p1(1))^2 + (p2(2) - p1(2))^2);
end

function new_state_prob = calculate_state_prob(state_prob,state_change_prob)
    
    temp_state_prob = zeros(size(state_prob));
    

    change_index = 1;

    for index = 2:length(state_prob)-1
        
        change_rate = state_change_prob(change_index,:) * state_prob(index);
        temp_state_prob(index-1) = temp_state_prob(index-1) + change_rate;
        temp_state_prob(index) = temp_state_prob(index) - change_rate;

        change_rate = state_change_prob(change_index+1,:) * state_prob(index);
        temp_state_prob(index+1) = temp_state_prob(index+1) + change_rate;
        temp_state_prob(index) = temp_state_prob(index) - change_rate;
        %display(state_prob);
        change_index = change_index + 2;
    end
    new_state_prob = state_prob + temp_state_prob;
    
end


