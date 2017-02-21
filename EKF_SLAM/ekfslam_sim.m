function data= ekfslam_sim(lm, wp, object, wall, oi, movieName)
%function data= ekfslam_sim(lm, wp)
%
% INPUTS: 
%   lm - set of landmarks
%   wp - set of waypoints
%
% OUTPUTS:
%   data - a data structure containing:
%       data.true: the vehicle 'true'-path (ie, where the vehicle *actually* went)
%       data.path: the vehicle path estimate (ie, where SLAM estimates the vehicle went)
%       data.state(k).x: the SLAM state vector at time k
%       data.state(k).P: the diagonals of the SLAM covariance matrix at time k
%
% NOTES:
%   This program is a SLAM simulator. To use, create a set of landmarks and 
%   vehicle waypoints (ie, waypoints for the desired vehicle path). The program
%   'frontend.m' may be used to create this simulated environment - type
%   'help frontend' for more information.
%       The configuration of the simulator is managed by the script file
%   'configfile.m'. To alter the parameters of the vehicle, sensors, etc
%   adjust this file. There are also several switches that control certain
%   filter options.
%
% Tim Bailey and Juan Nieto 2004.
% Version 2.0
%
% 
% Modified by Martin Stimpfl (2014)
%

%% Initializing


t_start=tic;

clearvars data

format compact
configfile; % ** USE THIS FILE TO CONFIGURE THE EKF-SLAM **
SLEmotionConfig;

%%Settings for the Presentation
% sigmaV= sV; % m/s
% sigmaG= (sG*pi/180); % radians
% sigmaR= sR; % metres
% sigmaB= (sB*pi/180); % radians
% Q= [sigmaV^2 0; 0 sigmaG^2];
% R= [sigmaR^2 0; 0 sigmaB^2];

if parameterSetup.saveMovie
    mkdir(['Movies/' movieName]);
end

% Setup plots
if not(any(strcmpi(parameterSetup.plotSetup, 'off')))
%subplotsettings depending on plotSetup
if any(strcmpi(parameterSetup.plotSetup, 'slender'))
    spSet=struct('size', [1,3], 'GroundtruthMapNr', 1, 'SlamMapNr', 2, 'PaSpaceNr', 3);
    spPos=struct('GroundtruthMap', [0.03 0.04 0.28 0.95],...
                 'SlamMap', [0.35 0.04 0.28 0.95],...
                 'PaSpace', [1280 250 600 600]);
end
if any(strcmpi(parameterSetup.plotSetup, 'full'))
    spSet=struct('size', [2,3], 'GroundtruthMapNr', 1, 'SlamMapNr', 2, 'SecurityMapNr', 3, 'PaSpaceNr', 4, 'PAtimelineNr', [5,6]);
    spPos=struct('GroundtruthMap', [0.04 0.52 0.3 0.43],...
                 'SlamMap', [0.33 0.52 0.3 0.43],...
                 'PaSpace', [130 50 420 420],...
                 'PAtimeline', [0.37 0.05 0.58 0.4],...
                 'SecurityMap', [0.66 0.52 0.3 0.43]);
end

fig1Pos=[0 0.03 1 0.97];


h.fig1=figure(1);
clf(h.fig1)
% Full Screen
% set(h.fig1, 'name', 'SLEmotion Simulator', 'Units', 'Normalized', 'OuterPosition', fig1Pos);

set(h.fig1, 'name', 'SLEmotion Simulator', 'Units', 'Normalized');


h.GroundtruthMap=subplot(spSet.size(1),spSet.size(2),spSet.GroundtruthMapNr, 'parent', h.fig1);
xlabel('x [m]', 'fontsize', 12, 'fontweight', 'bold');
ylabel('y [m]', 'fontsize', 12, 'fontweight', 'bold');
title('Groundtruth', 'fontsize', 14, 'fontweight', 'bold');
axis equal
hold on

if size(wall(1).x,2)==0
    wall(1)=[];
end
%plot walls and lm
wallArea=[0, 0, 0, 0]; %[xmin xmax ymin ymax]
for i=1:size(wall,2)
    if size(wall(i).x,2)==1
        plot(wall(i).x(1,1), wall(i).x(2,1),'o','Linewidth', 2,'Markersize',2, 'color', 'black')
    else
        line(wall(i).x(1,:),wall(i).x(2,:) ,'LineWidth',4, 'Color', 'black');  
    end
    wallArea=[min([wallArea(1) min(wall(i).x(1,:))]), max([wallArea(2) max(wall(i).x(1,:))]), ...
        min([wallArea(3) min(wall(i).x(2,:))]), max([wallArea(4) max(wall(i).x(2,:))])];
end

plot(lm(1,:),lm(2,:),'b*')
plot(wp(1,:),wp(2,:), 'g', wp(1,:),wp(2,:),'g.')


sp1_xlim=[min([min(lm(1,:)) min(wp(1,:)) wallArea(1)])-2 max([max(lm(1,:)) max(wp(1,:)) wallArea(2)])+2];
sp1_ylim=[min([min(lm(2,:)) min(wp(2,:)) wallArea(3)])-2 max([max(lm(2,:)) max(wp(2,:)) wallArea(4)])+2];

sp2_xlim=sp1_xlim;
sp2_ylim=sp1_ylim;

h.SlamMap=subplot(spSet.size(1),spSet.size(2),spSet.SlamMapNr, 'parent', h.fig1);
xlabel('x [m]', 'fontsize', 12, 'fontweight', 'bold');
ylabel('y [m]', 'fontsize', 12, 'fontweight', 'bold');
title('SLAM map', 'fontsize', 14, 'fontweight', 'bold');
axis equal
hold on

%setup animations;
h.xt= patch(0,0,'b','erasemode','xor', 'parent', h.GroundtruthMap); % vehicle true
h.xv= patch(0,0,'r','erasemode','xor', 'parent', h.SlamMap); % vehicle estimate
h.pth= plot(0,0,'k.','markersize',2,'erasemode','background', 'parent', h.SlamMap); % vehicle path estimate
h.obs= plot(0,0,'g','erasemode','xor', 'parent', h.SlamMap); % observations
h.xf= plot(0,0,'b+','erasemode','xor', 'parent', h.SlamMap); % estimated features
h.xw= plot(0,0,'k+','erasemode','xor', 'parent', h.SlamMap); % estimated wall
h.vcov= plot(0,0,'r','erasemode','xor', 'parent', h.SlamMap); % vehicle covariance ellipses
h.fcov= plot(0,0,'b','erasemode','xor', 'parent', h.SlamMap); % feature covariance ellipses
h.wcov= plot(0,0,'k','erasemode','xor', 'parent', h.SlamMap); % feature covariance ellipses
h.timestep=text(0,0,'0','FontSize',5, 'parent', h.SlamMap);
h.fnumber=text(0,0,'0','FontSize',5, 'parent', h.SlamMap);



set(h.GroundtruthMap, 'Units', 'Normalized', 'Position', spPos.GroundtruthMap, 'xlim', sp1_xlim, 'ylim', sp1_ylim);
set(h.SlamMap, 'Units', 'Normalized', 'Position', spPos.SlamMap, 'xlim', sp1_xlim, 'ylim', sp1_ylim);



%set the plots
if SWITCH_EMOTION_ENGINE==1
  
    if any(strcmpi(parameterSetup.plotSetup, {'full', 'slender'}))
        %PA space
        fSize = 12;
        h.spPAspace=subplot(spSet.size(1),spSet.size(2),spSet.PaSpaceNr, 'parent', h.fig1, 'NextPlot', 'add');       
        set(h.spPAspace, 'Units','pixels', 'xlim', [-1 1], 'ylim', [-1 1], 'XTick', [-1 -0.5 0 0.5 1], 'YTick', [-1 -0.5 0 0.5 1]);        
        hline(0)
        vline(0)
        rectangle('Position',[-0.5 -0.5 1 1],'Curvature',1, 'LineStyle', '--')
        textconfig = {'HorizontalAlignment', 'VerticalAlignment','BackgroundColor', ...
            'FontSize'};
        textparas = {'center', 'middle', 'white',fSize};
        text(0.3,0.4,'excited',textconfig, textparas)
        text(0.5,0.15,'happy',textconfig, textparas)
        text(0.3,-0.4,'relaxed',textconfig, textparas)
        text(0.5,-0.15,'contented',textconfig, textparas)
        text(-0.3,0.4,'nervous',textconfig, textparas)
        text(-0.5,0.15,'distressed',textconfig, textparas)
        text(-0.3,-0.4,'depressed',textconfig, textparas)
        text(-0.5,-0.15,'sad',textconfig, textparas)
        xlabel('pleasure', 'fontsize', 12, 'fontweight', 'bold');
        ylabel('arousal', 'fontsize', 12, 'fontweight', 'bold');
        title('PA space', 'fontsize', 14, 'fontweight', 'bold')
        axis equal
        h.PA= plot(0,0, 'b', 'parent', h.spPAspace, 'markerfacecolor', 'b', 'markersize', 10,'marker', 'o'); 
        
        
%         set(h.spPAspace, 'Units','pixels', 'Position', spPos.PaSpace,'xlim', [-1 1], 'ylim', [-1 1], 'XTick', [-1 -0.5 0 0.5 1], 'YTick', [-1 -0.5 0 0.5 1]);
%         %set(h.spPAspace, 'Position', [0.05 0.05 0.7/3 0.4],'xlim', [-1 1], 'ylim', [-1 1]);
%         xlabel('pleasure', 'fontsize', 12, 'fontweight', 'bold');
%         ylabel('arousal', 'fontsize', 12, 'fontweight', 'bold');
%         title('PA space', 'fontsize', 14, 'fontweight', 'bold')
%         axis equal
%         PAimg=imread('PAspace.png');
%         PAimg=flipdim(PAimg,1);
%         imagesc([-1 1], [-1 1], PAimg, 'parent', h.spPAspace);
%         h.PA= plot(0,0, 'b', 'parent', h.spPAspace, 'markerfacecolor', 'b', 'markersize', 10,'marker', 'o'); 
    end
    
    if any(strcmpi(parameterSetup.plotSetup, 'full'))
        %PA timeline
        h.spPAtimeline=subplot(spSet.size(1),spSet.size(2),spSet.PAtimelineNr, 'parent', h.fig1, 'NextPlot', 'add');
        set(h.spPAtimeline, 'Units', 'Normalized', 'Position', spPos.PAtimeline, 'ylim', [-1 1]);
        xlabel('time [s]', 'fontsize', 12, 'fontweight', 'bold');
        ylabel('pleasure/arousal', 'fontsize', 12, 'fontweight', 'bold');
        title('PA timeline', 'fontsize', 14, 'fontweight', 'bold')
        h.PAtimelineP=line(0,0,'parent', h.spPAtimeline, 'color', 'r', 'linewidth', 2);
        h.PAtimelineA=line(0,0,'parent', h.spPAtimeline, 'color', 'b', 'linewidth', 2);
        h.legend=legend([h.PAtimelineP h.PAtimelineA], 'pleasure', 'arousal');
        set(h.legend, 'fontsize', 12)
    end
    
    if any(strcmpi(parameterSetup.plotSetup, 'full'))
        %CorrelationMap
        h.spCorrMap=subplot(spSet.size(1),spSet.size(2),spSet.SecurityMapNr, 'parent', h.fig1, 'NextPlot', 'add');
        set(h.spCorrMap, 'Units', 'Normalized', 'Position', spPos.SecurityMap);
        xlabel('x [m]', 'fontsize', 12, 'fontweight', 'bold');
        ylabel('y [m]', 'fontsize', 12, 'fontweight', 'bold');
        title('Security map', 'fontsize', 14, 'fontweight', 'bold')
        axis equal
        h.CorrMap=surf([0,0;0,0],[0,0;0,0],[0,0;0,0], 'parent', h.spCorrMap);
        h.CorrMapPath=plot3(0,0,1, 'wo', 'MarkerFaceColor', [1 1 1], 'markersize', 1, 'parent', h.spCorrMap);            
    end
end
end

veh= [0 -WHEELBASE -WHEELBASE; 0 -0.5 0.5]; % vehicle animation
plines=[]; % for laser line animation
pcount=0;
observationCount=0;


% Initialise states and other global variables
global XX PX DATA
xtrue= [0;0;0];
XX= [0;0;0];
PX= zeros(3);
DATA= initialise_store(XX,PX,XX); % stored data for off-line


% Initialise other variables and constants
z=[];
idf=[];
dt= DT_CONTROLS;        % change in time between predicts
dtsum= 0;               % change in time since last observation
ftag= 1:size(lm,2);     % identifier for each landmark
da_table= zeros(1,size(lm,2)); % data association table 
iwp= 1;                 % index to first waypoint 
G= 0;                   % initial steer angle
QE= Q; 
RE= R; 
if SWITCH_INFLATE_NOISE, 
    QE= 2*Q; 
    RE= 2*R; 
end % inflate estimated noises (ie, add stabilising noise)
bumpsensor_flag=0;
kindtable=[];
VnMem=[];
GnMem=[];

if SWITCH_SEED_RANDOM, 
    rand('state',SWITCH_SEED_RANDOM), 
    randn('state',SWITCH_SEED_RANDOM), 
end

if SWITCH_PROFILE, profile on -detail builtin, end


time=0;
nrSteps=1;

%% Main loop 
while iwp ~= 0
    
    % Compute true data
    [G,iwp]= compute_steering(xtrue, wp, iwp, AT_WAYPOINT, G, RATEG, MAXG, dt);
    if iwp==0 & NUMBER_LOOPS > 1, 
        iwp=1; 
        NUMBER_LOOPS= NUMBER_LOOPS-1; 
    end % perform loops: if final waypoint reached, go back to first
        
    V=1;
    [Vn,Gn]= add_control_noise(V,G,Q, SWITCH_CONTROL_NOISE);
    VnMem=[VnMem Vn];
    GnMem=[GnMem Gn];
    
    %if collision with wall -> speed=0;
%     if bumpsensor_flag==1
%         V=0;
%     end 

    xtrue= vehicle_model(xtrue, V,G, WHEELBASE,dt);
    
    
    % EKF predict step
    predict (Vn,Gn,QE, WHEELBASE,dt);
    
    % If heading known, observe heading
    observe_heading(xtrue(3), SWITCH_HEADING_KNOWN);
    
    %% Observations
    
    % Incorporate observation, (available every DT_OBSERVE seconds)
    dtsum= dtsum + dt;
        
    
    if dtsum >= DT_OBSERVE
        
        observationCount=observationCount+1;
        dtsum= 0;
               
        if SWITCH_WALLS==1
            %The Bumpsensor is modeled as a circle with radius BUMPSENSOR_RANGE
            t = (0:0.05:1)*2*pi;
            vh_center=[WHEELBASE/2*-cos(xtrue(3))+xtrue(1); WHEELBASE/2*-sin(xtrue(3))+xtrue(2)];
            bumpsensor_x = [sin(t)*BUMPSENSOR_RANGE; cos(t)*BUMPSENSOR_RANGE]+repmat(vh_center,1,21);

            %Collision with Wall?
            for i=1:size(wall,2)
                if ~isempty(polyxpoly(wall(i).x(1,:), wall(i).x(2,:), bumpsensor_x(1,:), bumpsensor_x(2,:)))
                    bumpsensor_flag=1;
                end
            end   
        end
        
        
        % Compute true data
        [z,ftag_visible]= get_observations(xtrue, lm, ftag, MAX_RANGE, wall, SWITCH_WALLS);
        z = add_observation_noise(z,R, SWITCH_SENSOR_NOISE);
    
        % EKF update step
        if SWITCH_ASSOCIATION_KNOWN == 1
            [zf,idf,zn, da_table, associationDist]= data_associate_known(XX,z,ftag_visible, da_table);
        else
            [zf,idf,zn, associationDist]= data_associate(XX,PX,z,RE, GATE_REJECT, GATE_AUGMENT); 
        end

        %put the kind (wall, object ect..) of every new observation in a
        %table. The table is ordered chronologically like in XX
        if ~isempty(zn) kindtable=[kindtable zn(3,:)]; end
        
        %if ~isempty(zf) && ~isempty(RE) && ~isempty(idf)
            if SWITCH_USE_IEKF == 1
                update_iekf(zf,RE,idf, 5);
            else
                update_switch(zf,RE,idf,SWITCH_BATCH_UPDATE);
            end
        %end
            augment(zn,RE);
        

        %% Emotion Engine
        
        if not(any(strcmpi(parameterSetup.plotSetup, 'off')))            
            if SWITCH_EMOTION_ENGINE==1 && observationCount>=1
                SLEmotionEngine(SLEmotion, time, idf, ((length(XX)-3)/2)-size(zn,2)+1:((length(XX)-3)/2), ...
                    VnMem, GnMem, DATA.path, h, movieName);
            end
        else
            h = [];
            movieName = [];
            if SWITCH_EMOTION_ENGINE==1 && observationCount>=1
                SLEmotionEngine(SLEmotion, time, idf, ((length(XX)-3)/2)-size(zn,2)+1:((length(XX)-3)/2), ...
                    VnMem, GnMem, DATA.path, h, movieName);
            end
        end
        
        
        
        
    end
    % Offline data store
    store_data(XX, PX, xtrue);
      
    
	%% Graphics        
    %if vehicle or landmarks are out of the map, resize the map
    if not(any(strcmpi(parameterSetup.plotSetup, 'off')))
	if sp2_xlim(1)>min(XX([1 4:2:end]))
        sp2_xlim(1)=min(XX([1 4:2:end]))-2;
    end
	if sp2_xlim(2)<max(XX([1 4:2:end]))
        sp2_xlim(2)=max(XX(4:2:end))+2;
    end
    if sp2_ylim(1)>min(XX([2 5:2:end]))
        sp2_ylim(1)=min(XX([2 5:2:end]))-2;
    end
	if sp2_ylim(2)<max(XX([2 5:2:end]))
        sp2_ylim(2)=max(XX([2 5:2:end]))+2;
    end    

    set(h.SlamMap, 'xlim', sp2_xlim, 'ylim', sp2_ylim);    
 

    % Plots
    xt= transformtoglobal(veh, xtrue);
    set(h.xt, 'xdata', xt(1,:), 'ydata', xt(2,:))


    if SWITCH_GRAPHICS

        xv= transformtoglobal(veh, XX(1:3));
        pvcov= make_vehicle_covariance_ellipse(XX,PX);
        set(h.xv, 'xdata', xv(1,:), 'ydata', xv(2,:),'parent', h.SlamMap)
        set(h.vcov, 'xdata', pvcov(1,:), 'ydata', pvcov(2,:),'parent', h.SlamMap)     

        pcount= pcount+1;
        if pcount == 120 % plot path infrequently
            pcount=0;
            set(h.pth, 'xdata', DATA.path(1,1:DATA.i), 'ydata', DATA.path(2,1:DATA.i))  
        end            

        if dtsum==0 & ~isempty(z) % plots related to observations
            %find wich feature is wall or object 
            wallPos=find(kindtable==0); %gives the index of wallfeature in XX
            objectPos=find(kindtable~=0);

            set(h.xw, 'xdata', XX(2+wallPos*2), 'ydata', XX(3+wallPos*2))
            set(h.xf, 'xdata', XX(2+objectPos*2), 'ydata', XX(3+objectPos*2))            
            plines= make_laser_lines (z,XX(1:3));
            set(h.obs, 'xdata', plines(1,:), 'ydata', plines(2,:))

            %ocov: position of objectfeature in XX, PX 
            %(position 1,2,3 not relevant but necessary to function make_feature_covariance_ellipses)
            ocov=sort([1, 2, 3, 2+objectPos*2, 3+objectPos*2]);    
            pfcov= make_feature_covariance_ellipses(XX(ocov),PX(ocov,ocov));
            set(h.fcov, 'xdata', pfcov(1,:), 'ydata', pfcov(2,:))  
            %wcov: position of wallfeature in XX, PX            
            wcov=sort([1, 2, 3, 2+wallPos*2, 3+wallPos*2]);    
            pwcov= make_feature_covariance_ellipses(XX(wcov),PX(wcov,wcov));            
            set(h.wcov, 'xdata', pwcov(1,:), 'ydata', pwcov(2,:)) 
        end

    end
    
    drawnow
    
    end
    
    time=time+dt;
    nrSteps=nrSteps+1;
end % end of main loop



%% Postprocessing
if SWITCH_PROFILE, profile report, end

data = finalise_data(DATA, SLEmotion);
if not(any(strcmpi(parameterSetup.plotSetup, 'off')))
set(h.pth, 'xdata', data.path(1,:), 'ydata', data.path(2,:))    
end

t_end=toc(t_start)

clear global DATA 
clear global XX 
clear global PX


function p= make_laser_lines (rb,xv)
% compute set of line segments for laser range-bearing measurements
if isempty(rb), p=[]; return, end
len= size(rb,2);
lnes(1,:)= zeros(1,len)+ xv(1);
lnes(2,:)= zeros(1,len)+ xv(2);
lnes(3:4,:)= transformtoglobal([rb(1,:).*cos(rb(2,:)); rb(1,:).*sin(rb(2,:))], xv);
p= line_plot_conversion (lnes);

function p= make_vehicle_covariance_ellipse(x,P)
% compute ellipses for plotting vehicle covariances
N= 10;
inc= 2*pi/N;
phi= 0:inc:2*pi;
circ= 2*[cos(phi); sin(phi)];

p= make_ellipse(x(1:2), P(1:2,1:2), circ);

function p= make_feature_covariance_ellipses(x,P)
% compute ellipses for plotting feature covariances
N= 10;
inc= 2*pi/N;
phi= 0:inc:2*pi;
circ= 2*[cos(phi); sin(phi)];

lenx= length(x);
lenf= (lenx-3)/2;
p= zeros (2, lenf*(N+2));

ctr= 1;
for i=1:lenf
    ii= ctr:(ctr+N+1);
    jj= 2+2*i; jj= jj:jj+1;
    
    p(:,ii)= make_ellipse(x(jj), P(jj,jj), circ);
    ctr= ctr+N+2;
end

function p= make_ellipse(x,P,circ)
% make a single 2-D ellipse 
r= sqrtm_2by2(P);
a= r*circ;
p(2,:)= [a(2,:)+x(2) NaN];
p(1,:)= [a(1,:)+x(1) NaN];

function data= initialise_store(x,P, xtrue)
% offline storage initialisation
data.i=1;
data.path= x;
data.true= xtrue;
data.state(1).x= x;
data.state(1).P= P;
%data.state(1).P= diag(P);


function store_data(x, P, xtrue)
% add current data to offline storage
global DATA
CHUNK= 5000;
len= size(DATA.path,2);
if DATA.i == len % grow array exponentially to amortise reallocation
    if len < CHUNK, len= CHUNK; end
    DATA.path= [DATA.path zeros(3,len)];
    DATA.true= [DATA.true zeros(3,len)];
end
i= DATA.i + 1;
DATA.i= i;
DATA.path(:,i)= x(1:3);
DATA.true(:,i)= xtrue;
%DATA.state(i).x= x;
DATA.state(i).P= P;
%DATA.state(i).P= diag(P);


function data = finalise_data(data, SLEmotion)
% offline storage finalisation
data.path= data.path(:,1:data.i);
data.true= data.true(:,1:data.i);
data.SLEmotion=SLEmotion;







