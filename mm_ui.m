function mm_ui(action, varargin)
%- Interface functions for ploting MLM or SVD analysis
%================================================================================
%-  Copyright (C) 1997-2002 CEA
%-  This software and supporting documentation were developed by
%-       CEA/DSV/SHFJ/UNAF
%-       4 place du General Leclerc
%-       91401 Orsay cedex
%-       France
%================================================================================


	
	if nargin == 0
		action	= 'init';
	end
	
	switch lower(action)
		case 'init'
			H	= ui_init; 
		case 'plot'
			flag	= ui_plot(varargin{1});
		case 'load'
			flag 	= ui_load(varargin{1});
		case 'flip'
			flag	= ui_flip(varargin{1});
		case 'close'
			flag	= ui_close(varargin{1});
		case 'zoom' 
			flag	= ui_zoom(varargin{1});
		case 'initplot'
			fig	= ui_initPlot(varargin{1},varargin{2});
		case 'plotspec'
			fig	= ui_plotspec(varargin{1},varargin{2});
		
		otherwise,
			warning('Unknown action string')
end;



%====================================================================
%- init function set window and callbacks.

function fig=ui_init

helpon={...
'MM Visualization'
'__________________________________________'
'To start the visualisation component of the toolbox, press on "Load"'
'Load the SVD.mat or the MLM.mat file depending on the analysis'
'performed.'
''
'The display will show the spectrum of the singular values'
'of the analysis,a temporal component and a spatial component'
'when an eigen image number is chosen.'
''
'The MM info button displays the parameters of the analysis'
'and statistics'
''
'Note that several eigen image numbers can be entered at once.'
'You can zoom on the time series with the min and max values'
'You can flip the time courses and the images by entering -1'
''
'For MLM, clicking on the result table will show the contrast'
'corresponding to the time course and eigen-images.'};

mw.flag=0;

mw.mw = figure('Color',[0.8 0.8 0.8], ...
	'Name','MultiVariate Tool','NumberTitle','off', ...
	'unit','normal',...
	'IntegerHandle','off',...
	'MenuBar','none', ...
	'Position',[0.015 0.52 0.40 0.40], ...
	'Tag','main_ui', ...
	'ToolBar','none',...
	'resize','on',...
	'CloseRequestFcn','mm_ui(''close'',gcbf)');
fig=mw.mw;
menuHandle = uimenu(mw.mw,...
		'Label','&Command');

uimenu(menuHandle,...
	'Label','Load',...
	'Tag','Load',...
	'Callback','mm_ui(''load'',gcbf);mm_ui(''zoom'',gcbf)');

uimenu(menuHandle,...
	'Label','Compute',...
	'Tag','Compute',...
	'Callback','MM');
uimenu(menuHandle,...
	'Label','Close',...
	'Tag','Close',...
	'Callback','mm_ui(''close'',gcbf)');

menuHandle = uimenu(mw.mw,...
		'Label','&Option');
submenuHandle = uimenu(menuHandle,...
		'Label','Plot Eigenvalues',...
		'tag', 'Plotopt');
uimenu(submenuHandle,...
	'Label','Points',...
	'Tag','Points',...
	'Checked','on',...
	'Callback','mm_ui(''plotspec'',gcbf,gcbo);mm_ui(''zoom'',gcbf)');
mw.plotspec='Points';

uimenu(submenuHandle,...
	'Label','Line',...
	'Tag','Line',...
	'Checked','off',...
	'Callback','mm_ui(''plotspec'',gcbf,gcbo);mm_ui(''zoom'',gcbf)');
uimenu(submenuHandle,...
	'Label','Bar',...
	'Tag','Bar',...
	'Checked','off',...
	'Callback','mm_ui(''plotspec'',gcbf,gcbo);mm_ui(''zoom'',gcbf)');
	


mw.wload = uicontrol('Parent',mw.mw, ...
	'Units','normal', ...
	'BackgroundColor',[0.7 0.7 0.7], ...
	'Callback','mm_ui(''load'',gcbf);', ...
	'ListboxTop',0, ...
	'Position',[0.046 0.94 0.21 0.062], ...
	'String','LOAD', ...
	'visible','off',...
	'Tag','bload');

mw.wcomp = uicontrol('Parent',mw.mw, ...
	'Units','normal', ...
	'BackgroundColor',[0 0.4 0.4], ...
	'Callback','MM', ...
	'ListboxTop',0, ...
	'Position',[0.75 0.94 0.21 0.062], ...
	'String','compute', ...
	'visible','off',...
	'Tag','bcomp');

mw.area = axes('Parent',mw.mw, ...
	'CameraUpVector',[0 1 0], ...
	'CameraUpVectorMode','manual', ...
	'Color',[1 1 1], ...
	'Position',[0.05 0.08 0.775 0.8], ...
	'Tag','area', ...
	'Xticklabel','', ...
	'Yticklabel','', ...
	'XColor',[0 0 0], ...
	'YColor',[0 0 0]);
mw.helpon = uicontrol('Parent',mw.mw, ...
	'unit','normal',...
        'Position',[0.05 0.08 0.775 0.8], ...
	'BackgroundColor',[1 1 1], ...
	'Min', 0, ...
	'Max', 2, ...
	'Value', [], ...
	 'Callback', '', ...
	'Tag','description',...
	'style','list',...
	'string', ' ');


h2 = text('Parent',mw.area, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',[0.5 -0.07 9.2], ...
	'Tag','Axes1Text4', ...
	'VerticalAlignment','cap');
set(get(h2,'Parent'),'XLabel',h2);
h2 = text('Parent',mw.area, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',[-0.06 0.5 9.2], ...
	'Rotation',90, ...
	'Tag','Axes1Text3', ...
	'VerticalAlignment','baseline');
set(get(h2,'Parent'),'YLabel',h2);
h2 = text('Parent',mw.area, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','right', ...
	'Position',[-0.06 1.13 9.2], ...
	'Tag','Axes1Text2', ...
	'Visible','off');
set(get(h2,'Parent'),'ZLabel',h2);
h2 = text('Parent',mw.area, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',[0.5 1.02 9.2], ...
	'Tag','Axes1Text1', ...
	'VerticalAlignment','bottom');
set(get(h2,'Parent'),'Title',h2);





mw.wlabel_sub = uicontrol('Parent',mw.mw, ...
	'Units','normal', ...
	'BackgroundColor',[0.7 0.7 0.7], ...
	'ListboxTop',0, ...
	'Position',[ 0.83 0.83 0.15 0.05 ], ...
	'String',' Space : ', ...
	'Style','text', ...
	'Tag','l_e_sub');

mw.wedit_sub = uicontrol('Parent',mw.mw, ...
	'Units','norm', ...
	'BackgroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[0.83 0.78 0.15 0.05], ...
	'Callback','mm_ui(''plot'',gcbf);', ...
	'Style','edit', ...
	'Tag','e_sub');

mw.wlabel_eig = uicontrol('Parent',mw.mw, ...
	'Units','normal', ...
	'BackgroundColor',[0.7 0.7 0.7], ...
	'ListboxTop',0, ...
	'Position',[ 0.83 0.71 0.15 0.05 ], ...
	'String',' Eigen : ', ...
	'Style','text', ...
	'Tag','l_e_eig');
mw.wedit_eig = uicontrol('Parent',mw.mw, ...
	'Units','norm', ...
	'BackgroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[0.83 0.66 0.15 0.05], ...
	'Callback','mm_ui(''plot'',gcbf);', ...
	'Style','edit', ...
	'Tag','e_eig');

h1 = uicontrol('Parent',mw.mw, ...
	'Units','norm', ...
	'BackgroundColor',[0.70 0.70 0.7], ...
	'ListboxTop',0, ...
	'Position',[0.83 0.52 0.15 0.05], ...
	'String','flip image', ...
	'Style','text', ...
	'Tag','StaticText1');

mw.wedit_flip = uicontrol('Parent',mw.mw, ...
	'Units','normal', ...
	'BackgroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[ 0.83 0.47 0.15 0.05 ], ...
	'Callback','mm_ui(''flip'',gcbf);', ...
	'Style','edit', ...
	'Tag','EditText1');

mw.wmin = uicontrol('Parent',mw.mw, ...
	'Units','normal', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','mm_ui(''zoom'',gcbf);', ...
	'ListboxTop',0, ...
	'Position',[ 0.83 0.185 0.15 0.05 ], ...
	'Style','edit', ...
	'Tag','EditText1');
h1 = uicontrol('Parent',mw.mw, ...
	'Units','normal', ...
	'BackgroundColor',[0.7 0.7 0.7], ...
	'ListboxTop',0, ...
	'Position',[ 0.83 0.235 0.15 0.05 ], ...
	'String','min', ...
	'Style','text', ...
	'Tag','StaticText1');
mw.wmax = uicontrol('Parent',mw.mw, ...
	'Units','normal', ...
	'BackgroundColor',[1 1 1], ...
	'Callback',...
	'mm_ui(''zoom'',gcbf);', ...
	'ListboxTop',0, ...
	'Position',[ 0.83 0.0715 0.15 0.05 ], ...
	'Style','edit', ...
	'Tag','EditText1');
h1 = uicontrol('Parent',mw.mw, ...
	'Units','normal', ...
	'BackgroundColor',[0.7 0.7 0.7], ...
	'ListboxTop',0, ...
	'Position',[ 0.83 0.12 0.15 0.05 ], ...
	'String','max', ...
	'Style','text', ...
	'Tag','StaticText1');
mw.winfo = uicontrol('Parent',mw.mw, ...
	'Units','normal', ...
	'Callback',...
	'H=gcbf;mm_info(H);', ...
	'ListboxTop',0, ...
	'Position',[ 0.83 0.35 0.15 0.05 ], ...
	'String','Info', ...
	'Tag','Pushbutton1');

mw.wplot=[];
%set(mw.helpon,'Enable', 'on', 'Max', 1, 'Value', 1);
set(mw.helpon,'string',helpon);
set(mw.helpon,'value',[]);
set(mw.mw,'userdata',mw);
mw.wplot=ui_initPlot(mw.mw,'init');
set(mw.mw,'userdata',mw);

clear mw;

%====================================================================
%- ploting function 
%- for MLM case plot predicted and observed time-course.
%- for SVD case plot obseved time-course.
%====================================================================
function flag=ui_plot(mw)
	
    mw=get(mw,'UserData'); % Get all data from the main Window.
    if mw.flag==0 %if no valid data return
	flag=0;
	return;
    else

    ok=0;
    tmp=mw.wedit_eig;
    str_cur=get(tmp,'string');
    eval('cur=str2num(str_cur);','ok=1;');
    end
    if isempty(cur)
	    flag=0;
	   
	    return;
    end
    ok=0;
    tmp=mw.wedit_sub;
    str_cur=get(tmp,'string');
    eval('cursp=str2double(str_cur);','ok=1;');
    
    if isnan(cursp)|(cursp>length(mw.MDS.Pmat))
	    cursp=1;
	    
    end
    set(tmp,'string',num2str(cursp));
    tmp=mw.wedit_flip;
    str_flip=get(tmp,'string');
    
    
    flip	= str2num(str_flip);
    res	= length(cur) - length(flip);
    if (res>0)
	    flip(length(flip)+1 : length(cur))=ones(1,res);
    else
	   flip=flip(1 : length(cur));
    end
    
    
    id_cur=find(cur<length(mw.MDS.ds)+1);
    cur=cur(id_cur);
    if isempty(cur)
	    flag=0;
	    return;
    end
    
    flip=sign(flip(id_cur));
    

    mw.wplot=ui_initPlot(mw.mw,'init');
    set(mw.mw,'userdata',mw); % Save data 
 
    
    set(mw.wedit_flip,'string',num2str(flip));
    set(mw.wedit_eig,'string',num2str(cur));

    k=size(cur,2);
    lgd='legend(';

    for i=1:k
	    lgd=sprintf('%s''cp %d'',',lgd,cur(i));
    end
    lgd=lgd(1:length(lgd)-1);
    lgd=[lgd ');'];

    [cc, ia, ib]	=	intersect(cur,mw.MDS.LEig);
   

    data=get(mw.wplot,'UserData');
    data.cur = cur;
    data.cursp=cursp;
    data.flip = diag(flip);
    data.lgd=lgd;
    set(mw.wplot,'UserData',data);

    mw.wplot=ui_initPlot(mw.mw,'display');
    set(mw.mw,'userdata',mw); % Save data     	
    if ~isempty(cc)
	spm_check_registration(mw.MDS.Eig{cursp}(cc,:));
	flip=flip(ia);
	global st
	for i=1:size(cc,2)	
		st.vols{i}.pinfo=st.vols{i}.pinfo*flip(i);
	end	
		spm_orthviews('Redraw');
	else
		disp('Image not present');
	end
        flag=mw.flag;
	set(mw.mw,'userdata',mw); % Save data 


%====================================================================
%- loading function
%- load MLM.mat or SVD.mat
% create MDS structure that contain data and saved as mw (main_window) user-data
 

function flag=ui_load(mw)
	
	mw=get(mw,'UserData'); % Get all data from the main Window.
	flag=mw.flag;
	cla(mw.mw);	
	
	
	set(mw.wedit_eig,'string','');
	set(mw.wedit_flip,'string','');
	set(mw.wmin,'string','');
	set(mw.wmax,'string','');
	eval('set(mw.wplot,''visible'',''off'')',';');

	if ishandle(mw.wplot)
		cla(mw.wplot);
	end

	Fmat		= spm_select(1,'.*.mat','Select MLM.mat or SVD.mat ');
	mw.typeAnal	= spm_str_manip(Fmat,'st');
	cwd		= spm_str_manip(Fmat,'H');
	mw.cwd		=cwd;


	switch mw.typeAnal

			case 'MLM'
				 load(fullfile(cwd,'MLM.mat'));
				 MDS=MLM;
				 clear MLM;

			case 'SVD'
				 load(fullfile(cwd,'SVD.mat'));
				 MDS=SVD;
				 clear SVD;
			otherwise
				error('unknown type of analysis')
	end

	eiglen=0;
	eiglen	= length(MDS.ds);
	spacelen = length(MDS.Pmat);
 	if eiglen

	   set(mw.wmin,'string','1');
	   set(mw.wmax,'string',num2str(eiglen));
	   set(mw.helpon,'visible','off');
	   mw.flag=1;
	   mw.MDS=MDS;
	   clear MDS;

	else
	    mw.flag=0;
	end
	set(mw.wedit_sub,'string','1');
	flag=mw.flag;
	set(mw.mw,'userdata',mw); % Save updated data
	

%====================================================================
%- function initplot
%- initialize ploting window.
 function fig=ui_initPlot(varargin)

	mw=varargin{1};
	mw=get(mw,'UserData'); % Get all data from the main Window.
	action=varargin{2};
	
  switch action
	case 'init'	 
	 if ~isempty(mw.wplot)
    	    set(mw.wplot,'Visible','on');
	    fig=mw.wplot;
	    return ;
	 end
	 
	h0 = figure('CloseRequestFcn','set(gcbf,''Visible'',''off'')', ...
	'Color',[0.8 0.8 0.8], ...
	'IntegerHandle','off', ...
	'NumberTitle','off', ...
	'units','normal', ...
	'Position',[0.010 0.10 0.43 0.40], ...
	'ResizeFcn','legend(''ResizeLegend'')', ...
	'Tag','wplot', ...
	'Visible','off',...
	'ToolBar','none');
	
	h1 = axes('Parent',h0, ...
	'Box','on', ...
	'CameraUpVector',[0 1 0], ...
	'Color',[1 1 1], ...
	'Position',[0.043 0.14 0.774 0.814], ...
	'Tag','Axes1', ...
	'XColor',[0 0 0], ...
	'YColor',[0 0 0], ...
	'ZColor',[0 0 0]);
	
	h1 = uicontrol('Parent',h0, ...
	'Units','normal', ...
	'BackgroundColor',[0.7 0.7 0.7], ...
	'ListboxTop',0, ...
	'Position',[0.83 0.8 0.15 0.05 ], ...
	'String','observed', ...
	'Style','radiobutton', ...
	'Callback','mm_ui(''initPlot'',getfield(get(gcbf,''UserData''),''mw''),''update'');', ...
	'Visible','off',...
	'Tag','ORad');
	
	h1 = uicontrol('Parent',h0, ...
	'Units','normal', ...
	'BackgroundColor',[0.7 0.7 0.7], ...
	'ListboxTop',0, ...
	'Position',[ 0.83 0.73 0.15 0.05 ], ...
	'String','Predicted', ...
	'Style','radiobutton', ...
	'Callback','mm_ui(''initPlot'',getfield(get(gcbf,''UserData''),''mw''),''update'');', ...
	'Max',1,...
	'Min',0,...
	'Visible','off',...
	'Tag','PRad');
	
	h1 = uicontrol('Parent',h0, ...
	'Units','normal', ...
	'BackgroundColor',[0.7 0.7 0.7], ...
	'ListboxTop',0, ...
	'Position',[ 0.83 0.2 0.15 0.05 ], ...
	'String','max', ...
	'Style','text', ...
	'Tag','StaticText1');
	h1 = uicontrol('Parent',h0, ...
	 'Units','normal', ...
	 'BackgroundColor',[1 1 1], ...
	 'Callback','mm_ui(''initPlot'',getfield(get(gcbf,''UserData''),''mw''),''update'');', ...
	 'ListboxTop',0, ...
	 'Position',[ 0.83 0.15 0.15 0.05 ], ...
	 'Style','edit', ...
	 'Tag','wmax');
	h1 = uicontrol('Parent',h0, ...
	 'Units','normal', ...
	 'BackgroundColor',[0.7 0.7 0.7], ...
	 'ListboxTop',0, ...
	 'Position',[ 0.83 0.32 0.15 0.05 ], ...
	 'String','min', ...
	 'Style','text', ...
	 'Tag','StaticText1');
	h1 = uicontrol('Parent',h0, ...
	 'Units','normal', ...
	 'BackgroundColor',[1 1 1], ...
	 'Callback','mm_ui(''initPlot'',getfield(get(gcbf,''UserData''),''mw''),''update'');', ...
	 'ListboxTop',0, ...
	 'Position',[ 0.83 0.27 0.15 0.05 ], ...
	 'Style','edit', ...
	 'Tag','wmin');

	 data.mw=mw.mw;
	 set(h0,'UserData',data);
	 figH=findobj(h0,'Units','points');
	 set(figH,'Units','normalized');
	 fig=h0;

case 'display'
	data=get(mw.wplot,'UserData');
        set(0,'currentfigure',mw.wplot);
	figure(mw.wplot);
	cur=data.cur ;
	cursp=data.cursp;
	flip=data.flip;
	lgd=data.lgd;
	switch mw.typeAnal

 		    case 'MLM'
 		       
		       
		       len=length(mw.MDS.y);
		       
		       h1=findobj(mw.wplot,'Tag','ORad');
		       set(h1,'Value',1);
		       set(h1,'Visible','on');
		       h1=findobj(mw.wplot,'Tag','PRad');
		       set(h1,'Value',1);
		       set(h1,'Visible','on');
		     
		       
		       plot(mw.MDS.Y{cursp}(:,cur)*flip,'.-');
 		       hold on;
 		       plot(mw.MDS.y(:,cur)*flip,'--');
 		       eval(lgd);
 		       hold off;



 		    case 'SVD'
			    len=length(mw.MDS.u);
			    h1=findobj(mw.wplot,'Tag','ORad');
			    set(h1,'Visible','off');
			    h1=findobj(mw.wplot,'Tag','PRad');
		            set(h1,'Visible','off');
			    plot(mw.MDS.u(:,cur)*flip);
			    eval(lgd);
 		    otherwise
			    error('unknown type of analysis')
	end
      h1=findobj(mw.wplot,'Tag','wmin');
      set(h1,'string',sprintf('1'));
      h1=findobj(mw.wplot,'Tag','wmax');
      set(h1,'string',sprintf('%d',len));
      fig=mw.wplot;

case 'update'
	
	data=get(mw.wplot,'UserData');
        set(0,'currentfigure',mw.wplot);
	h1=findobj(mw.wplot,'Tag','wmin');
	min=str2num(get(h1,'string'));
	h1=findobj(mw.wplot,'Tag','wmax');
	max=str2num(get(h1,'string'));
	cur=data.cur ;
	cursp=data.cursp;
	flip=data.flip;
	lgd=data.lgd;
	
	switch mw.typeAnal

 		    case 'MLM'
 		       
		       
		       len=length(mw.MDS.y);
		       
		       h1=findobj(mw.wplot,'Tag','ORad');
		       Oflag=get(h1,'Value');
		       
		       h1=findobj(mw.wplot,'Tag','PRad');
		       Pflag=get(h1,'Value');
		       if( isempty(min) | min > max-1|min<1)
				min=1;
		       end
		       if( isempty(max) | min > max-1|max >len)
				max=len;
		       end
		       
		       
		       if Oflag
			  plot([min:max],mw.MDS.Y{cursp}(min:max,cur)*flip,'.-');
 			  hold on;
		       end
		       if Pflag
 			  plot([min:max],mw.MDS.y(min:max,cur)*flip,'--');
 			  
		       end
 		       eval(lgd);
		       hold off;



 		    case 'SVD'
			    len=length(mw.MDS.u);
			    h1=findobj(mw.wplot,'Tag','ORad');
			    set(h1,'Visible','off');
			    h1=findobj(mw.wplot,'Tag','PRad');
		            set(h1,'Visible','off');
			    if( isempty(min) | min > max-1|min<1)
				min=1;
			    end
			    if( isempty(max) | min > max-1 | max >len)
				max=len;
			     end
			    plot([min:max],mw.MDS.u(min:max,cur)*flip);
			    eval(lgd);
 		    otherwise
			    error('unknown type of analysis')
	end
      h1=findobj(mw.wplot,'Tag','wmin');
      set(h1,'string',min);
      h1=findobj(mw.wplot,'Tag','wmax');
      set(h1,'string',max);
      fig=mw.wplot;
 end
	 
	 
	    
	 
	 







%====================================================================
%- function flip
%- this function flip eigenimage and the corresponding temporal pattern.


function flag=ui_flip(mw)
	
    mw=get(mw,'UserData'); % Get all data from the main Window.
    flag=mw.flag;
    if mw.flag==0
	return;
    else

    tmp=mw.wedit_flip;
    str_cur=get(tmp,'string');
    cur=str2num(str_cur);
    end

    global st
    if isempty(st)
	    return;
    end
	 

    k=size(cur,2);

    for i=1:k
	    if isfield(st,'vols')&isfield(st.vols{1},'pinfo')
	    st.vols{i}.pinfo=sign(cur(i))*st.vols{i}.pinfo;
	    end
    end
    spm_orthviews('Redraw')
    
    flag=mw.flag;
    set(mw.mw,'userdata',mw);

%====================================================================
%- function plot_spec
%- this function set option for the plot of the spectrum of the eigenvalues


function flag=ui_plotspec(mw,obj)
	
    h=setxor(get(get(obj,'parent'),'children'),obj);
    set(h,'checked','off');
    set(obj,'checked','on');
    
    
    mw=get(mw,'UserData'); % Get all data from the main Window.
    mw.plotspec=get(obj,'label');
    flag=mw.flag;
    set(mw.mw,'userdata',mw);
    
  
%====================================================================
%- to close proprely all the window

function flag=ui_close(mw)
	
    mw=get(mw,'UserData'); % Get all data from the main Window.
     if ~isempty(mw.wplot)
    	    delete(mw.wplot);
    	    mw.wplot=[];
    	    set(mw.mw,'userdata',mw);

    end
    flag=mw.flag;
    delete(mw.mw);
	
	
%====================================================================
%- Zooming function : plot the spectrum of the eigenvalues.

function flag=ui_zoom(mw)

    mw=get(mw,'UserData'); % Get all data from the main Window.
    if mw.flag==0 %if no valid data return
	flag=0;
	return;
    else
	flag=1;
	eiglen	= length(mw.MDS.ds);
	spacelen	= length(mw.MDS.Pmat);	
	min=str2num(get(mw.wmin,'string'));
	max=str2num(get(mw.wmax,'string'));
	if( isempty(min) | min > max-1 |min <1)
		min=1;
	end
	if( isempty(max) | min > max-1| max > eiglen)
		max=eiglen;
	end
	
	set(0,'currentfigure',mw.mw);
	
	switch(lower(mw.plotspec))
	     case 'points'
		   plot([min:max],mw.MDS.ds(min:max),'+');
		   

	     case 'line'
		   plot([min:max],mw.MDS.ds(min:max));

	     case 'bar'
		   bar([min:max],mw.MDS.ds(min:max));

	end   
       set(mw.area,'xlim',get(mw.area,'Xlim')+[-0.5 +0.5]);
       set(mw.area,'Xgrid','on');
       set(mw.area,'Ygrid','on');
       legend(sprintf('nb Space : %d \nnb Eigen  : %d',spacelen,eiglen));

	set(mw.wmin,'string',min);	
    	set(mw.wmax,'string',max);
	
end
	



