%% Mass spring damper - 1 DOF
% Simulation and animation of a mass spring damper system with 1 degree of
% freedom subjected to base excitation.
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
h   = 0.4;                      % Height of the block           [m]
a   = 0.8;                      % Width of the block            [m]

% Video
tF      = 15;                   % Final time                    [s]
fR      = 60;                   % Frame rate                    [fps]
dt      = 1/fR;                 % Time resolution               [s]
time    = linspace(0,tF,tF*fR); % Time                          [s]

% Base input
A = 0.1;                        % Amplitude                     [m]
f = 1.0;                        % Frequency                     [Hz]
w = 2*pi*f;                     % Frequency                     [rad/s]
u_vet = A*cos(w*time');         % Displacement                  [m]

%% Simulation

% Transfer function model
G = tf([c k],[m c k]);

% Integration
[y,t,x] = lsim(G,u_vet,time);

%% Animation

color = cool(6); % Colormap

% Mass absolute vertical position (lower center point)
yc = y(:,1) + L0; 

% Base info
baseX = [-0.3 0.3];
baseY = [u_vet u_vet];

figure
% set(gcf,'Position',[50 50 1280 720])  % YouTube: 720p
% set(gcf,'Position',[50 50 854 480])   % YouTube: 480p
set(gcf,'Position',[50 50 640 640])     % Social

hold on ; grid on ; axis equal
set(gca,'ylim',[-0.2 1.35],'xlim',[-0.8 0.8],'xtick',-0.8:0.2:0.8,'ytick',-0.2:0.2:1.3)
set(gca,'FontName','Verdana','FontSize',16)

% Create and open video writer object
v = VideoWriter('mass_spring_damper_1_dof_base.mp4','MPEG-4');
v.Quality   = 100;
v.FrameRate = fR;
open(v);

for i=1:length(time)
    cla
    
    % Mass plot
    fill([-a/2 a/2 a/2 -a/2],[yc(i) yc(i) yc(i)+h yc(i)+h],color(6,:),'LineWidth',2)
    
    % Base position instant
    baseYval = baseY(i,:);
    % Base plot
    plot(baseX,baseYval,'k','linewidth',2)
    
    % Spring
    plotSpring(L0,u_vet,yc,i)
    
    % Damper
    plotDamper(L0,u_vet,yc,i)
  
    % Amplitude markers
    % Find steady state amplitude during second half of the simulation:
    ycSteady = yc(floor(end/2):end);
    plot([-0.6 0.6],[min(ycSteady) min(ycSteady)],'k--','LineWidth',1.5)
    plot([-0.6 0.6],[max(ycSteady) max(ycSteady)],'k--','LineWidth',1.5)

    % Amplitude position input
    plot([-0.6 0.6],[A A],'k--','LineWidth',1.5)
    plot([-0.6 0.6],[-A -A],'k--','LineWidth',1.5)

    title('Mass spring damper - 1 DOF')
    
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
    spring_wid  = 3;        % Spring line width
    
    % Spring length without rods
    L = (yc - yb) - 2*rodPct*L0;
    
    % Spring geometry
    center  = -0.2;         % Lateral position
    wid     = 0.1;          % Width

    % Spring
    springX = [ 
                center                              % Start
                center                              % rod
                center+wid                          % Part 1   
                center-wid                          % Part 2
                center+wid                          % Part 3
                center-wid                          % Part 4
                center+wid                          % Part 5
                center-wid                          % Part 6
                center                              % Part 7
                center                              % rod/End
                ];
    
	springY = [ 
                yb(i)                               % Start
                yb(i)+rodPct*L0                     % rod
                yb(i)+rodPct*L0                     % Part 1 
                yb(i)+rodPct*L0+springPct*L(i)      % Part 2
                yb(i)+rodPct*L0+springPct*L(i)      % Part 3
                yb(i)+rodPct*L0+2*springPct*L(i)    % Part 4
                yb(i)+rodPct*L0+2*springPct*L(i)    % Part 5
                yb(i)+rodPct*L0+3*springPct*L(i)    % Part 6
                yb(i)+rodPct*L0+3*springPct*L(i)    % Part 7
                yb(i)+2*rodPct*L0+3*springPct*L(i)  % rod/End
               ]; 

    % PLOT
    plot(springX,springY,'k','LineWidth',spring_wid)
        
end

function plotDamper(L0,yb,yc,i)

    rodLowerPct = 0.1; % Length lower rod percentage of L0  
    rodUpperPct = 0.6; % Length upper rod percentage of L0 
    cylinderPct = 0.6; % Length cylinder porcentagem de L0
    damper_line_wid  = 3;   % Damper line width
    
    % Damper geometry
    center  = 0.2;              % Lateral position
    wid     = 0.05;             % Width

    % rod attached to base
    rod1X = [center center];
    rod1Y = [yb yb+rodLowerPct*L0];
    
    % Damper base cylinder - rod - base 
    cylinderX = [   
                    center-wid
                    center-wid
                    center+wid
                    center+wid
                ];
                
    cylinderY = [
                    yb(i)+rodLowerPct*L0+cylinderPct*L0
                    yb(i)+rodLowerPct*L0 
                    yb(i)+rodLowerPct*L0 
                    yb(i)+rodLowerPct*L0+cylinderPct*L0
                ];
    
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

    % PLOT
    % rods
    plot(rod1X,rod1Yval,'k','LineWidth',damper_line_wid)
    plot(rod2X,rod2Yval,'k','LineWidth',damper_line_wid)
    % Damper parts
    plot(pistonX,pistonYVal,'k','LineWidth',damper_line_wid)
    plot(cylinderX,cylinderY,'k','LineWidth',damper_line_wid)

end
