function mm_info(mw)
% Display information about Multivariate anlysis results.
%================================================================================
%-  Copyright (C) 1997-2002 CEA
%-  This software and supporting documentation were developed by
%-       CEA/DSV/SHFJ/UNAF
%-       4 place du General Leclerc
%-       91401 Orsay cedex
%-       France
%================================================================================

mw=get(mw,'UserData');

flag=mw.flag;
    if mw.flag==0
	return;
end
tmp=mw.wedit_sub;
    str_cur=get(tmp,'string');
    eval('cursp=str2double(str_cur);','ok=1;');
    
    if isnan(cursp)|(cursp>length(mw.MDS.Pmat))
	    cursp=1;
	    
    end
set(tmp,'string',num2str(cursp));

%Launch Graphic Window

Fgraph = spm_figure('GetWin','Graphics');
set(Fgraph,'name','Multivariate Methods: Graphics');
spm_figure('Clear',Fgraph)
FS    = spm('FontSizes');
PF        = spm_platform('fonts');

% Get the multivariate data for the main window
xC=mw.MDS.xC;
sub=cursp; % subject id
Rep=['NO ';'Yes'];
%load the Design Matrix used for the data
Param=mw.MDS.paramsAnal;
load(mw.MDS.Pmat{sub});
xX=SPM.xX;






%-Print comparison title
%-----------------------------------------------------------------------
hTitAx = axes('Parent',Fgraph,...
		'Position',[0.02 0.95 0.96 0.02],...
		'Visible','off');

text(0.5,0,xC.name,'Parent',hTitAx,...
	'HorizontalAlignment','center',...
	'VerticalAlignment','baseline',...
	'FontWeight','Bold','FontSize',FS(14))

cwd=strrep(spm_str_manip(mw.cwd,'a30'),'\','\\');
UpInfo=sprintf('{\\fontsize{14}\\bf} Results {\\fontsize{12}\\rm}%s',cwd);
UpInfo=sprintf('%s\n\n {\\fontsize{14}\\bf}Parameters \\rm',UpInfo);
UpInfo=sprintf('%s\n {\\fontsize{12}\\bf} Divide by Res std          : \\rm %s ',...
		UpInfo,Rep(Param.divideByRessd+1,:));
UpInfo=sprintf('%s\n {\\fontsize{12}\\bf} Temporaly Filter           : \\rm %s ',...
		UpInfo,Rep(Param.temporalFilter+1,:));
UpInfo=sprintf('%s\n {\\fontsize{12}\\bf} Projected to Res space  : \\rm %s ',...
		UpInfo,Rep(Param.resContSp+1,:));

Up=sf_strsplit(UpInfo,sprintf('\n'));

%-Print MM results: Results directory & Paramaters of the analysis
%-----------------------------------------------------------------------
hResAx = axes('Parent',Fgraph,...
		'Position',[0.02 0.85 0.45 0.05],...
		'DefaultTextVerticalAlignment','baseline',...
		'DefaultTextFontSize',FS(9),...
		'DefaultTextColor',[1,1,1]*.7,...
		'Units','points',...
		'Visible','off');
AxPos = get(hResAx,'Position'); set(hResAx,'YLim',[0,AxPos(4)])
h = text(0,24,Up,'Parent',hResAx,...
	'FontWeight','Bold','FontSize',FS(12),'interpreter','tex');


%tt=text(get(h,'Extent')*[0;0;1;0],24,spm_str_manip(mw.cwd,'a30'),'Parent',hResAx)%
%jj=get(h,'Extent')*[0;1;0;0]
%text(0,jj-5,'Parameters :','Parent',hResAx,...
	%'FontWeight','Bold','FontSize',FS(14));


%-Plot design matrix
%-----------------------------------------------------------------------
hDesMtx   = axes('Parent',Fgraph,'Position',[0.65 0.55 0.25 0.25]);
hDesMtxIm = image((xX.nKX+1)*32);
set(hDesMtx,...
	'XTick',spm_DesRep('ScanTick',size(xX.nKX,2),10),...
	'YTick',spm_DesRep('ScanTick',size(xX.nKX,1),24),'TickDir','out')
xlabel('Design matrix')

%-Plot contrasts
%-----------------------------------------------------------------------
nPar   = size(xX.X,2);
xx     = [repmat([0:nPar-1],2,1);repmat([1:nPar],2,1)];
nCon   = length(xC);
if nCon
	dy     = 0.15/max(nCon,2);
	hConAx = axes('Position',[0.65 (0.80 + dy*.1) 0.25 dy*(nCon-.1)],...
		'Tag','ConGrphAx','Visible','off');
	title('contrast(s)')
	htxt = get(hConAx,'title'); 
	set(htxt,'Visible','on','HandleVisibility','on')
end

for ii = nCon:-1:1
    axes('Position',[0.65 (0.80 + dy*(nCon-ii+.1)) 0.25 dy*.9])
    if xC.STAT == 'T' & size(xC.c,2) == 1

	%-Single vector contrast for SPM{t} - bar
	%---------------------------------------------------------------
	yy = [zeros(1,nPar);repmat(xC.c',2,1);zeros(1,nPar)];
	h = patch(xx,yy,[1,1,1]*.5);
	set(gca,'Tag','ConGrphAx',...
		'Box','off','TickDir','out',...
		'XTick',spm_DesRep('ScanTick',nPar,10)-0.5,'XTickLabel','',...
		'XLim',	[0,nPar],...
		'YTick',[-1,0,+1],'YTickLabel','',...
		'YLim',	[min(xC.c),max(xC.c)] + ...
			[-1 +1] * max(abs(xC.c))/10	)

    else

	%-F-contrast - image
	%---------------------------------------------------------------
	h = image((xC.c'/max(abs(xC.c(:)))+1)*32);
	set(gca,'Tag','ConGrphAx',...
		'Box','on','TickDir','out',...
		'XTick',spm_DesRep('ScanTick',nPar,10),'XTickLabel','',...
		'XLim',	[0,nPar]+0.5,...
		'YTick',[0:size(xC.c,2)]+0.5,'YTickLabel','',...
		'YLim',	[0,size(xC.c,2)]+0.5	)

    end
    
    
end

j=1;
CumVar=0;
VarTot=sum(mw.MDS.ds);
for i=1:length(mw.MDS.ds)
val=sprintf('%3.3f',mw.MDS.ds(i));
Pvar=mw.MDS.ds(i)*100/VarTot;sPvar=sprintf('%3.2f',Pvar);
CumVar=CumVar+Pvar;sCumVar=sprintf('%3.2f',CumVar);
if strcmp(mw.typeAnal,'MLM')
	Pval=sprintf('%2.2g',mw.MDS.stat.Pf(i));
else
	Pval=' ';
end

if (i==mw.MDS.LEig(j) & i<length(mw.MDS.LEig)+1)	
BotInfo{i}=sprintf('%+5s  %-33s  %+8s  %+6s  %+6s %+8s',num2str(i),spm_str_manip(mw.MDS.Eig{cursp}(i,:),'k30'),val,sPvar,sCumVar,Pval); 
if(j+1>length(mw.MDS.LEig)) ; 
else  
j=j+1;
end

else 
BotInfo{i}=sprintf('%+5s  %-33s  %+8s  %+6s  %+6s %+8s',num2str(i),'not computed',val,sPvar,sCumVar,Pval);
end
end

HeadBotInfo=sprintf('%+5s  %-33s  %+8s  %+6s  %+6s %+8s','Id','Name','Value','%Var','%CumVar','Pval');

 %-Table axes & Title
%-----------------------------------------------------------------------
hAx   = axes('Position',[0.05 0.1 0.9 0.4],...
	'DefaultTextFontSize',FS(8),...
	'DefaultTextInterpreter','Tex',...
	'DefaultTextVerticalAlignment','Baseline',...
	'Units','points',...
	'Visible','off');
AxPos = get(hAx,'Position'); set(hAx,'YLim',[0,AxPos(4)])
dy    = FS(9);
y     = floor(AxPos(4)) - dy;

text(0,y,'Statistics:',...
	'FontSize',FS(11),'FontWeight','Bold');	y = y - dy/2;
line([0 1],[y y],'LineWidth',3,'Color','r'),	y = y - 9*dy/8;

 %-Construct table header
%-----------------------------------------------------------------------
set(gca,'DefaultTextFontName',PF.courier,'DefaultTextFontSize',FS(8))
text(0.01,y,HeadBotInfo,'FontSize',FS(8));	y = y - 9*dy/8;

Hc = [];
%h = text(0.01,y,	BotInfo,'FontSize',FS(9));		%Hc = [Hc,h];

CBPlt=sprintf('data=get(gcbo,''UserData'');if isempty(data), return;end;set(data{3},''Visible'',''on''); ');
CBPlt=sprintf('%s val=get(gcbo,''Value'');set(data{2},''CurrentAxes'',data{3});bar(data{1}(:,val));',CBPlt);

ListInfo=uicontrol('Parent',Fgraph, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'FontName',PF.courier, ...
    'FontSize',FS(8), ...
	'Position',[0.05 0.06 0.9 0.4], ...
	'String',BotInfo, ...
	'Style','listbox', ...
	'Tag','Listbox1', ...
	'callback',CBPlt,...
	'Value',1);




PlCt = axes('Parent',Fgraph, ...
	'CameraUpVector',[0 1 0], ...
	'Visible','off',...
	'Color',[1 1 1], ...
	'FontName',PF.courier, ...
	'Position',[0.05 0.52 0.5 0.25], ...
	'Tag','AKF', ...
	'XColor',[0 0 0], ...
	'YColor',[0 0 0], ...
	'ZColor',[0 0 0]);
if strcmp(mw.typeAnal,'MLM')
	set(ListInfo,'UserData',{mw.MDS.M12*mw.MDS.u,Fgraph,PlCt});
else
	set(ListInfo,'UserData',[]);
end




function [res,n]=sf_strsplit(str,fs)

%format [a,n]=str_split(str,fs)
%- Split the string str into cell array elements a{1}, a{2},
%- a{n},  and  return n. The separation will be
%- done with the expression  fs
%- 


if length(fs) >1 
	disp('error')
	return;
end

id=find(str==fs);
if isempty(id)
	n=1;
	res{n}=str;
	return
end
sz=length(str);
cur=1;
n=1;
for i=1:length(id)
	
	tmp=str(cur:id(i)-1);
	if length(tmp)
	   res{n}=str(cur:id(i)-1);
	   n=n+1;
	end
	cur=id(i)+1;
	
	if (id(i)==sz)
		break;
	end


end

if id(length(id))<sz
	res{n}=str(id(length(id))+1:sz);

else n=n-1;
end
	





