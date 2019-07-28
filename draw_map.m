% This function displays the map landmark as black circles and returns the
% figure
function sim_fig = draw_map()

global map

margin = 5;
xmin = min(map(1, :)) - margin;
xmax = max(map(1, :)) + margin;
ymin = min(map(2, :)) - margin;
ymax = max(map(2, :)) + margin;

sim_fig = figure(1);
clf(sim_fig);
figure(sim_fig);
plot(map(1, :), map(2, :), 'ko')
hold on;
axis([xmin xmax ymin ymax])
title('EKF Localization');


