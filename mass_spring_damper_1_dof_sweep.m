%% Mass spring damper - 1 DOF - Frequency sweep
% Simulation and animation of a mass spring damper system with 1 degree of
% freedom subjected to a base excitation frequency sweep.
%
%%

clear ;  close all ; clc

%% Parameters

% System
m = 1000;                       % Mass                          [kg]
k = 48000;                      % Spring constant               [N/m]
c = 4000;                       % Damping constant              [N.s/m]

% Animation model
L0  = 0.7;                      % Spring relaxed length         [m]
h   = 0.3;                      % Height of the block           [m]
a   = 1;                        % Width of the block            [m]

% Video
tF      = 60;                   % Final time                    [s]
fR      = 60;                   % Frame rate                    [fps]
dt      = 1/fR;                 % Time resolution               [s]
time    = linspace(0,tF,tF*fR); % Time                          [s]

% Base input
freq_ini = 0.1;                 % Initial frequency             [Hz]
freq_end = 3;                   % Final frequency               [Hz]
f = (freq_end-freq_ini)/tF*time + freq_ini;    % Frequency      [Hz]
w = 2*pi*f;                     % Frequency                     [rad/s]
A = 0.1;                        % Amplitude                     [m]
% Displacement [m]
u_vet   = A*sin(2*pi*((freq_end-freq_ini)/tF*time + freq_ini).*time)';     

%% Simulation

% Transfer function model
G = tf([c k],[m c k]);

% Integration
[y,t,x] = lsim(G,u_vet,time);

%% Animation

% Mass absolute vertical position (lower center point)
yc = y(:,1) + L0; 

% Base info
baseX = [-0.8 0.8];
baseY = [u_vet u_vet];

figure
set(gcf,'Position',[50 50 1280 720]) % 720p
% set(gcf,'Position',[50 50 854 480]) % 480p

% Create and open video writer object
v = VideoWriter('mass_spring_damper_1_dof_sweep.avi');
v.Quality   = 100;
v.FrameRate = fR;
open(v);

for i=1:length(time)
    cla
    hold on ; grid on ; axis equal
    set(gca,'ylim',[-0.2 1.3],'xlim',[-1 1],'xtick',-1:0.1:1,'ytick',-0.2:0.1:1.3)
    
    % Mass plot
    fill([-a/2 a/2 a/2 -a/2],[yc(i) yc(i) yc(i)+h yc(i)+h],'r')
    
    % Base position instant
    baseYval = baseY(i,:);
    % Base plot
    plot(baseX,baseYval,'k','linewidth',2)
    
    % Spring
    plotSpring(L0,u_vet,yc,i)
    
    % Damper
    plotDamper(L0,u_vet,yc,i)
  
    % Initial position
    plot([-0.8 0.8],[L0 L0],'k--')
    
    % Amplitude position input
    plot([-0.8 0.8],[A A],'k--')
    plot([-0.8 0.8],[-A -A],'k--')

    title(strcat('Mass spring damper: m=',num2str(m),' kg ; k=',num2str(k),' N/m ; c=',num2str(c),' N.s/m'))
    
    xlabel('x [m]')
    ylabel('y [m]')
    
    frame = getframe(gcf);
    writeVideo(v,frame);
    
end

close(v);

%% Auxiliary functions

function plotSpring(L0,yb,yc,i)
    % L0 - Spring relaxed length
    % yb - Base position
    % yc - Mass position

    rodPct      = 0.11;     % Length rod percentage of L0 
    springPct   = 1/3;      % Spring pitch percentage of L0 

    % Spring length without rods
    L = (yc - yb) - 2*rodPct*L0;
    
    % Spring geometry
    center  = -0.2;         % Lateral position
    wid     = 0.1;          % Width

    % rod attached to base
    rod1X = [center center];
    rod1Y = [yb yb+rodPct*L0];
    % rod attached to mass
    rod2X = [center center];
    rod2Y = [yc yc-rodPct*L0];

    % Spring parts
    % Part 1
    spring1X = [center center+wid];
    spring1Y = [yb+rodPct*L0 yb+rodPct*L0];
    % Part 2
    spring2X = [center-wid center+wid];
    spring2Y = [yb+rodPct*L0+springPct*L yb+rodPct*L0];
    % Part 3
    spring3X = [center-wid center+wid];
    spring3Y = [yb+rodPct*L0+1*springPct*L yb+rodPct*L0+1*springPct*L];
    % Part 4
    spring4X = [center-wid center+wid];
    spring4Y = [yb+rodPct*L0+2*springPct*L yb+rodPct*L0+1*springPct*L];
    % Part 5
    spring5X = [center-wid center+wid];
    spring5Y = [yb+rodPct*L0+2*springPct*L yb+rodPct*L0+2*springPct*L];
    % Part 6
    spring6X = [center-wid center+wid];
    spring6Y = [yb+rodPct*L0+3*springPct*L yb+rodPct*L0+2*springPct*L];
    % Part 7
    spring7X = [center-wid center];
    spring7Y = [yb+rodPct*L0+3*springPct*L yb+rodPct*L0+3*springPct*L];
    
    % Iteration values
    % rods
    rod1Yval = rod1Y(i,:);
    rod2Yval = rod2Y(i,:);
    % Spring parts
    spring1Yval = spring1Y(i,:);
    spring2Yval = spring2Y(i,:);
    spring3Yval = spring3Y(i,:);
    spring4Yval = spring4Y(i,:);
    spring5Yval = spring5Y(i,:);
    spring6Yval = spring6Y(i,:);
    spring7Yval = spring7Y(i,:);

    % PLOT
    % rods
    plot(rod1X,rod1Yval,'k')
    plot(rod2X,rod2Yval,'k')
    % Spring parts
    plot(spring1X,spring1Yval,'k')
    plot(spring2X,spring2Yval,'k')
    plot(spring3X,spring3Yval,'k')
    plot(spring4X,spring4Yval,'k')
    plot(spring5X,spring5Yval,'k')
    plot(spring6X,spring6Yval,'k')
    plot(spring7X,spring7Yval,'k')

end

function plotDamper(L0,yb,yc,i)

    rodLowerPct = 0.1; % Length lower rod percentage of L0  
    rodUpperPct = 0.6; % Length upper rod percentage of L0 
    cylinderPct = 0.6; % Length cylinder porcentagem de L0

    % Damper geometry
    center  = 0.2;              % Lateral position
    wid     = 0.05;             % Width

    % rod attached to base
    rod1X = [center center];
    rod1Y = [yb yb+rodLowerPct*L0];
    % Damper base cylinder - rod - base 
    basecylinderX = [center-wid center+wid];
    basecylinderY = [yb+rodLowerPct*L0 yb+rodLowerPct*L0];
    % Damper left wall cylinder
    wall_1CylinderX = [center-wid center-wid];
    wall_1CylinderY = [yb+rodLowerPct*L0 yb+rodLowerPct*L0+cylinderPct*L0];
    % Damper right wall cylinder
    wall_2CylinderX = [center+wid center+wid];
    wall_2CylinderY = [yb+rodLowerPct*L0 yb+rodLowerPct*L0+cylinderPct*L0];
    
    % rod attached to mass
    rod2X = [center center];
    rod2Y = [yc yc-rodUpperPct*L0];
    % Piston inside cylinder
    pistonX = [center-0.8*wid center+0.8*wid];
    pistonY = [yc-rodUpperPct*L0 yc-rodUpperPct*L0];
    
    % Iteration values
    rod1Yval = rod1Y(i,:);
    rod2Yval = rod2Y(i,:);
    pistonYVal = pistonY(i,:);
    baseCylinderYval = basecylinderY(i,:);
    wall_1CylinderYval = wall_1CylinderY(i,:);
    wall_2CylinderYval = wall_2CylinderY(i,:);

    % PLOT
    % rods
    plot(rod1X,rod1Yval,'k')
    plot(rod2X,rod2Yval,'k')
    % Damper parts
    plot(pistonX,pistonYVal,'k')
    plot(basecylinderX,baseCylinderYval,'k')
    plot(wall_1CylinderX,wall_1CylinderYval,'k')
    plot(wall_2CylinderX,wall_2CylinderYval,'k')

end