function mmArg = mm_load_arg(arg)
% definition and description of the input arguments for MLM/SVD analysis.
% To be use with ui_arg (interactive argument setting)
% Format mmArg=load_arg(arg)
% arguments : 
%        typeanal	 :     type of anlysis
%        nbsub		 :     number of subject
%        god		 :     global output directory
%        iod		 :     indv output directory
%        mod		 :     Model
%        neig		 :     eigen name
%        Cm		 :     Contrast matrix
%        Ci		 :     Contrast vector
%        Pres		 :     Project in the residual space
%        dvres		 :     Divide by res
%================================================================================
%-  Copyright (C) 1997-2002 CEA
%-  This software and supporting documentation were developed by
%-       CEA/DSV/SHFJ/UNAF
%-       4 place du General Leclerc
%-       91401 Orsay cedex
%-       France
%================================================================================


	
if (nargin <1) arg = 'all'; end
%====================================================================
% Global title	
	mmArg.title 	= 'MULTIVARIATE METHODS';
	list_arg={...
		 'start',...		% Start GUI
		 'typeanal',...		% Type of anlysis.
		 'nbsub',...		% Number of subject
		 'god',...		% Global output directory.
		 'iod',...		% Indv output directory
		 'mod',...		% Model
		 'neig',...		% Eigen name
		 'Cm',...		% Contrast matrix
		 'Ci',...		% Contrast vector
		 'leig',...		% Number of eigenimage
		 'Pres',...		% Project in the residual space
		 'filter',...		% Apply filter
		 'GSF',...		% Apply GSF
		 'dvres',...		% Devide by res
		 'defImages',...	% Used default images set in VY variable (SPM.mat).
		 'Image'...		% Images
	};
	if strcmp(arg,'all')
		for i=1:length(list_arg)
			mmArg=sf_mm_load_arg(mmArg,list_arg{i});
		end
	else
		mmArg=sf_mm_load_arg(mmArg,arg);
	end


function mmArg=sf_mm_load_arg(mmArg,arg)
switch arg
%====================================================================
case 'start'					      %start GUI
	mmArg.start.prompt	='startup ... ';
	mmArg.start.ProgType 	='choice';
	mmArg.start.description = {...
	' __  __						    '
	'(  \/  )						    '
	' )    (ULTIVARIATE					    '
	'(_/\/\_)						    '
	' __  __						    '
	'(  \/  )						    '
	' )    (ETHODS  					    '
	'(_/\/\_)						    '
	'_____________________________________________________________________'
	'MULTIVARIATE METHODS is a package for fMRI/PET data analysis'
	'developed by the Models and Data Analysis group at SHFJ/CEA'
	' Main Author : Ferath Kherif. Other : JB Poline '
	' This is a ALPHA VERSION '
 	' Please do not distribute and redirect requests for the toolbox to' 
 	' us. For bugs, remarks, additions, etc, please contact jbp at '
 	' poline@shfj.cea.fr.'
 	' If you are using this material for publication,'  
 	' please see with us how you can acknowledge our work.' 
	''
	' '
	' WARNING : THIS SOFTWARE IS DISTRIBUTED FREE WITHOUT ANY GUARANTY !'
	'_____________________________________________________________________'  
	'This package is intented for computing and visualizing '
	'Multivariate analysis.'	
	'See the help documents for how to use it .             '	   
	''
	''};
	mmArg.start.input.label='Results|Compute';
	mmArg.start.input.prompt='Show  previous results  or launch new analysis';

	
		
%====================================================================
case 'typeanal'					      % type of anlysis.
	mmArg.typeanal.prompt		= 'start analysis ... ';
	mmArg.typeanal.ProgType 	='choice';
	mmArg.typeanal.description 	= {...
	' Multivariate  Methods :            '  
	' Choose SVD to perform SVD (eg PCA) analysis.             '    
	' Choose MLM for  multivariate linear models.               '
	' Further information can be found in the html help document.'
	' For more advanced disscussion see Worsley 97'
	' (Neuroimage 1997 Nov;6(4):305-19) ' 
	' '};
	mmArg.typeanal.input.label	='MLM|SVD';
	mmArg.typeanal.input.prompt	='type of analysis ?';
	
%====================================================================
case 'nbsub'					   % number of subject
	
	mmArg.nbsub.prompt		= 'space domains ...';
	mmArg.nbsub.ProgType		= 'edit';
	mmArg.nbsub.description		= {...
	'Choose the number of space domains (with identical time domains) for this analysis   '
	'This corresponds to the number of SPM analyses that have previously '
	'been done and that will be included in the multivariate computations '
	'(e.g. this number is 1 for fixed effect analysis - and in fact is generally 1 ...)' };
	mmArg.nbsub.input.etype		= 'evaluated';
	mmArg.nbsub.input.prompt	= 'number of analyses ?';
	mmArg.nbsub.input.def		= 1;

%====================================================================
case 'god'				    % global output directory.

	mmArg.god.prompt		= 'global subjects results ...';
	mmArg.god.ProgType		= 'dir';
	mmArg.god.description		= {...
	'Select a directory. Global results concerning the MM analysis   '
	'will be saved in this directory.                          ' 
	'You must have write permissions on this directory'};
	mmArg.god.input.prompt		= '';

%====================================================================
case 'iod'				       % indv output directory	
	
	mmArg.iod.prompt	= 'individual space domain results ...';
	mmArg.iod.ProgType	= 'dir';
	mmArg.iod.description	= {...
	'Select a directory. Results concerning this specific space domain '
	'will be saved in this directory                          ' };
	mmArg.iod.input.prompt	= '';

%====================================================================
case 'mod'						       % Model
	
	mmArg.mod.prompt	= 'Model setting...';
	mmArg.mod.ProgType	= 'file';
	mmArg.mod.description	= {...
	'Select a SPM.mat matrix. This will define an experimental model '
	'that will be used to either remove some components of no interest '
	'or to reduce the data to the part that correlates with part of '
	'this model (projection onto some space of interest). '
	};
	mmArg.mod.input.prompt	= '';
	mmArg.mod.input.filter	= 'SPM.mat';
	mmArg.mod.input.nb	= '1';
	
%====================================================================
case 'neig' 					  % eigen name
	
	mmArg.neig.prompt	= 'EigenImage...';
	mmArg.neig.ProgType	= 'edit';
	mmArg.neig.description	= {...
	'Choose the base-name for the output eigen image   ' 
	'Eigenimages will be named "base-name"NNNN where NNNN '
	'is the eigen image number' 
	};
	mmArg.neig.input.etype	= 'string';
	mmArg.neig.input.prompt	= 'basename ';
	mmArg.neig.input.def	= 'eigen';
%====================================================================
case 'Cm'					     % Contrast matrix
	
	mmArg.Cm.prompt		= 'Contrast Matrix...';
	mmArg.Cm.ProgType	= 'file';
	mmArg.Cm.description	= {...
	'Select a contrast matrix that corresponds to the SPM.mat chosen :'
	};
	mmArg.Cm.input.prompt	= '';
	mmArg.Cm.input.filter	= 'xCon.mat';
	mmArg.Cm.input.nb 	= '1';
%====================================================================
case 'Ci'					     % Contrast vector
	
	mmArg.Ci.prompt		= 'Contrast ...';
	mmArg.Ci.ProgType	= 'contrast';
	mmArg.Ci.description	= {...
	'Select a contrast:                                       '
	'for data projection onto a subspace (removing effect of no interest'
	'or selecting effect of interest) with the selection of an appropriate contrast '
	'(For instance, choose a contrast that selects the block effects to remove them '
	'in a further SVD analysis)'
	};
	mmArg.Ci.input.prompt	= '';
	

%====================================================================
case 'leig'					% number of eigenimage
	
	mmArg.leig.prompt	= 'EigenImage ...';
	mmArg.leig.ProgType	= 'edit';
	mmArg.leig.description	= {...
	'Choose the number of eigenimage to be saved.            '
	'You can choose a small number, 5 is generally enough to start with '
	'Type for example 1:5 to save the first 5 eigenimages '
	'You will be given later the possibillty to compute a new set of eigenimage.'
	};
	mmArg.leig.input.etype	= 'evaluated';
	mmArg.leig.input.prompt	= 'number of eigenImage?';
	mmArg.leig.input.def	= '1:5';

	
%====================================================================
case 'Pres'			       % Project in the residual space
	
	mmArg.Pres.prompt	= 'residual space ...';
	mmArg.Pres.ProgType	= 'choice';
	mmArg.Pres.description	= {...
	'Choose yes if you want to perform the analysis     '
	'in the residual space. This means that the part of the data that correlates '
	'with    X*c     where c is your contrast (possibly multidimensional) and '
	'X is the design matrix will be removed.'
	'                                                   '};
	mmArg.Pres.input.label	= 'Yes|No';
	mmArg.Pres.input.values	= [1 0];
	mmArg.Pres.input.prompt	= 'Project in residual space';
	
	
%====================================================================
case 'filter'					        % Apply filter	
	
	mmArg.filter.prompt	= 'Apply filter ...';
	mmArg.filter.ProgType	= 'choice';
	mmArg.filter.description= {...
	'Choose yes if you want to filter the data by the temporal '
	'filter that was used in the initial SPM analysis. In general '
	'this is adviced unless you know exatly what you''re doing because'
	'the model used to project the data onto a subspace has also been'
	'temporally filtered'
	'                                                   '};
	mmArg.filter.input.label	= 'Yes|No';
	mmArg.filter.input.values	= [1 0];
	mmArg.filter.input.prompt	= 'Filter ?';


%====================================================================
case 'GSF'					        % Apply GSF	
	
	mmArg.GSF.prompt	= 'Use gSF ...';
	mmArg.GSF.ProgType	= 'choice';
	mmArg.GSF.description= {...
	'Choose yes if you want to use gSF the data  '
	' '
	''
	''
	''
	'                                                   '};
	mmArg.GSF.input.label	= 'Yes|No';
	mmArg.GSF.input.values	= [1 0];
	mmArg.GSF.input.prompt	= ' Use gSF?';
	
%====================================================================
case 'dvres'					       % Devide by res	
	
	mmArg.dvres.prompt	= 'normalize by residuals SD ...';
	mmArg.dvres.ProgType	= 'choice';
	mmArg.dvres.description	= {...
	'choose yes if you want to normalize the data     '
	'voxel per voxel by the estimate of the residual standard deviation'
	'                                                   '};
	mmArg.dvres.input.label	= 'Yes|No';
	mmArg.dvres.input.values=[1 0];
	mmArg.dvres.input.prompt='normalize ?';
%====================================================================
case 'DefImages'					       % default images	
	
	mmArg.DefImages.prompt	= 'Data Image: Use default location ?';
	mmArg.DefImages.ProgType	= 'choice';
	mmArg.DefImages.description	= {...
	'Default : use images defined by SPM analysis (stored in the SPM.mat file).'
	'Choose manually: to enter manually the location of images. '
	''};
	mmArg.DefImages.input.label	= 'Use default|Choose manually';
	mmArg.DefImages.input.values=[1 0];
	mmArg.DefImages.input.prompt='';
	
%====================================================================
case 'Image'					     % Contrast matrix
	
	mmArg.Image.prompt	= 'Data Image...';
	mmArg.Image.ProgType	= 'file';
	mmArg.Image.description	= {...
	'choose the functional images to work on:'
	'                                  ' };
	mmArg.Image.input.prompt= '';
	mmArg.Image.input.filter= 'img';
	

%====================================================================
otherwise
	
	fprintf('\n typeanal :     type of anlysis		   ');
	fprintf('\n nbsub    :     number of subject		   ');
	fprintf('\n god      :     global output directory	   ');
	fprintf('\n iod      :     indv output directory	   ');
	fprintf('\n mod      :     Model			   ');
	fprintf('\n neig     :     eigen name			   ');
	fprintf('\n Cm       :     Contrast matrix		   ');
	fprintf('\n Ci       :     Contrast vector		   ');
	fprintf('\n Pres     :     Project in the residual space  ');
	fprintf('\n dvres    :     Divide by res                  ');
	
	
end		
