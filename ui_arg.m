function varargout = ui_arg(varargin)
% Argument manager interface
% format varargout = ui_arg(varargin)
% The idea of this routine is to have a separate description of the arguments 
% from the main program (to be able to add or modify arguments)
%
% ui_arg is based on spm_input_ui and spm_get, then handles most forms of interactive user input.
% (see spm_input or spm_get for details.)
%
% 
% 
% accept one or two input argument : arg = ui_arg(s_arg,'field') or arg = ui_arg(s_arg);
% 	s_arg or s_arg.el must be a valid structure of ui_arg type that contain different field.
% 	s_arg.title (optional) : title of the window.
%	s_arg.description (optional): Give information or help. 
% 	s_arg.ProgType (required) : type of the argument (file,dir,edit,contrast,choice)
%	s_arg.input    (required) : argument parameters 
% 				    s_arg.input.prompt : all type of argument
%				    s_arg.input.filter : file or dir type
% 				    s_arg.input.base   : dir type 
%				    s_arg.input.nb     : file type 
% 				    s_arg.input.etype  : edit type 
%							(string,string+,natural,whole,real,evaluated)
%							 as defined in spm_input.
%				    s_arg.input.def	: edit,choices 
%================================================================================
%-  Copyright (C) 1997-2002 CEA
%-  This software and supporting documentation were developed by
%-       CEA/DSV/SHFJ/UNAF
%-       4 place du General Leclerc
%-       91401 Orsay cedex
%-       France
%================================================================================
%- kherif ferath


if (nargin < 1)
	return;
end

s_arg = varargin{1};

if ~(isstruct(s_arg))
	error('Input argument : not a structure');
	return;
end 

if (nargin > 1)  
	s_arg_el	= varargin{2};
	if ~(isfield(s_arg,s_arg_el)) 
		error(sprintf('invalid field : %s',s_arg_el));
	end
	s_arg_el	= getfield(s_arg,s_arg_el);
	if (isfield(s_arg,'title'))
		title	= getfield(s_arg,'title');
	elseif isfield(s_arg_el,'prompt')
		title	= getfiel(s_arg_el,'prompt')
	else title = ''; %**** == before (jb)
	end
	
	varargout{1}	= sf_get_arg(title,s_arg_el);
	return	
end

if isfield(s_arg, 'prompt')
	title	= getfield(s_arg,'prompt');
else title = '';
end

varargout{1}	= sf_get_arg(title,s_arg);



%-------------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------
% SUB FUNCTIONS
%-------------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------


%-------------------------------------------------------------------------------------------
function varargout = sf_get_arg(title,s_arg)
%-------------------------------------------------------------------------------------------
%- Get the arguments by launching spm_input or spm_get
%- updates the description window W.des
%- updates the title window : W.title
%- updates the main window : W.main
%
%- s_arg : description above 
%- title : string with the name of the main window
	
	[s_arg, ok] = sf_uiArgCheck(s_arg);
	
	if ~ok 
	   error(sprintf('Imcompatible argument structure ...\n type help ui_arg for details'));	
	end
	Location=10.5;			%default location of the spm_input
	F	= sf_uiArgInit; 	% Initialise gui
	set(F,'unit','pix');
	W	= get(F,'UserData'); 	% get Info saved in the main window.
	
	% and now, we can put all the info and prompt for the input:
	
	set(W.main,'name',title) 	% Rename the main window.
	if ~(isfield(s_arg,'prompt')) 	s_arg.prompt = ''; end;
	set(W.title,'string', s_arg.prompt);
	if ~(isfield(s_arg,'description')) s_arg.description = 'No description'; end; 
	set(W.des,'string',deblank(s_arg.description));
	set(W.des,'Value',[]);
	oldtag = get(W.main,'tag');
	set(W.main,'tag','');
	set(0,'currentfigure',W.main);
	
	
	switch s_arg.ProgType
		case 'choice'
		  ok='B';
		case 'string'
		  ok='I';  IType='s';
		case 'string+'
		  ok='I';  IType='s+';  
		case 'evaluated'
		  ok='I';  IType='e';
		case 'natural'
		  ok='I';  IType='n';
		case 'whole'
		  ok='I';  IType='w';
		case 'integer'
		  ok='I';  IType='i';
		case 'real' 
		  ok='I';  IType='r';
		case 'contrast'
		  ok='GC'; IType='cid';
		case 'dir'
		  ok='G';  IType='dir';
		case 'file'
		  ok='G';  IType='file'; 
	
	
	otherwise
		error('invalid input Type');
	end
	
	if (ok=='I')
		varargout{1} = spm_input(s_arg.input.prompt,Location,IType,s_arg.input.def,s_arg.input.req);
	elseif (ok=='G')
	    if (strcmp(IType,'dir'))
            s_arg.input.base=pwd;
	       cb = sprintf('ui_arg_res=spm_select(1,''dir'',''%s'',{},''%s'',''%s'');uiresume(UD.fig);',...
	   		     s_arg.input.prompt,s_arg.input.base,'.*');
	    end
	    if (strcmp(IType,'file'))
	    	cb = sprintf('ui_arg_res=spm_select(%s,''any'',''%s'','''',''%s'',''%s'');uiresume(UD.fig);',...
				num2str(s_arg.input.nb),s_arg.input.prompt,pwd,s_arg.input.filter);
	    end
		UD.fig=F;
		cb=sprintf('%s data=get(UD.fig,''UserData'');data.ans={ui_arg_res};set(UD.fig,''UserData'',data);',cb);
		
		spm_input(s_arg.input.prompt,Location,'b!','Browse',char(cb),UD,1);
		uiwait(F);
		data=get(F,'UserData');
		clear UD;
		varargout{1}=data.ans{1};
			
			
	elseif (ok=='B')
	    if isempty(s_arg.input.values)
	     varargout{1} = spm_input(s_arg.input.prompt,Location,'b',s_arg.input.label);
	    else
	     varargout{1} = spm_input(s_arg.input.prompt,Location,'b',s_arg.input.label,s_arg.input.values,s_arg.input.def);
 	    end
	
	else
	    if (strcmp(IType,'cid'))
	    UD.SPM= s_arg.input.SPM;
		UD.xCon= s_arg.input.xCon;
		UD.fig=F;
	    cb = sprintf('[ui_arg_res1 ui_arg_res2] = spm_conman(UD.SPM,''T|F'',1,''%s'','' '',1);uiresume(UD.fig);',s_arg.input.prompt); %
		cb = sprintf('%s data = get(UD.fig,''UserData'');data.ans={ui_arg_res1 ,ui_arg_res2};set(UD.fig,''UserData'',data)',cb);
		h = spm_input('',Location,'b!','select a contrast',char(cb),UD,1);
		uiwait(F);
		data = get(F,'UserData');
		clear UD;
		varargout{1} = data.ans;
	    end
	end	    
spm_input('!DeleteInputObj',F);
set(F,'tag','uiArgFigure');
set(F,'unit','norm');
set(W.title,'string', ''); 
set(W.des,'string','');
set(W.des,'Value',[]);
set(W.main,'Visible','off');
drawnow


%-------------------------------------------------------------------------------------------
function [s_arg, ok] = sf_uiArgCheck(s_arg)
%-------------------------------------------------------------------------------------------	
%
% Check that the s_arg structure is well constructed 
% If fields are missing, they will be added and some defaults values are set
% returns an error if necessary fields are missing.  
%
	
	if ~(isfield(s_arg,'ProgType'))
		ok=0;
		return;
	end
	
	validProgType = {'directory' 'file' 'edit' 'choice' 'contrast'};
	typMatch = strmatch(s_arg.ProgType,validProgType);
	if (isempty(typMatch))
		ok=0;
		return;
	end
	switch validProgType{typMatch(1,1)}
		
		case 'directory'
			if ~(isfield(s_arg.input,'filter'))
				s_arg.input.filter='';
			end
			
			if ~(isfield(s_arg.input,'base'))
				s_arg.input.base='';
			end
		case 'file'
			if ~(isfield(s_arg.input,'filter'))
				s_arg.input.filter='';
			end
			
			if ~(isfield(s_arg.input,'nb'))
				s_arg.input.nb='inf';
			end
		
		case 'choice'
		      if ~(isfield(s_arg.input,'label'))
		              ok=0; 
			      return;
		      end
	
		      if ~(isfield(s_arg.input,'values'))
		              s_arg.input.values='';
		      end
		      
		      if ~(isfield(s_arg.input,'def'))
		              s_arg.input.def='';
		      end
		case 'edit'
			
		       if ~(isfield(s_arg.input,'etype'))
		               s_arg.input.etype='evaluated';
		       end
		       validEdit={'string' 'string+' 'evaluated' 'whole' 'integer' 'real'};
		       EMatch = strmatch(s_arg.input.etype,validEdit);
		       if (isempty(EMatch))
			       ok=0;
			       return;
		       end
		      s_arg.ProgType= validEdit{EMatch(1,1)};
		      if ~(isfield(s_arg.input,'def'))
		              s_arg.input.def='';
		      end
		      
		      if ~(isfield(s_arg.input,'req'))
		              s_arg.input.req='';
		      end
		      
		      
		
		case 'contrast'
		     if ~(isfield(s_arg.input,'SPM'))
		     	     ok=0;
			     return
		     end
		     if ~(isfield(s_arg.input,'xCon'))
		     	     ok=0;
		     	     return
		     end
		     
		     
		
		otherwise
		     ok = 0;
		return;
	end    
	if ~(isfield(s_arg.input,'prompt'))
		
		s_arg.input.prompt = '';
	end
	
	ok=1;	  
	

%-------------------------------------------------------------------------------------------
function F=sf_uiArgInit
%-------------------------------------------------------------------------------------------	
%
% Construction of the interface window for ui_arg.
%
% 	
	
	F	= 'uiArgFigure';
	F	= spm_figure('FindWin',F);
	PF        = spm_platform('fonts');
	It	= spm_figure('FindWin','Interactive');
% 	if (It) delete(It); end
% 	if (F)
% 		set(F,'Visible','on');
% 		data = get(F,'UserData');
% 		data.ans=[];  
% 		set(F,'UserData',data);
% 	else
	    
	    oldRootUnits = get(0,'Units');
   set(0, 'Units', 'points');
   
   pixfactor = (72/get(0,'screenpixelsperinch'))*1.1;
   figurePos=get(0,'DefaultFigurePosition');
   figurePos(3:4)=[450 335];
   figurePos = figurePos * pixfactor;
   rootScreenSize = get(0,'ScreenSize');
   if ((figurePos(1) < 1) ...
         | (figurePos(1)+figurePos(3) > rootScreenSize(3)))
      figurePos(1) = 30;
   end
   set(0, 'Units', oldRootUnits);
   if ((figurePos(2)+figurePos(4)+60 > rootScreenSize(4)) ...
            | (figurePos(2) < 1))
	 figurePos(2) = rootScreenSize(4) - figurePos(4) - 60;
  end
  
  
 COLOUR=[0.7 0.7 0.7];
 
        w.main = figure('Color',[0.8 0.8 0.8], ...
		       'Units','points', ...
		       'Position',figurePos, ...
		       'Tag','uiArgFigure', ...,
		       'MenuBar','none',...
		       'NumberTitle','off',...
		       'IntegerHandle','off',...
		       'ToolBar','none');
	       w.f1 = uicontrol('Parent',w.main, ...
		       'Units','points', ...
		       'ListboxTop',0, ...
		       'BackgroundColor',COLOUR, ...
		       'Position',[0 0 450 335]*pixfactor, ...
		       'Style','frame', ...
		       'Tag','Frame1');
	       w.f2 = uicontrol('Parent',w.main, ...
		       'Units','points', ...
		       'ListboxTop',0, ...
		       'BackgroundColor',COLOUR, ...
		       'Position',[5 294.4 435 35]*pixfactor, ...
		       'Style','frame', ...
		       'Tag','Frame2');
	       w.f3 = uicontrol('Parent',w.main, ...
		       'Units','points', ...
		       'BackgroundColor',COLOUR, ...
		       'ListboxTop',0, ...
		       'Position',[5 150 435 125]*pixfactor, ...
		       'Style','frame', ...
		       'Tag','Frame3');
	       w.des = uicontrol('Parent',w.main, ...
		       'Units','points', ...
		       'FontSize',10, ...
		       'FontName',PF.courier, ...
		       'HorizontalAlignment','left', ...
		       'Min', 0, ...
		       'Max', 2, ...
		       'BackgroundColor',[1 1 1]*0.95, ...
		       'Position',[10 152 425 120]*pixfactor, ...
		       'String',' ', ...
		       'Style','list', ...
		       'Callback', 'set(gcbo,''value'',[]);', ...
		       'Tag','Listbox1', ...
		       'Value',[]);
	       w.title = uicontrol('Parent',w.main, ...
		       'Units','points', ...
		       'HorizontalAlignment','left', ...
		       'Enable', 'inactive', ...
		       'BackgroundColor',[1 1 1]*0.95, ...
		       'FontSize',14, ...
		       'FontWeight','demi', ...
		       'ListboxTop',0, ...
		       'Position',[8.8 298 428 28]*pixfactor, ...
		       'Style','text', ...
		       'Tag','StaticText1');
	       w.label = uicontrol('Parent',w.main, ...
		       'Units','points', ...
		       'BackgroundColor',COLOUR, ...
		       'FontSize',12, ...
		       'FontWeight','demi', ...
		       'ForegroundColor',[1 0 0], ...
		       'HorizontalAlignment','left', ...
		       'ListboxTop',0, ...
		       'Position',[6.4 273.6 128 19.2]*pixfactor, ...
		       'String','Description ...', ...
		       'Style','text', ...
		       'Tag','StaticText2');
	       w.ans=[];
	       set(w.main,'UserData',w);
	       set([w.main w.f1 w.f2 w.f3 w.des w.label w.title],...
	       		'Units','normalized');
	       F=w.main;
 
