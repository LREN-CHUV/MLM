function  MM(typeAnal,argfile)
% Multivariate Methods. General multivariate tool. 
%  Contains different procedures to explore FMRI or PET DATA
% format [ds,u,Nvox] = MM(argfile,typeAnal) 
% 
% - INPUT   typeAnal: type of analyse: MLM or SVD.
%          argfile (optional) : batch file.
%          There is yet no documentation for the batch files ...
% 
% - OUTPUT   write eigenimages, other results are saved in MLM.mat or SVD.mat. 
%           Results can be be explored using the user interface function, mm_ui.
%
%
% 
% The standard way of using the MM package is to first perform a standard spm analysis,
% that will provide a first apriori model and the corresponding estimated parameters
% and residual sum of square images. As the temporal filter or the normalisation chosen 
% is of importance, please keep in mind the parameters used for a meaningful interpretation
% of your MM results.
% 
% MM embeds the concept of several spatial space such that if the regression model
% is performed separately on several subjects (1..N) or regions of interest have the same 
% temporal space, MM allows you to consider your data as a matrix with dimension
% common-time-dim X (subject1-space-dim + subject2-space-dim +  ... + subjectN-space-dim)
% In such a case, the result of the analysis for the first component is one time
% dimension eigen vector and one space dimension vector with size :
% (subject1-space-dim + subject2-space-dim +  ... + subjectN-space-dim), 
% which can also be considered as one eigenimage per subject (or region of interest).
%  
% More often, the MM is performed on a matrix with dimension
% (subject1-time-dim + subject2-time-dim +  ... + subjectN-time-dim) X common-space-dim
% 
% 1) SVD analysis:   Given image files and a contrast of a general linear model, 
% 		     this procedure  perform PCA analysis on the projected data 
%		     in the sub-space defined by the contrast. 
%		     orthogonal projection allow to study the residual part of a model. 
% 		     
% 2) MLM analysis: Given Beta images and a contrast of a general linear model this procedure
%  		    allow to study the relatiom between the data and the model.
% 		    MLM is adapted from Worsley et al (1997).
% 
%----- References ----------
% MLM : Worsley KJ, Poline JB, Friston KJ, Evans AC.
% "Characterizing the response of PET and fMRI data using multivariate linear models."
% Neuroimage 1997 Nov;6(4):305-19  
% SVD :  K.J. Friston, J.-B. Poline, S. Strother, A.P. Holmes, C.D. Frith, et
% R.S.J.  Frackowiak, "A multivariate analysis of PET activation
% studies" Human brain mapping. 4:140-151, 1996.
%
%================================================================================
% CREDITS
%
% This package was developped by Ferath Kherif primarily
% with some help from Jean-Baptiste Poline, Guillaume Flandin and Philippe Ciuciu.
% FK, JBP, PC are at the SHFJ-CEA in Orsay, France. GF is at EPIDAURE-INRIA, 
% Sophia Antipolis, France, and at the SHFJ-CEA (year 2001).
% 
% A number of functions used in the toolbox belong to the SPM core package from the
% Wellcome Department of Cognitive Neurology, (also distributed under GNU General 
% Public License). See www.fil.ion.ucl.ac.uk
%
% COPYING / DISTRIBUTING
%
% You can redistribute it and/or modify it under the terms of the GNU General Public
% License version 2 as published by the Free Software Foundation, which is displayed 
% in the accompanying COPYING file. See the GNU General Public License for more
% details. 
%
% Please redirect requests for the toolbox to us. For bugs, remarks, additions, 
% etc, please contact 
%                          mm@madic.org
% 
% If you are using this material for publication, please see with us how you can 
% acknowledge our work.
%
%================================================================================
% WARNING : THIS SOFTWARE IS DISTRIBUTED FREE WITHOUT ANY GUARANTY ! 
%================================================================================
%================================================================================
%-  Copyright (C) 1997-2002 CEA
%-  This software and supporting documentation were developed by
%-       CEA/DSV/SHFJ/UNAF
%-       4 place du General Leclerc
%-       91401 Orsay cedex
%-       France
%================================================================================
% Uptaed version 2019

 if nargin == 0
	 start = ui_arg(mm_load_arg('start'),'start');
	 switch start
	 	case 'Results'
			mm_ui;
			return;
		case 'Compute'
			typeAnal = ui_arg(mm_load_arg('typeanal'),'typeanal');
	 		MM(typeAnal, []);
	 		return;
		end
	 
 end
 
 if nargin == 1
	 argfile = '';
 end


%--------------------------------------------------------------------
%- Start Here
%--------------------------------------------------------------------
	 
		 	 
disp('___________________________________________________________')
disp(' __  __                                                    ')
disp('(  \/  )                                                   ')
disp(' )    (ULTIVARIATE                                         ')
disp('(_/\/\_)                                                   ')
disp(' __  __                                                    ')
disp('(  \/  )                                                   ')
disp(' )    (ETHODS                                              ')
disp('(_/\/\_)                                                   ')
disp('___________________________________________________________')
	 

drawnow % flushes the event queue


%--------------------------------------------------------------------
%- Define structure for MLM or SVD paramters and results
%--------------------------------------------------------------------


switch typeAnal
	
	case 'MLM'

		MLM = struct(...
		   'Res', [],...        %- filename of ResMS image
		   'Mask', [],...       %- filename of Mask image
		   'xC', [],...         %- contrast 
		   'sXG', [],...	%- space of interest (def orthogonal to the space of non-interest)
		   'ds', [],...         %- eigen values
		   'u',[],...           %- eigen vector
		   'Y',[],...		%- observed temporal reponse 
		   'y',[],...		%- predicted temporal reponse
		   'Eig',[],...         %- filename of eigen images
		   'lEig',[],...        %- link between eigen vectors and saved eigenimages.  
		   'M12',[],...         %- square root of (X'G V XG)
		   'Nvox',[],...        %- total number of voxel
		   'NF',[],...          %- matrix of normalisation
		   'stat',[],...        %- used by stat computation
		   'description',[],...
		   'paramsAnal',[],...  %- Parameters 
		   'gSF',[]) ;          %- global scaling factor

	case 'SVD'
		SVD = struct(...
		   'Res', [],...        %- filename of ResMS image
		   'Mask', [],...       %- filename of Mask image
		   'xC', [],...         %- contrast 
		   'xX', [],...	        %- design matrix
		   'ds', [],...         %- eigen values
		   'u',[],...           %- eigen vector
		   'v',[],...           %- eigen vector
		   'Eig',[],...         %- filename of eigen images
		   'LEig',[],...        %- link between eigen vectors and saved eigenimages.
		   'M12',[],...         %- square root of (X'G V XG)
		   'Nvox',[],...        %- total number of voxel
		   'NF',[],...          %- matrix of normalisation
		   'description',[],...
		   'paramsAnal',[],...  %- Parameters
		   'gSF',[]) ;          %- global scaling factor
	otherwise
		error('unknown type of analysis')
end
	

%--------------------------------------------------------------------
%- Load input argument for the analysis 
%--------------------------------------------------------------------

switch typeAnal

   case 'MLM'
	[nbsub, Pimg, Res, Mask, Yimg, gcsd, cwd, csd, xC, ...
			fname, gsf, Filter, leig, paramsAnal, W] = mm_arg(typeAnal, argfile);
	%- nbsub 	: number of subject
	%- Pimg 	: images filename, input data for the svd computation
	%- cwd		: SPM.mat directory 
	%- csd		: directory for saving results
	%- Xc 		: contrast.  
	%- argfile 	: parameter file 
	
    case 'SVD'
	[nbsub, Pimg, Res, Mask, gcsd, cwd, csd, xC, ...
			Filter, paramsAnal, fname, leig, gsf, W] = mm_arg(typeAnal, argfile);
    otherwise
		error('unknown type of analysis')
end


%--------------------------------------------------------------------
%- Set the model, the sub-space of interest and the normalised mtrix 
%--------------------------------------------------------------------

%- nu, h, d : degrees of freedom
%- NF : matrix of normalisation

fprintf('%s%s%s\n','............init ',typeAnal,' Analysis');
switch typeAnal
	case 'MLM'
		[NF, nu, h, d, M12, XG, sXG] = mm_model(typeAnal, cwd, nbsub, xC);
	case 'SVD'
		[NF, h, RNF] = mm_model(typeAnal, cwd, xC,paramsAnal);
	otherwise
		error('unknown type of analysis')
end



%--------------------------------------------------------------------
%-  compute Y'*Y, for each subject if not exist.
%--------------------------------------------------------------------
flag_gsf=1;
%flag_gsf = ui_arg(mm_load_arg('GSF'),'GSF');

fprintf('%-40s\n','Initialising data covariance matrix') 
for sub=1:nbsub
    flag_ypy = 1;
    if ~exist(fullfile(cwd{sub},'YpY.mat'))
	    flag_ypy = 0;
    else 
	    s_ypy=load(fullfile(cwd{sub},'YpY.mat'),'paramsAnal');
	    fprintf('%-40s\n','Found already computed matrix')
	    fprintf('%-40s\n',['check:' fullfile(cwd{sub},'YpY.mat')])
	    if s_ypy.paramsAnal.divideByRessd ~= paramsAnal.divideByRessd
		    flag_ypy = 0;
	    end

	    if s_ypy.paramsAnal.temporalFilter ~= paramsAnal.temporalFilter
	    	    flag_ypy = 0;
	    end
		
   end
   
    if ~flag_ypy;
	fprintf('%-40s\n','Parameters are different: recompute data covariance matrix  ')    
	switch typeAnal
	   case 'SVD' 
	   	 
		 
		 
	    	[YpY,nvox]	= mm_cpypy(typeAnal,1, Pimg(sub), Mask(sub), Res(sub),...
				       paramsAnal, gsf(sub), Filter,W);
	    	save(fullfile(cwd{sub},'YpY.mat'), 'YpY', 'nvox','paramsAnal');
	    
	  case 'MLM'
	  	
	  	[YpY,nvox] = mm_cpypy(typeAnal,1, Yimg(sub), Mask(sub), Res(sub),...
				       paramsAnal, gsf, Filter,W);
	  	save(fullfile(cwd{sub},'YpY.mat'), 'YpY', 'nvox','paramsAnal');
	  end
	  
    end
end
	
	
%--------------------------------------------------------------------
%- Load the Data, compute Z = NF'*Y'*Y*NF
%--------------------------------------------------------------------


switch typeAnal
  case 'MLM'
	fprintf('%-60s\n','Computing parameters covariance matrix') 
	[Z, Nvox,MU] = mm_readData(typeAnal, NF, h, nbsub, Pimg, Res, Mask);
	
  case 'SVD'
	Z	= zeros(size(Pimg{1},1));
	for sub=1:nbsub
		load(fullfile(cwd{sub},'YpY.mat'));
		Nvox(sub) 	= nvox;
		
		% NS{sub} = sum(sum(RNF.*YpY));
		% YpY		= YpY/nvox;
		Z 	  	= YpY + Z;
	end	
	clear YpY nvox;
	Z	= NF*Z*NF';
	
  otherwise
	error('unknown type of analysis')
end


%--------------------------------------------------------------------
%- Compute svd 
%--------------------------------------------------------------------
fprintf('%-40s\n','Computing Principal Components') 
Z	= Z/sum(Nvox);
[u s u] = svd(Z,0);
ds	= diag(s);
clear s;

%--------------------------------------------------------------------
%- STATISTICS if any ...
%--------------------------------------------------------------------

switch typeAnal
	
	case 'MLM'
	   %- Fq : F values for the last q eigein values.
	   %- P  : P values.for the last q eigein values.

	   Fq= zeros(1,h);
	   for q = 0:h-1;
 	    	nu1	= d*(h-q);
	    	nu2	= d*nu - (d-1)*(4*(h-q)+2*nu)/(h-q+2);
	    	Fq(q+1)	= ((nu-2)/nu) * nu2/(nu2-2)*sum(ds(q+1:h))/(h-q);
	   end
	   Pf	= 1 - spm_Fcdf(Fq,round(nu1),round(nu2));
	
	case 'SVD'
	   %- 
	   
	otherwise
		error('unknown type of analysis')
end	    


%--------------------------------------------------------------------
%- Write Images for the results
%--------------------------------------------------------------------

%- Eig 		: eigenimages filenames
%- (by default computes up to 5 images)

fprintf('%-40s\n','writing EigenImage') 
leig 	= leig(find(leig >= 1 & leig <= size(u,2)));

switch typeAnal
  case 'MLM'
	Eig	= mm_writeEigImg(typeAnal, csd, nbsub, Pimg, Res, Mask, NF,...
		       u(:,leig), ds, fname, h);
  case 'SVD'
	 if ~flag_gsf
		 	gsf{sub}=ones(size(gsf{sub}));
	 end
	Eig	= mm_writeEigImg(typeAnal, csd, nbsub, Pimg, Res, Mask, NF,...
		       u(:,leig), ds, fname, h, Filter, paramsAnal,gsf);
    otherwise
	error('unknown type of analysis')
end

%--------------------------------------------------------------------
%- Evaluate predicted and observed temporal reponse
%--------------------------------------------------------------------

switch typeAnal
  case 'MLM'	
	fprintf('%-40s\n','Computing predicted and observed temporal reponse') 

	y	= (pinv(XG)'* M12 * u)*diag(sqrt(ds)); % predicted temporal reponse
	
	RG	= spm_sp('r',sXG);
	for sub=1:nbsub
	       load(fullfile(cwd{sub},'YpY.mat'),'YpY');
	       Y{sub}	= RG*(NF*pinv(XG)*YpY)'*u/diag(sqrt(ds)*sum(Nvox));% observed temporal reponse
	end 
		
  case 'SVD'
	% 
    otherwise
	%error('unknown type of analysis')
end



%--------------------------------------------------------------------
%- Put the result in the MLM/SVD structure.
%--------------------------------------------------------------------

fprintf('\n%-40s\n',sprintf('Saving..... in %s (use mm_ui to explore the results)',gcsd)); 
switch typeAnal
	case 'MLM'
   	   
		MLM.Res		= Res;
		MLM.Mask	= Mask;
		MLM.xC		= xC;
		MLM.ds		= ds;
		MLM.MU		= MU;
		for sub=1:nbsub
			MLM.Pmat{sub}	= fullfile(cwd{sub},'SPM.mat');
		end
		MLM.sXG		= sXG;
		MLM.gSF		= gsf;
		MLM.u		= u;
		MLM.M12		= M12;
		MLM.Eig		= Eig;
		MLM.LEig	= leig;
		MLM.Y		= Y;
		MLM.y		= y;
		MLM.Nvox	= Nvox;
		MLM.NF		= NF;
		MLM.stat	= struct('X1orank',h,'erdf',nu,'ressel',d,'Pf',Pf);
		MLM.paramsAnal  = paramsAnal;
		save(fullfile(gcsd,'MLM.mat') ,'MLM');
   	   
	   
	case 'SVD'
		SVD.Res		= Res;
		SVD.Mask	= Mask;
		SVD.xC		= xC;
		SVD.ds		= ds;
		SVD.NF		= NF;
		for sub=1:nbsub
			SVD.Pmat{sub}	= fullfile(cwd{sub},'SPM.mat');
			SVD.gSF{sub}	= gsf{sub};
		end
		
		SVD.u		= u;
			
		SVD.Eig		= Eig;
		SVD.LEig	=leig;
		SVD.Nvox	= Nvox;
		SVD.paramsAnal  = paramsAnal;
		
		
		save(fullfile(gcsd,'SVD.mat') ,'SVD');

	otherwise
		error('unknown type of analysis')
end	    


%--------------------------------------------------------------------
%--------------------------------------------------------------------
