function varargout = mm_writeEigImg(varargin)
% Write Eigen Images
% Format varargout = mm_writeEigImg(varargin)
% see sub-functions for details.
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
		Eig	 	= sf_writeEigImg_mlm(varargin{2:nargin});
		varargout 	= {Eig};
		% varargin	= {cwd, nbsub, Pimg, Res, Mask, NF, u, s, fname, h};

	case 'SVD'
		Eig	 	= sf_writeEigImg_svd(varargin{2:nargin});
		varargout 	= {Eig};
		% varargin	= {cwd, nbsub, Pimg, Res, Mask, NF, ...
		%		   u, ds, fname, h, Filter, paramsAnal}
		
	otherwise
		error('unknown type of analysis')
end
		

%===================================================================

function Eig = sf_writeEigImg_mlm(cwd, nbsub, Pimg, Res, Mask, NF, u, ds, fname, h);
% write eigenimages.
%- Eig : filename of the eigen images.
% Yout output images data
% Yout = u' Z/sqrt(ds(i)), u eigen vector, ds eigen values.
% Yout = u' NF B/Res
%===================================================================
  
  
  holds 	= 0; %- Interpolation method
  [dimp tmp] 	= size(Pimg{1});
  memchunk 	= 2^24;
  sizeVox  	= ceil((memchunk/dimp/8)); % 8 = sizeof(double)
  
  for sub=1:nbsub
    
    V   	= spm_vol(Pimg{sub});
    Vr 		= spm_vol(Res{sub});
    dimx 	= V(1).dim(1);
    dimy 	= V(1).dim(2);
    Vm 		= spm_vol(Mask{sub});
    nbp 	= sizeVox/prod(V(1).dim(1:2));
    nbp 	= min(max(1,round(nbp)),V(1).dim(3));
    Afname	= [];
    
    for U=1:size(u,2)
      
      Afname 	= [Afname; fullfile(cwd{sub},sprintf('%s%03d.img',fname{sub},U))]; % Eigenimage filename 
      Veig=V(1);
         Veig.fname= num2str(Afname(U,:));
%          Veig.dim',  [V(1).dim(1:3)],...
%          'mat',  V(1).mat,...
         Veig.pinfo=[1 0 0]';
         Veig.descrip=sprintf('%s %d','eigenimage',U);
      UMGS(U)    = spm_create_vol(Veig); %- image structure.
      
    end % for U=1:size(u,2)
    
    Eig{sub}	= Afname;
    
    for p = 1:nbp:V(1).dim(3)
      
      plank=length(p:min(p+nbp,V(1).dim(3)));
      endpl	= min(p+nbp-1,V(1).dim(3));	% position of last plane in bunch
      nb_plan 	= endpl - p + 1;
      plm 	= zeros(dimx*dimy,nb_plan);
      idp	= 1;
      fprintf('\r%-20s: ',sprintf('Plane %3d/%-3d ',...
      p,V(1).dim(3)))
      fprintf('%20s',' Reading Mask ');  
      
      for n = p:endpl
        fprintf('%-20s',sprintf('plank %3d/%-3d',...
	        idp,plank))
		fprintf('%s',sprintf('\b')*ones(1,20))
	
	Ma    = spm_matrix([0 0 n]);
        iplm  = spm_slice_vol(Vm,Ma,Vm.dim(1:2),holds);
        plm(:,idp) = iplm(:);idp=idp+1;
      end
      
      plm    	= plm(:) > 0;
      nvox   	= sum(plm); % nombre de voxel
      
      if nvox
        
        BETAp   = zeros(floor(nvox),dimp);
        RES    	= zeros(floor(nvox),1);
	
	fprintf('%s',sprintf('\b')*ones(1,20))
       fprintf('%20s',' Reading data ')
        
        for t = 1:dimp
          plb  	= zeros(dimx*dimy,nb_plan);
          plr 	= zeros(dimx*dimy,nb_plan);
          idp	= 1;
          for n = p:endpl
		  
	   fprintf('%-20s',sprintf('plank %3d/%-3d',...
	   idp,plank))
	   fprintf('%s',sprintf('\b')*ones(1,20))
            Ma    	= spm_matrix([0 0 n]);
            iplb  	= spm_slice_vol(V(t),Ma,V(t).dim(1:2),holds);
            plb(:,idp) 	= iplb(:);
            iplr  	= spm_slice_vol(Vr,Ma,Vr.dim(1:2),holds);
            plr(:,idp) 	= iplr(:);
	    idp		= idp + 1;
          end
          plb		= plb(:);
          BETAp(:,t)   	= plb(find(plm));
          plr		= plr(:);
          RES 		= sqrt(plr(find(plm)));
  	end
  
      end % if nvox

      for U=1:size(u,2)
        fprintf('%20s',sprintf(' writing Img %d',U));
	Yout = zeros(dimx*dimy*nb_plan,1)*nan;
        if nvox
          Yout(plm)= ((NF*BETAp')./(ones(h,1)*RES'))'*u(:,U)/sqrt(ds(U));
        end
        i_plm    = 0;
        for ip = p:endpl
          img 	= reshape(Yout([1:dimx*dimy] + i_plm*dimx*dimy), dimx, dimy);
          spm_write_plane(UMGS(U),img,ip);
          i_plm = i_plm + 1;
        end
        fprintf('%s',sprintf('\b')*ones(1,20))
      end % for U=1:size(u,2)
      
    end % for p = 1:nbp:V(1).dim(3)
    
end
% fprintf('%s',sprintf('\b')*ones(1,80))
% fprintf('%s\r',sprintf(' ')*ones(1,80))


%===================================================================

function Eig = sf_writeEigImg_svd(cwd, nbsub, Pimg, Res, Mask, NF, ...
				u, ds, fname, h, Filter, paramsAnal,gsf);
%===================================================================
  
  
holds 		= 0; %- Interpolation method
[dimt tmp] 	= size(Pimg{1});
memchunk 	= 2^24;
sizeVox  	= ceil((memchunk/dimt/8)); % 8 = sizeof(double)



for sub=1:nbsub

   
   V   	= spm_vol(Pimg{sub});
   Vr 	= spm_vol(Res{sub});
   dimx 	= V(1).dim(1);
   dimy 	= V(1).dim(2);
   Vm 	= spm_vol(Mask{sub});
   nbp 	= sizeVox/prod(V(1).dim(1:2));
   nbp 	= min(max(1,round(nbp)),V(1).dim(3));
   Afname	= [];
   
    sf=gsf{sub}; %scaling factor for the subject sub
       fprintf('\nworking on space domain : %d \n',sub);
      for v=1:dimt
        V(v,1).pinfo(1:2,:) = V(v,1).pinfo(1:2,:)*sf(v,1);
      end

   for U=1:size(u,2)
      
      Afname 	= [Afname; fullfile(cwd{sub}, ...
      		   sprintf('%s%03d.img',fname{sub},U))]; % Eigenimage filename 
      Veig    = struct( ...
      	 'fname',	num2str(Afname(U,:)),...
         'dim',  	[V(1).dim(1:3)],...
         'mat',  	V(1).mat,...
         'type', [spm_type('float') 0],...
         'pinfo', 	[1 0 0]',...
         'descrip', 	sprintf('%s %d','eigenimage',U) );
      UMGS(U)    = spm_create_vol(Veig); %- image structure.
      
   end % for U=1:size(u,2)
    
   Eig{sub}	= Afname;
    
   for p = 1:nbp:V(1).dim(3)

      
      plank=length(p:min(p+nbp,V(1).dim(3)));
      endpl	= min(p+nbp-1,V(1).dim(3));	% position of last plane in bunch
      nb_plan 	= endpl - p + 1;
      plm 	= zeros(dimx*dimy,nb_plan);
      idp	= 1;
      fprintf('\r%-20s: ',sprintf('Plane %3d/%-3d ',...
      p,V(1).dim(3)))
      fprintf('%20s',' Reading Mask ');
      for n = p:endpl
	fprintf('%-20s',sprintf('plank %3d/%-3d\n',idp,plank))
% 		fprintf('%s',sprintf('\b')*ones(1,20))
        Ma    	= spm_matrix([0 0 n]);
        iplm  	= spm_slice_vol(Vm,Ma,Vm.dim(1:2),holds);
        plm(:,idp) = iplm(:);idp=idp+1;
      end
      
      plm    	= plm(:) > 0;
      nvox   	= sum(plm); % nombre de voxel
      
      if nvox
        
        BETA   = zeros(dimt, floor(nvox));
        RES    	= zeros(floor(nvox),1);
% 	fprintf('%s',sprintf('\b')*ones(1,20))
       fprintf('%20s',' Reading data ')
        
        for t = 1:dimt
          plb  	= zeros(dimx*dimy,nb_plan);
          plr 	= zeros(dimx*dimy,nb_plan);
          idp	= 1;
          for n = p:endpl
	    fprintf('%-20s',sprintf('plank %3d/%-3d',...
	   idp,plank))
	   fprintf('%s',sprintf('\b')*ones(1,20))
            Ma    	= spm_matrix([0 0 n]);
            iplb  	= spm_slice_vol(V(t),Ma,V(t).dim(1:2),holds);
            plb(:,idp) 	= iplb(:);
            iplr  	= spm_slice_vol(Vr,Ma,Vr.dim(1:2),holds);
            plr(:,idp) 	= iplr(:);
	    idp		= idp + 1;
          end
          plb		= plb(:);
          BETA(t,:)   	= plb(find(plm))';
          plr		= plr(:);
          RES 		= sqrt(plr(find(plm)));
  	end
  
      end % if nvox

      for U=1:size(u,2)
        fprintf('%20s',sprintf(' writing Img %d',U));
	Yout = zeros(dimx*dimy*nb_plan,1);
        if nvox
	  if paramsAnal.temporalFilter
	     BETA	= spm_filter(Filter,BETA);
	  end
	  if paramsAnal.divideByRessd
	     %BETA	= (NF*BETA)./(ones(h,1)*RES');
	     BETA	= (BETA)./(ones(h,1)*RES');
	  end
          Yout(plm)	= u(:,U)'*BETA/sqrt(ds(U));  
          
	end
	
  
        i_plm    = 0;
        for ip = p:endpl
          img 	= reshape(Yout([1:dimx*dimy] + i_plm*dimx*dimy),dimx,dimy);
          spm_write_plane(UMGS(U),img,ip);
          i_plm = i_plm + 1;
        end
        fprintf('%s',char(sprintf('\b')*ones(1,20)))
      end % for U=1:size(u,2)
      
   end % for p = 1:nbp:V(1).dim(3)
end 



