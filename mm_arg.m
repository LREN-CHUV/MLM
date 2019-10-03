function varargout = mm_arg(typeAnal, argfile)
% Get arguments for MLM/SVD analysis.
% Format varargout = mm_arg(typeAnal, argfile)
% nbsub		= Number of subject or space domain.
% Pimg		= Beta images for MLM, Data images for SVD.
% Res		= estimated residual variance image.
% Mask 		= analysis mask image indicating which voxels were
%		 included in the analysis
% gcsd		= global result directory.
% cwd		= current working directory (dir contening the model)
% csd 		= current saving directory for each space domain.
% fname 	= Eigen image basename.
% Xc		= Contrast 
% gsf		= global scaling factor.
% Filter 	= Sparse temporal smoothing matrix.
% leig		= Eigen Images to save.
% paramsAnal	= Parameters for the anlysis :
%================================================================================
%-  Copyright (C) 1997-2002 CEA
%-  This software and supporting documentation were developed by
%-       CEA/DSV/SHFJ/UNAF
%-       4 place du General Leclerc
%-       91401 Orsay cedex
%-       France
%================================================================================





switch typeAnal
	case 'MLM'
		[nbsub, Pimg, Res, Mask, Yimg, gcsd, cwd, csd, xC, fname, gsf, Filter, leig, paramsAnal,W] = ...
										sf_arg_mlm(argfile);
		varargout 	= {nbsub, Pimg, Res, Mask, Yimg,gcsd, cwd, csd, xC, fname, gsf, Filter, ...
										leig, paramsAnal,W};
	case 'SVD'
		[nbsub, Pimg, Res, Mask, gcsd, cwd, csd, xC, Filter, paramsAnal, fname, leig, gsf,W] = ...
				 						sf_arg_svd(argfile);
		varargout 	= {nbsub, Pimg, Res, Mask, gcsd, cwd, csd, xC, Filter, paramsAnal, ...
										fname, leig, gsf,W};
	otherwise
		error('unknown type of analysis')
end


%=========================================================================================================
function [nbsub, Pimg, Res, Mask, Yimg ,gcsd, cwd, csd, xC, fname, gsf, Filter, leig, paramsAnal,W] = ...
										sf_arg_mlm(argfile)

%- 	if the argfile is not given then the interactive mode is use.
% argfile format is : one line per subject whith 3 variables cwd, csd and d delimited by a semicolon ";".
%
% input argument for the multivariate analysis.
% FORMAT [nbsub, Pimg, Res,Mask] = mm_arg(argfile)
% 
% nbsub 		: number of subject
% Pimg 			: images filename, input data for the mlm computation
% cwd, csd		: SPM.mat directory, directory for saving results.
% argfile 		: parameter file 
% cwd, csd 		: working and saving directory. 
% Xc 			: contrast.  
% paramsAnal		: on what is the eigen value decomposition done : 
%			   - divideByRessd = 1 : divide by the residual standard deviation
%			   - temporalFilter = 1 : apply the temporal filter to data first
% fname			: generic name for the eigen images
% leig			: liste of number for which the corresponding eigenimages will be constructed
%=========================================================================================================

if isempty(argfile) %- INTERACTIVE MODE
   
   %- Set the number of subjects and gcsd
   %--------------------------------------------------------------------

	  
	  gcsd	= ui_arg(mm_load_arg('god'),'god');
	  nbsub	= ui_arg(mm_load_arg('nbsub'),'nbsub');
	  

   %- Set working directory for each subject and names for eigenimages
   %--------------------------------------------------------------------

   	  for sub=1:nbsub
   	      input 	= sprintf('for space domain %d ',sub);
	      arg   	= mm_load_arg('mod');
	      arg.mod.input.prompt = ['model  ' input];
	      cwd{sub} 	= spm_str_manip(ui_arg(arg,'mod'),'H');
	      if nbsub > 1
	         arg		= mm_load_arg('iod');
		 arg.iod.input.prompt = ['dir ' input];
   	         csd{sub} 	= ui_arg(arg,'iod');
	      else
	         csd{1}		= gcsd;
	      end
	      arg	 = mm_load_arg('neig');arg.neig.input.prompt=[arg.neig.input.prompt input];
   	      fname{sub} = ui_arg(arg,'neig');
	      arg = mm_load_arg('DefImages');arg.DefImages.input.prompt=['Images ' input];
       defImg=ui_arg(arg,'DefImages');
	      if defImg
		      load(fullfile(cwd{sub},'SPM.mat'));
		      Yimg{sub}=SPM.xY.P;
	      else
		      arg=mm_load_arg('Image');
		      arg.image.input.prompt=['Images ' input] ;
		      Yimg{sub} 	= ui_arg(arg,'Image');
	      end
   	  end
   	  
	  % csd = cwd; %- by default working and saving directory are the same.
  
   %- Load the design Matrix, (same for all subjects) and the temporal filter
   %--------------------------------------------------------------------
  
  	  Pmat = fullfile(cwd{1},'SPM.mat');
	  load(Pmat);
	  xX=SPM.xX
    	  Filter	= SPM.xX.K;
	  W		=SPM.xX.W;
   
   %- Load the contrast 
   %--------------------------------------------------------------------

   	  %Pcon 		    = ui_arg(mm_load_arg('Cm'),'Cm');	%- get name of xCon matrix
   	  %load(Pcon,'xCon');
	  arg 		    = mm_load_arg('Ci'); %- Ci : a specific contrast
   arg.Ci.input.SPM=SPM; 
   arg.Ci.input.xCon=SPM.xCon; 
   	  arg 		    = ui_arg(arg,'Ci');
	  [Ic,xCon]	    = deal(arg{:});
   	  xC 		    = xCon(Ic);
	  %SPM.xCon=xCon;
	  
	  %try, save(cwd{1},'SPM'); catch, fprintf('can not save xCon : check permissions\n'); end;
	  clear arg;
      
elseif isstruct(argfile) %- SPM BATCH MODE
    
    job = argfile;
    
    gcsd = job.god{1};
    nbsub = numel(job.domain);
    
    %- Working directories and eigen image names
    for sub=1:nbsub          
          cwd{sub} = spm_str_manip(job.domain(sub).mod{1},'H'); %#ok<AGROW>
          
          if nbsub > 1
   	         csd{sub} 	= job.domain(sub).iod{1}; %#ok<AGROW>
	      else
	         csd{1}		= gcsd;
          end
   	      fname{sub} = job.domain(sub).neig;
          
          defImg=isfield(job.domain(sub).DefImages, 'UseDefImage');
	      if defImg
		      load(fullfile(cwd{sub},'SPM.mat'));
		      Yimg{sub}=SPM.xY.P; %#ok<AGROW>
          else
		      Yimg{sub} 	= job.domain(sub).DefImages.Image; %#ok<AGROW>
	      end
    end
    
    %- Design matrix and temporal filter
    Pmat = fullfile(cwd{1},'SPM.mat');
    load(Pmat);
    xX = SPM.xX; %#ok<NASGU>
    Filter = SPM.xX.K;
    W = SPM.xX.W;
    
    %- Contrast
	Ic = job.Ci;xCon = SPM.xCon;
    %[Ic,xCon] = deal([job.Ci(1), SPM.xCon]);
   	xC = xCon(Ic);
    
    %- leig
    leig = job.leig;
    
else   %- BATCH MODE
 	  [ggcsd cwd csd d fname] 	= textread(argfile,'%s %s %s %d %s','commentstyle','matlab');
	  gcsd=ggcsd{1};
 	  nbsub		= size(cwd,1);
 	  load(fullfile(cwd{1},'xCon.mat'),'xCon');
	  load(fullfile(cwd{1},'SPM.mat'),'xX');
	  Filter=xX.K;
	  d = d(1,1);
	  if isempty(d), d=1; end
  	  xC 	= xCon(d);
	  %------ SOME DEFAULTS VALES - TO BE PUT IN A DEFAULT FILE ?
	  leig 	= 1:5;			% defaults that should 
end

%- Set parameters : filtering and divide by std deviation
%--------------------------------------------------------------------
  paramsAnal.divideByRessd 	= 1;
  paramsAnal.temporalFilter 	= 1;
  paramsAnal.resContSp		= 0;

%- set the parameters: Pimg, Res and Mask filenames.
%--------------------------------------------------------------------

for sub = 1:nbsub
       load(fullfile(cwd{sub},'SPM.mat'));
       Vbeta=SPM.Vbeta;
      %Pimg{sub}	= [repmat([cwd{sub}, filesep],length(Vbeta),1),char(Vbeta.fname)];
       Pimg{sub}	= char(Vbeta.fname);
        Mask{sub}	= fullfile(cwd{sub}, 'mask.nii');

       VResMS =SPM.VResMS
       %Res{sub}		= fullfile(cwd{sub},char(VResMS.fname));
       Res{sub}		= char(VResMS.fname);
       gsf{sub}		= SPM.xGX.gSF;
     
end


if isempty(argfile)    %- NOT IN BATCH MODE
   %- Set number of eigenimages
   %--------------------------------------------------------------------
   arg		= mm_load_arg('leig');
   arg.leig.input.def=['[1:' num2str(min(5,size(Pimg{1},1))) ']'];
   leig 	= ui_arg(arg,'leig');

end


clear Vbeta,VResMS;


%=========================================================================================================
function [nbsub, Pimg, Res, Mask, gcsd, cwd, csd, xC, Filter, paramsAnal, fname, leig, gsf,W] = ...
									sf_arg_svd(argfile);
%
% paramsAnal		: on what is the eigen value decomposition done : 
%			   - divideByRessd = 1 : divide by the residual standard deviation
%			   - temporalFilter = 1 : apply the temporal filter to data first
% fname			: generic name for the eigen images
% leig			: liste of number for which the corresponding 
%			  eigenimages will be constructed
% 
%=========================================================================================================

paramsAnal = struct(...
		'divideByRessd', 1, ...
		'temporalFilter', 1, ...
		'resContSp', 0 ...
		);

if isempty(argfile) %- INTERACTIVE MODE
	
   %- Set the number of subjects and gcsd
   %--------------------------------------------------------------------

   gcsd		= ui_arg(mm_load_arg('god'),'god');
   nbsub	= ui_arg(mm_load_arg('nbsub'),'nbsub');
	  
   %- Set input and output directories and names for eigenimages - get gsf
   %--------------------------------------------------------------------   
   for sub=1:nbsub
       input=sprintf('for space domain %d ',sub);
       arg=mm_load_arg('mod');
       arg.mod.input.prompt=['model  ' input];  
       cwd{sub} 	= spm_str_manip(ui_arg(arg,'mod'),'H');
       load(fullfile(cwd{sub},'SPM.mat'));
       if nbsub > 1
          arg=mm_load_arg('iod');arg.iod.input.prompt = ['result directory  ' input];      			 
          csd{sub} 	= ui_arg(arg,'iod');
       else
	  csd{1}	= gcsd;
       end
       arg = mm_load_arg('DefImages');arg.DefImages.input.prompt=['Images ' input];
       defImg=ui_arg(arg,'DefImages');
       if defImg
		Pimg{sub}=SPM.xY.P;
	else
		arg=mm_load_arg('Image');
		arg.image.input.prompt=['Images ' input];

   		Pimg{sub} 	= ui_arg(arg,'Image');
       end
       arg = mm_load_arg('neig'); arg.neig.input.prompt=[arg.neig.input.prompt input];
       fname{sub} 			= ui_arg(arg,'neig');
       
       gsf{sub}				= SPM.xGX.gSF;
       
       Mask{sub}   	= fullfile(cwd{sub},'mask.img');
       Res{sub}	= fullfile(cwd{sub},SPM.VResMS.fname);
   end

   %- Load design matrix of the first subject
   %--------------------------------------------------------------------
   
   load(fullfile(cwd{1},'SPM.mat'));
   xX		= SPM.xX;
   Filter	= SPM.xX.K;
   W		= SPM.xX.W;
  	
   
   %- Load the contrast
   %--------------------------------------------------------------------

   
   arg=mm_load_arg('Ci');
   arg.Ci.input.SPM=SPM; 
   arg.Ci.input.xCon=SPM.xCon; 
   arg 	= ui_arg(arg,'Ci');
   [Ic,SPM.xCon] 	= deal(arg{:});
   xC 		= SPM.xCon(Ic);
   SPM.xCon=SPM.xCon;
	  
	 % try, fprintf('can not save contrast'); save(cwd{1},'SPM'); catch, fprintf('can not save xCon : check permissions\n'); end;
   
   
   %clear arg SPM


   %- Get images + Mask + ResMS per subject
   %- %--------------------------------------------------------------------
%-    for sub=1:nbsub
%- 
%-    	Mask{sub}   	= fullfile(cwd{sub},'mask.img');
%-    	load(fullfile(cwd{sub},'SPM.mat'),'VResMS');
%-    	Res{sub}	= fullfile(cwd{sub},char(VResMS));
%-    end
%- 
   %- Set number of eigenimages
   %--------------------------------------------------------------------
   arg		= mm_load_arg('leig');
   arg.leig.input.def=['[1:' num2str(min(5,size(Pimg{1},1))) ']'];
   leig 	= ui_arg(arg,'leig');

   %- Set parameters : filtering and divide by std deviation
   %--------------------------------------------------------------------
   paramsAnal.resContSp 	= ui_arg(mm_load_arg('Pres'),'Pres');
   paramsAnal.divideByRessd 	= ui_arg(mm_load_arg('dvres'),'dvres');
 
   paramsAnal.temporalFilter 	= ui_arg(mm_load_arg('filter'),'filter');

elseif isstruct(argfile) %- SPM BATCH MODE
    
    job = argfile;
    
    gcsd = job.god{1};
    nbsub = numel(job.domain);
    
    %- Working directories and eigen image names
    for sub=1:nbsub          
          cwd{sub} = spm_str_manip(job.domain(sub).mod{1},'H'); %#ok<AGROW>
          
          if nbsub > 1
   	         csd{sub} 	= job.domain(sub).iod{1}; %#ok<AGROW>
	      else
	         csd{1}		= gcsd;
          end
   	      fname{sub} = job.domain(sub).neig;
          
          defImg=isfield(job.domain(sub).DefImages, 'UseDefImage');
	      if defImg
		      load(fullfile(cwd{sub},'SPM.mat'));
		      Pimg{sub}=SPM.xY.P %#ok<AGROW>
          else
		      Pimg{sub} 	= job.domain(sub).DefImages.Image; %#ok<AGROW>
          end
          
          gsf{sub}				= SPM.xGX.gSF;
          Mask{sub}   	= fullfile(cwd{sub},'mask.img');
          Res{sub}	= fullfile(cwd{sub},SPM.VResMS.fname);
    end
    
    %- Design matrix and temporal filter
    Pmat = fullfile(cwd{1},'SPM.mat');
    load(Pmat);
    xX = SPM.xX; %#ok<NASGU>
    Filter = SPM.xX.K;
    W = SPM.xX.W;
    
    %- Contrast
	[Ic,xCon] = deal([job.Ci{1}, SPM.xCon]);
   	xC = xCon(Ic);
    
    %- leig
    leig = job.leig;
    
    %- Filtering and divide by std deviation
    paramsAnal.resContSp 	= job.typeanal.svdanal.pres;
    paramsAnal.divideByRessd 	= job.typeanal.svdanal.dvres;
    paramsAnal.temporalFilter 	= job.typeanal.svdanal.filter;
   
else   %- BATCH MODE
 	  [gcsdr cwd csd d fname ImgDir ImgName paramsAnal.temporalFilter paramsAnal.divideByRessd paramsAnal.resContSp ] ...
	  	= textread(argfile,'%s %s %s %d %s %s %s %d %d %d','commentstyle','matlab');
	  
 	  nbsub		= size(cwd,1);
	  gcsd=gcsdr{1}
	  load(fullfile(cwd{1},'SPM.mat'),'xX');
	  Filter	= xX.K;
 	  load(fullfile(cwd{1},'xCon.mat'),'xCon');
	  d = d(1,1);
	  if isempty(d), d=1; end
  	  xC 	= xCon(d);
	  
	 clear xX xCon
	 for sub=1:nbsub
	      [DIn Dsz]	=sf_strsplit(ImgName{sub},';');
		      for i=1:Dsz
			      pimg{i}=fullfile(ImgDir{sub},spm_select('List',ImgDir{sub},str_clean(DIn{i})));
		      end
   	      Pimg{sub} 	= cat(1,pimg{:});
   	      Mask{sub}   	= fullfile(cwd{sub},'mask.img');
   	      load(fullfile(cwd{sub},'SPM.mat'),'VResMS');
   	      Res{sub}	= fullfile(cwd{sub},char(VResMS));
	      load(fullfile(cwd{sub},'SPMcfg.mat'), 'xGX');
       	      gsf{sub}		= xGX.gSF;
	      clear xGX;
	 end
      leig 	= 1:5;	
end



function [res,n]=sf_strsplit(str,fs)

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


