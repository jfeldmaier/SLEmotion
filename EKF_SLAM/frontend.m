% (c) Tim Bailey 2004.
% 
% Modified by Martin Stimpfl (2014)
%
function varargout = frontend(varargin)
%EKF-SLAM environment-making GUI
%
% This program permits the graphical creation and manipulation 
% of an environment of point landmarks, and the specification of
% vehicle path waypoints therein.
%
% USAGE: type 'frontend' to start.
%   1. Click on the desired operation: <enter>, <move>, or <delete>.
%   2. Click on the type: <waypoint> or <landmark> to commence the 
%   operation.
%   3. If entering new landmarks or waypoints, click with the left
%   mouse button to add new points. Click the right mouse button, or
%   hit <enter> key to finish.
%   4. To move or delete a point, just click near the desired point.
%   5. Saving maps and loading previous maps is accomplished via the
%   <save> and <load> buttons, respectively.
%
% Tim Bailey and Juan Nieto 2004.

% FRONTEND Application M-file for frontend.fig
%    FIG = FRONTEND launch frontend GUI.
%    FRONTEND('callback_name', ...) invoke the named callback.
global WAYPOINTS FH OBJECT WALL OI

if nargin == 0  % LAUNCH GUI

    %initialisation
    WAYPOINTS= [0;0];
    OBJECT=struct('x',[], 'h',[], 'kind', []);
    WALL=struct('x',[], 'h',[]);
    
    
    % open figure
	fig = openfig(mfilename,'new');
    hh= get(fig, 'children');
    set(hh(3), 'value', 1)
    
    
    hold on
    FH.hl= plot(0,0,'g*'); plot(0,0,'w*')
    FH.hw= plot(0,0,0,0,'ro');
    plotwaypoints(WAYPOINTS);

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));
    set(fig,'name', 'SLAM Map-Making GUI')

 
       
    % Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

	if nargout > 0
		varargout{1} = fig;
    end
 
    %define objectindices   
    OI={'object'; 'tv'; 'pc'; 'furniture'; 'chair'; 'table'; 'food'};
    set(handles.object_popup, 'string', OI)
    
    set(handles.enter_checkbox, 'value', 1)
    set(handles.move_checkbox, 'value', 0)
    set(handles.delete_checkbox, 'value', 0)
    
    %axis equal

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
	catch
		disp(lasterr);
	end

end


% --------------------------------------------------------------------
function varargout = waypoint_checkbox_Callback(h, eventdata, handles, varargin)
global WAYPOINTS
set(handles.wall_checkbox, 'value', 0)
WAYPOINTS= perform_task(WAYPOINTS, handles.waypoint_checkbox, handles);
plotwaypoints(WAYPOINTS);

% --------------------------------------------------------------------
function varargout = wall_checkbox_Callback(h, eventdata, handles, varargin)
global WALL
set(handles.waypoint_checkbox, 'value', 0)
if isempty(WALL(1).x) iWall=1; else iWall=size(WALL,2)+1; end
WALL(iWall).x= perform_task([], handles.wall_checkbox, handles);


% --------------------------------------------------------------------
function varargout = object_popup_Callback(h, eventdata, handles, varargin)
global OBJECT
set(handles.waypoint_checkbox, 'value', 0)
set(handles.wall_checkbox, 'value', 0)
if isempty(OBJECT(1).x) iObject=1; else iObject=size(OBJECT,2)+1; end
OBJECT(iObject).x= perform_task([], handles.object_popup, handles);


% --------------------------------------------------------------------
function varargout = enter_checkbox_Callback(h, eventdata, handles, varargin)
set(handles.enter_checkbox, 'value', 1)
set(handles.move_checkbox, 'value', 0)
set(handles.delete_checkbox, 'value', 0)

% --------------------------------------------------------------------
function varargout = move_checkbox_Callback(h, eventdata, handles, varargin)
set(handles.enter_checkbox, 'value', 0)
set(handles.move_checkbox, 'value', 1)
set(handles.delete_checkbox, 'value', 0)

% --------------------------------------------------------------------
function varargout = delete_checkbox_Callback(h, eventdata, handles, varargin)
set(handles.enter_checkbox, 'value', 0)
set(handles.move_checkbox, 'value', 0)
set(handles.delete_checkbox, 'value', 1)

% --------------------------------------------------------------------
function varargout = load_button_Callback(h, eventdata, handles, varargin)
global WAYPOINTS OBJECT WALL
seed = {'*.mat','MAT-files (*.mat)'};
[fn,pn] = uigetfile(seed, 'Load landmarks and waypoints');
if fn==0, return, end

fnpn = strrep(fullfile(pn,fn), '''', '''''');
load(fnpn)
WAYPOINTS= wp; OBJECT=object; WALL=wall; 
plotwaypoints(WAYPOINTS);
for i=1:size(OBJECT,2)
    plotobjects(OBJECT(i).x, OBJECT(i).kind);
end
for i=1:size(WALL,2)
    plotwalls(WALL(i).x);
end
% --------------------------------------------------------------------
function varargout = save_button_Callback(h, eventdata, handles, varargin)
global WAYPOINTS OBJECT WALL OI

kindlist=[];
lmDensity=0.05; %lm per meter wall

wp= WAYPOINTS; lm=[OBJECT(:).x]; object=OBJECT; wall=WALL; oi=OI;


iKind=1;

for i=1:size(OBJECT,2)
    for ii=iKind:iKind+size(OBJECT(i).x,2)-1 
        kindlist(ii)=OBJECT(i).kind;
    end
    iKind=ii+1;
end

if isempty(iKind) iKind=1; end
% 
% for i=1:size(WALL,2)
%     if size(WALL(i).x)==1
%         lm=[lm WALL(i).x];
%     else
%         for ii=1:size(WALL(i).x,2)-1
%             rel(1:2)=[WALL(i).x(1,ii) WALL(i).x(2,ii)];
%             rel(3:4)=[WALL(i).x(1,ii+1)-WALL(i).x(1,ii) WALL(i).x(2,ii+1)-WALL(i).x(2,ii)];
%             par1=parallelLine(rel,.1);
%             par2=parallelLine(rel,-.1);
%             abs1=[par1(1) par1(1)+par1(3); par1(2) par1(2)+par1(4)];
%             abs2=[par2(1) par2(1)+par2(3); par2(2) par2(2)+par2(4)];
%             
%                %alle ecken zu lm
%             if ii==1 lm=[lm abs1 abs2];
%             else lm=[lm abs1(1:2,2) abs2(1:2,2)]; end
%             
%             r =sqrt(par1(3)^2+par1(4)^2).*rand(ceil(sqrt(par1(3)^2+par1(4)^2)*lmDensity),1);
%             pL=pointOnLine(par1, r);
%             r =sqrt(par2(3)^2+par2(4)^2).*rand(ceil(sqrt(par2(3)^2+par2(4)^2)*lmDensity),1);
%             pL=[pL; pointOnLine(par2, r)];
%             
%             %hier Landmarks einzeichen
%            lm=[lm pL'];
%            
%             line(abs1(1,:), abs1(2,:));
%             line(abs2(1,:), abs2(2,:));
%             plot(pL(:,1), pL(:,2), 'g+')
% 
%         end
%     end
% end

WALL(1)=[];

kindlist(iKind:size(lm,2))=0;
lm=[lm;kindlist];

plot(lm(1,:),lm(2,:),'g*');

seed = {'*.mat','MAT-files (*.mat)'};
[fn,pn] = uiputfile(seed, 'Save landmarks and waypoints');
if fn==0, return, end
fnpn = strrep(fullfile(pn,fn), '''', '''''');
save(fnpn, 'wp', 'lm', 'object', 'wall', 'oi');

% --------------------------------------------------------------------
function plotwaypoints(x)
global FH
set(FH.hw(1), 'xdata', x(1,:), 'ydata', x(2,:))
set(FH.hw(2), 'xdata', x(1,:), 'ydata', x(2,:))

% --------------------------------------------------------------------
function plotobjects(x, val)
global OI

plot(x(1,:), x(2,:),'rd');  
text(x(1,:)+0.2,x(2,:),OI(val), 'FontSize', 7, 'Color', 'black');

% --------------------------------------------------------------------
function plotwalls(x)

if size(x,2)==1
    plot(x(1,1), x(2,1),'o','Linewidth', 2,'Markersize',2, 'color', 'black')
else
    line(x(1,:),x(2,:) ,'LineWidth',4, 'Color', 'black');  
end


% --------------------------------------------------------------------
function i= find_nearest(x)
xp= ginput(1);
d2= (x(1,:)-xp(1)).^2 + (x(2,:)-xp(2)).^2;
i= find(d2 == min(d2));
i= i(1);

% --------------------------------------------------------------------
function x= perform_task(x, h, handles)    
global OBJECT KIND

if get(h, 'value') == 1 || h == handles.object_popup
    zoom off
    
    if get(handles.enter_checkbox, 'value') == 1 % enter points
        [xn,yn,bn]= ginput(1);
        if h == handles.waypoint_checkbox
            while ~isempty(xn) && bn == 1
                x= [x [xn;yn]];
                plotwaypoints(x); 
                [xn,yn,bn]= ginput(1);
            end
            set(h, 'value', 0);
        elseif h == handles.wall_checkbox
            while ~isempty(xn) && bn == 1
                x= [x [round(xn);round(yn)]];
                plotwalls(x);
                [xn,yn,bn]= ginput(1);                
            end      
            set(h, 'value', 0);
        elseif h == handles.object_popup
            val=get(handles.object_popup,'Value');  
            if isempty(OBJECT(1).x)
                iObject=1;
            else
                iObject=size(OBJECT, 2)+1;          
            end
            OBJECT(iObject).kind=val;
            while ~isempty(xn) && bn == 1
                x= [x [xn;yn]];
                plotobjects([xn;yn], val);
                [xn,yn,bn]= ginput(1);                
            end         
        end            
                   
    else
        i= find_nearest(x);        
        if get(handles.delete_checkbox, 'value') == 1 % delete nearest point
            x= [x(:,1:i-1) x(:,i+1:end)];
            
        elseif get(handles.move_checkbox, 'value') == 1 % move nearest point
            xt= x(:,i);
            plot(xt(1), xt(2),'kx', 'markersize',10)
            x(:,i)= ginput(1)';
            plot(xt(1), xt(2),'wx', 'markersize',10)
        end  
        set(h, 'value', 0);
    end
 
end
