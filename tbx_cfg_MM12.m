function MM12 = tbx_cfg_MM12
    if ~isdeployed, addpath(fullfile(spm('dir'),'toolbox','MM12')); end
    
    % pres
    pres         = cfg_menu;
    pres.tag     = 'pres';
    pres.name    = 'Project in residual space';
    pres.help    = {
        'Choose yes if you want to perform the analysis     '
	'in the residual space. This means that the part of the data that correlates '
	'with    X*c     where c is your contrast (possibly multidimensional) and '
	'X is the design matrix will be removed.'
        };
    pres.labels  = {
                    'Yes'
                    'No'
                    }';
    pres.values = {
                    1
                    0
                    }';
    pres.val    = {};
    
    % filter
    filter         = cfg_menu;
    filter.tag     = 'filter';
    filter.name    = 'Filter';
    filter.help    = {
        'Choose yes if you want to filter the data by the temporal '
	'filter that was used in the initial SPM analysis. In general '
	'this is adviced unless you know exatly what you''re doing because'
	'the model used to project the data onto a subspace has also been'
	'temporally filtered'
        };
    filter.labels  = {
                    'Yes'
                    'No'
                    }';
    filter.values = {
                    1
                    0
                    }';
    filter.val    = {};
    
    % GSF
    GSF         = cfg_menu;
    GSF.tag     = 'GSF';
    GSF.name    = 'Use gSF';
    GSF.help    = {
       'Choose yes if you want to use gSF the data  '
        };
    GSF.labels  = {
                    'Yes'
                    'No'
                    }';
    GSF.values = {
                    1
                    0
                    }';
    GSF.val    = {};
    
    % dvres
    dvres         = cfg_menu;
    dvres.tag     = 'dvres';
    dvres.name    = 'Normalize by residuals SD';
    dvres.help    = {
       'choose yes if you want to normalize the data     '
	'voxel per voxel by the estimate of the residual standard deviation'
        };
    dvres.labels  = {
                    'Yes'
                    'No'
                    }';
    dvres.values = {
                    1
                    0
                    }';
    dvres.val    = {};
    
    % mlmanal
    mlmanal = cfg_const;
    mlmanal.tag = 'mlmanal';
    mlmanal.name = 'MLM';
    mlmanal.val = {'MLM'};
    
    % svdanal
    svdanal = cfg_branch;
    svdanal.tag = 'svdanal';
    svdanal.name = 'SVD';
    svdanal.val = {pres filter dvres};
    
    % typeanal
    typeanal         = cfg_choice;
    typeanal.tag     = 'typeanal';
    typeanal.name    = 'Type of analysis';
    typeanal.help    = {
        ' Multivariate  Methods :            '  
	' Choose SVD to perform SVD (eg PCA) analysis.             '    
	' Choose MLM for  multivariate linear models.               ' 
	' Further information can be found in the html help document.' 
	' For more advanced disscussion see Worsley 97' 
	' (Neuroimage 1997 Nov;6(4):305-19) ' 
        };
    typeanal.values = {
                    mlmanal
                    svdanal
                    }';
    typeanal.val    = {};
    
    % god
    god         = cfg_files;
    god.tag     = 'god';
    god.name    = 'Global subjects results ';
    god.help    = {'Select a directory. Global results concerning the MM analysis' 
        'will be saved in this directory' 
        'You must have write permissions on this directory'};
    god.filter = 'dir';
    god.ufilter = '.*';
    god.num     = [1 1];
    
    % iod
    iod         = cfg_files;
    iod.tag     = 'iod';
    iod.name    = 'Individual space domain results';
    iod.help    = {'Select a directory. Results concerning this specific space domain ' 
	'will be saved in this directory'};
    iod.filter = 'dir';
    iod.ufilter = '.*';
    iod.num     = [1 1];
    
    % mod
    mod          = cfg_files;
    mod.tag      = 'mod';
    mod.name     = 'Experimental model';
    mod.help     = {
        'Select a SPM.mat matrix. This will define an experimental model ' 
        'that will be used to either remove some components of no interest ' 
        'or to reduce the data to the part that correlates with part of ' 
        'this model (projection onto some space of interest). '
        }; 
    mod.filter   = 'mat';
    mod.ufilter  = 'SPM.mat';
    mod.num      = [1 1];
    mod.val      = {};
    
    % Cm
    Cm          = cfg_files;
    Cm.tag      = 'Cm';
    Cm.name     = 'Contrast Matrix';
    Cm.help     = {
       'Select a contrast matrix that corresponds to the SPM.mat chosen'
        }; 
    Cm.filter   = 'mat';
    Cm.ufilter  = 'xCon.mat';
    Cm.num      = [1 1];
    Cm.val      = {};
    
    % Ci
    Ci = cfg_entry;
    Ci.strtype = 'n';
    Ci.tag = 'Ci';
    Ci.name = 'Contrast index';
    Ci.help = {
        'Select a contrast:                                       ' 
	'for data projection onto a subspace (removing effect of no interest' 
	'or selecting effect of interest) with the selection of an appropriate contrast ' 
	'(For instance, choose a contrast that selects the block effects to remove them ' 
	'in a further SVD analysis)'
        };
    
    % leig
    leig = cfg_entry;
    leig.tag = 'leig';
    leig.name = 'Number of EigenImages';
    leig.help = {
        'Choose the number of eigenimage to be saved.            ' 
	'You can choose a small number, 5 is generally enough to start with ' 
	'Type for example 1:5 to save the first 5 eigenimages ' 
	'You will be given later the possibillty to compute a new set of eigenimage.'
        };
    leig.strtype = 'e';
    leig.num = [1 Inf];
    leig.val = {1:5};
    
    % neig
    neig = cfg_entry;
    neig.name = 'Eigen images basename';
    neig.tag = 'neig';
    neig.help	= {...
	'Choose the base-name for the output eigen image   ' 
	'Eigenimages will be named "base-name"NNNN where NNNN '
	'is the eigen image number' 
	};
	neig.strtype	= 's';
    neig.num = [1 Inf];
    neig.val = {'eigen'};
    
    % UseDefImage
    UseDefImage = cfg_const;
    UseDefImage.tag = 'UseDefImage';
    UseDefImage.name = 'Default';
    UseDefImage.val = {''};
    
    % ChooseManually
    Image           = cfg_files;
    Image.tag       = 'Image';
    Image.name      = 'Choose manually';
    Image.help      = {
        'choose the functional images to work on:'
        }; 
    Image.filter    = 'image';
    Image.ufilter   = '.*';
    Image.num       = [0 Inf];
    Image.val       = {''};
    
    % DefImages
    DefImages         = cfg_choice;
    DefImages.tag     = 'DefImages';
    DefImages.name    = 'Data Image: Use default location ?';
    DefImages.help    = {
      'Default : use images defined by SPM analysis (stored in the SPM.mat file).'
	'Choose manually: to enter manually the location of images. '
        };
    DefImages.values = {
                    UseDefImage
                    Image
                    }';
    DefImages.val    = {};
    
    
    % domain
    onedomain = cfg_branch;
    onedomain.tag = 'domain';
    onedomain.name = 'Domain';
    onedomain.val = {iod mod neig DefImages};
    
    % subjects
    domains           = cfg_repeat;
    domains.tag       = 'domains';
    domains.name      = 'Domains';
    domains.val       = {onedomain };
    domains.help      = {
        'Choose the number of space domains (with identical time domains) for this analysis   '
	'This corresponds to the number of SPM analyses that have previously '
	'been done and that will be included in the multivariate computations '
	'(e.g. this number is 1 for fixed effect analysis - and in fact is generally 1 ...)'
    };
    domains.values    = {onedomain };
    domains.num       = [1 Inf];
    
    % anal
    anal         = cfg_exbranch;
    anal.tag     = 'anal';
    anal.name    = 'MM12 Analysis';
    anal.help = {
        'MULTIVARIATE METHODS is a package for fMRI/PET data analysis' 
	'developed by the Models and Data Analysis group at SHFJ/CEA' 
    'Main Author : Ferath Kherif. Other : JB Poline' 
       'This is a ALPHA VERSION' 
       'Please do not distribute and redirect requests for the toolbox to' 
       'us. For bugs, remarks, additions, etc, please contact jb at' 
       'poline@shfj.cea.fr. Some of the ideas implemented in the MM toolbox' 
       'have not yet been published. Please refrain from publishing the' 
       'original ideas that can be found here ... If you are using this' 
       'material for publication, please see with us how you can' 
       'acknowledge our work.'};
    anal.val = {typeanal god Ci leig domains};
    anal.prog = @MM5_prog;
    anal.vout = @MM5_vout;
    
    % MM5
    MM12 = cfg_branch;
    MM12.tag = 'MM12';
    MM12.name = 'MM12';
    MM12.val = {anal};
end

function out = MM5_prog(job)
    if isfield(job.typeanal, 'pres')
        MM('SVD', job);
        out=job;
    else
        MM('MLM', job);
        out=job;
    end
end

function dep = MM5_vout(job)
    dep = cfg_dep;
end
