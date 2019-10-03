function varargout = mm_readData(varargin)
% Compute Dispersion matrix using BETA images (faster).
% Format varargout = mm_readData(varargin)
% 
% see subfunctions for details.
%================================================================================
%-  Copyright (C) 1997-2002 CEA
%-  This software and supporting documentation were developed by
%-       CEA/DSV/SHFJ/UNAF
%-       4 place du General Leclerc
%-       91401 Orsay cedex
%-       France
%================================================================================



if nargin
	typeAnal = varargin{1};
else 
	error('no input argument in mm_model')
end



switch typeAnal
	case 'MLM'
		[Z, Nvox,MU] 	= sf_readData_mlm(varargin{2:nargin});
		varargout 	= {Z, Nvox,MU};
		% varargin	= {NF, h, nbsub, Pimg, Res, Mask};

	case 'SVD'
		[Z, Nvox] 	= sf_readData_svd(varargin{2:nargin});
		varargout 	= {Z, Nvox};
		% varargin	= {NF, h, nbsub, Pimg, Res, Mask, Filter, paramsAnal}
		
	otherwise
		error('unknown type of analysis')
end
		

%===================================================================

function [Z, Nvox,MU] = sf_readData_mlm(NF, h, nbsub, Pimg, Res, Mask);
%
% Read data for the multivariate analysis.
% FORMAT [Z,Nvox] = tt_readData(NF,h,nbsub, Pimg, Res,Mask);
% Z normalized input data: Z=(X'G V XG)-1/2 X'G YG/Res
% M-1/2=(X'G V XG)-1/2
% Z=M-1/2 X' RG X B/Res with RG projection operator and B the beta values computed by spm 
% NF=M-1/2 X' RG X then Z=NF B./ Res.
%===================================================================

hold	= 0;
nvox	= 0; 	% total number of voxel 
Z	= zeros(h,h);
Nvox	= 0;
 
%- Load the BETA values for each subjects
%--------------------------------------------------------------------

[dimt tmp] 	= size(Pimg{1});
memchunk 	= 2^24;
sizeVox  	= ceil((memchunk/dimt/8)); % 8 = sizeof(double)


for sub=1:nbsub	
	
	V  	= spm_vol(Pimg{sub});
	Vr	= spm_vol(Res{sub});
	dimx	= V(1).dim(1);
	dimy	= V(1).dim(2);
        Vm	= spm_vol(Mask{sub});
	nbp 	= sizeVox/prod(V(1).dim(1:2));
	nbp 	= min(max(1,round(nbp)),V(1).dim(3));
	
	Nvox(sub)=0;
	MU{sub}=zeros(1,h);
	for p = 1:nbp:V(1).dim(3)
               
	       	nb_plan = min(p+nbp-1,V(1).dim(3)) - p + 1;
	       	plm	= zeros(dimx*dimy,nb_plan);
		nnn(p)	= nb_plan;
		plank=length(p:min(p+nbp,V(1).dim(3))); 
		idp	= 1;
		fprintf('\r%-20s: ',sprintf('Plane %3d/%-3d ',...
                p,V(1).dim(3)))
		fprintf('%20s',' Reading Mask ');  
	      	for n =  p:min(p+nbp-1,V(1).dim(3))
		fprintf('%-20s',sprintf('plank %3d/%-3d',...
	        idp,plank))
		fprintf('%s',sprintf('\b')*ones(1,20))
		  Ma    	= spm_matrix([0 0 n]);
		  iplm  	= spm_slice_vol(Vm,Ma,Vm.dim(1:2),hold);
		  plm(:,idp) 	= iplm(:);
		  idp		= idp + 1;
	      	end
		
	      	plm   		= plm(:) > 0;
	      	nvox  		= sum(plm); % nombre de voxel
	      	Nvox(sub)	= Nvox(sub) + nvox;
	      
	        if nvox
	   
	      	  BETAp  	= zeros(floor(nvox),dimt);
	      	  RES   	= zeros(floor(nvox),1);
		  
		fprintf('%s',sprintf('\b')*ones(1,20))
		fprintf('%20s',' Reading data ')


	          for t = 1:dimt
		     plb	= zeros(dimx*dimy,nb_plan);
		     plr	= zeros(dimx*dimy,nb_plan);
		     idp	= 1;
		     for n = p:min(p+nbp-1,V(1).dim(3))
		        
			fprintf('%-20s',sprintf('plank %3d/%-3d',...
			idp,plank))
			fprintf('%s',sprintf('\b')*ones(1,20))
		     
		        Ma    = spm_matrix([0 0 n]);
		        iplb  = spm_slice_vol(V(t),Ma,V(t).dim(1:2),hold);
		        plb(:,idp) = iplb(:);
		        iplr  = spm_slice_vol(Vr,Ma,Vr.dim(1:2),hold);
		        plr(:,idp) = iplr(:);idp=idp+1;
		     end
		     plb	= plb(:);
		     BETAp(:,t) = plb(find(plm));
		     plr	= plr(:);
		     RES 	= sqrt(plr(find(plm)));
	          end
		  fprintf('%20s',' transposing ');
		  A= ((NF*BETAp')./(ones(h,1)*RES'))';
		  MU{sub} = MU{sub} + sum(A);
% 		  Z	= spm_atranspa(real(A)) + Z;
          tmpz	= A'*A + Z;
          Z=tmpz;

		  fprintf('%s',sprintf('\b')*ones(1,20))
	  
	        end % if nvox
	     
  	end % for p = 1:nbp:V(1).dim(3)
%MU{sub}=MU{sub}/Nvox(sub)
	
end % for sub=1:nbsub
MU{sub}=MU{sub}/Nvox(sub);
fprintf('%s',sprintf('\b')*ones(1,80))
fprintf('%s\r',sprintf(' ')*ones(1,80))





%===================================================================
function [Z, Nvox] = sf_readData_svd(NF, h, nbsub, Pimg, Res, Mask, Filter, paramsAnal);
%
% Read data for the multivariate analysis.
% FORMAT [Z,Nvox] = tt_readData(NF,h,nbsub, Pimg, Res,Mask);
% Z normalized input data: Z=(X'G V XG)-1/2 X'G YG/Res
% M-1/2=(X'G V XG)-1/2
% Z=M-1/2 X' RG X B/Res with RG projection operator and B the beta values computed by spm 
% NF=M-1/2 X' RG X then Z=NF B./ Res.
%===================================================================

hold	= 0;
nvox	= 0; 	% total number of voxel 
Z	= zeros(h,h);
Nvox	= 0;
 
%- Load the BETA values for each subjects
%--------------------------------------------------------------------

[dimt tmp] 	= size(Pimg);
memchunk 	= 2^24;
sizeVox  	= ceil((memchunk/dimt/8)) % 8 = sizeof(double)

	
V  	= spm_vol(Pimg);
Vr	= spm_vol(Res);
dimx	= V(1).dim(1);
dimy	= V(1).dim(2);
Vm	= spm_vol(Mask);
nbp 	= sizeVox/prod(V(1).dim(1:2));
nbp 	= min(max(1,round(nbp)),V(1).dim(3));
Nvox	= 0;
	
for p = 1:nbp:V(1).dim(3)

       	nb_plan = min(p+nbp-1,V(1).dim(3)) - p + 1;
       	plm	= zeros(dimx*dimy,nb_plan);
	nnn(p)	= nb_plan;
	idp	= 1;
		
      	for n =  p:min(p+nbp-1,V(1).dim(3))
	  Ma    	= spm_matrix([0 0 n]);
	  iplm  	= spm_slice_vol(Vm,Ma,Vm.dim(1:2),hold);
	  plm(:,idp) 	= iplm(:);
	  idp		= idp + 1;
     	end
		
      	plm   	= plm(:) > 0;
      	nvox  	= sum(plm); % nombre de voxel
      	Nvox	= Nvox + nvox;
      
        if nvox
	   
      	  BETAp	= zeros(floor(nvox),dimt);
      	  RES	= zeros(floor(nvox),1);
	  
          for t = 1:dimt
	     plb	= zeros(dimx*dimy,nb_plan);
	     plr	= zeros(dimx*dimy,nb_plan);
	     idp	= 1;
	     for n = p:min(p+nbp-1,V(1).dim(3))
	        Ma    = spm_matrix([0 0 n]);
	        iplb  = spm_slice_vol(V(t),Ma,V(t).dim(1:2),hold);
	        plb(:,idp) = iplb(:);
	        iplr  = spm_slice_vol(Vr,Ma,Vr.dim(1:2),hold);
	        plr(:,idp) = iplr(:);idp=idp+1;
	     end
	     plb	= plb(:);
	     BETAp(:,t) = plb(find(plm));
	     plr	= plr(:);
	     RES 	= sqrt(plr(find(plm)));
     	  end
     
	  if paramsAnal.temporalFilter
	     BETA	= spm_filter('apply',Filter,BETAp');
	  end
	     
	  if paramsAnal.divideByRessd
	     Z	= spm_atranspa(((NF*BETA)./(ones(h,1)*RES'))') + Z;
	  else 
	     Z	= spm_atranspa(NF*BETA) + Z;
	  end
        end % if nvox
	     
end % for p = 1:nbp:V(1).dim(3)
	



%- Mask loading 
%--------------------------------------------------------------------

%- for sub=1:nbsub	 
%- 	 Vm	= spm_vol(Mask{sub});
%- 	 plm	= zeros(Vm(1).dim(1)*Vm(1).dim(2),Vm(1).dim(3));
%- 	 for n = 1:Vm.dim(3)
%- 	   Ma    = spm_matrix([0 0 n]);
%- 	   iplm  = spm_slice_vol(Vm,Ma,Vm.dim(1:2),hold);
%- 	   plm(:,n) = iplm(:);
%- 	 end
%- 	 plm		= plm(:) > 0;
%- 	 Nvox(sub)	= sum(plm);
%- 	 nvox		= nvox + sum(plm); % nombre de voxel
%-  end
