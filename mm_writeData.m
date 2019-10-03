function varargout = mm_writeData(varargin)
%====================================================================
% This package was developped by Ferath Kherif primarily
% with some help from Jean-Baptiste Poline.
% 
% Please do not distribute and redirect requests for the toolbox to 
% us. For bugs, remarks, additions, etc, please contact jb at 
% poline@shfj.cea.fr. 
%====================================================================
% WARNING : THIS SOFTWARE IS DISTRIBUTED FREE WITHOUT ANY GUARANTY ! 
%====================================================================

if nargin
	typeAnal = varargin{1}
else 
	error('no input argument in mm_model')
end


switch typeAnal
	case 'MLM'
		Eig	 	= sf_writeData_mlm(varargin{2:nargin});
		varargout 	= {Eig};
		% varargin	= {cwd, nbsub, Nvox, Pimg, Res, Mask, NF, u, s, fname, h};

	case 'SVD'
		Eig	 	= sf_writeData_svd(varargin{2:nargin});
		varargout 	= {Eig};
		% varargin	= {cwd, nbsub, Nvox, Pimg, Res, Mask, NF, ...
		%		   u, ds, fname, h, Filter, paramsAnal}
		
	otherwise
		error('unknown type of analysis')
end
		

%===================================================================

function Eig = sf_writeData_mlm(cwd, nbsub, Nvox, Pimg, Res, Mask, NF, u, s, fname, h);
% write eigenimages.
%- Eig : filename of the eigen images.
% Yout output images data
% Yout = u' Z/sqrt(ds(i)), u eigen vector, ds eigen values.
% Yout = u' NF B/Res
% FORMAT Eig = tt_writeData(cwd,nbsub, Nvox,Pimg, Res,Mask,NF,u,s,fname,h);
%===================================================================
  
  
  cwd
  2
  
  holds 	= 0; %- Interpolation method
  [dimp tmp] 	= size(Pimg{1});
  memchunk 	= 2^24;
  sizeVox  	= ceil((memchunk/dimp/8)) % 8 = sizeof(double)
  
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
      
      Afname 	= [Afname; fullfile(cwd{sub}, ...
      		   sprintf('%s%03d.img',fname{sub},U))]; % Eigenimage filename 
      UMGS(U)    = struct(  'fname',...
         num2str(Afname(U,:)),...
         'dim',  [V(sub).dim(1:3),spm_type('float')],...
         'mat',  V(sub).mat,...
         'pinfo', V(sub).pinfo',...
         'descrip', sprintf('%s %d','eigenimage',U) );
      UMGS(U)    = spm_create_image(UMGS(U)); %- image structure.
      
    end % for U=1:size(u,2)
    
    Eig{sub}	= Afname;
    
    for p = 1:nbp:V(1).dim(3)
      
      endpl	= min(p+nbp-1,V(1).dim(3));	% position of last plane in bunch
      nb_plan 	= endpl - p + 1;
      plm 	= zeros(dimx*dimy,nb_plan);
      idp	= 1;
      
      for n = p:endpl
        Ma    = spm_matrix([0 0 n]);
        iplm  = spm_slice_vol(Vm,Ma,Vm.dim(1:2),holds);
        plm(:,idp) = iplm(:);idp=idp+1;
      end
      
      plm    	= plm(:) > 0;
      nvox   	= sum(plm); % nombre de voxel
      Nvox(sub) = Nvox(sub) + nvox;
      
      if nvox
        
        BETAp   = zeros(floor(nvox),dimp);
        RES    	= zeros(floor(nvox),1);
        
        for t = 1:dimp
          plb  	= zeros(dimx*dimy,nb_plan);
          plr 	= zeros(dimx*dimy,nb_plan);
          idp	= 1;
          for n = p:endpl
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
        
	Yout = zeros(dimx*dimy*nb_plan,1);
        if nvox
          Yout(plm)= ((NF*BETAp')./(ones(h,1)*RES'))'*u(:,U)/sqrt(s(U,U));
        end
        i_plm    = 0;
        for ip = p:endpl
          img 	= reshape(Yout([1:dimx*dimy] + i_plm*dimx*dimy),dimx,dimy);
          spm_write_plane(UMGS(U),img,ip);
          i_plm = i_plm + 1;
        end
        
      end % for U=1:size(u,2)
      
    end % for p = 1:nbp:V(1).dim(3)
    
end


%===================================================================

function Eig = sf_writeData_svd(cwd, nbsub, Nvox, Pimg, Res, Mask, NF, ...
				u, ds, fname, h, Filter, paramsAnal);
%===================================================================
  
  
holds 	= 0; %- Interpolation method
[dimp tmp] 	= size(Pimg);
memchunk 	= 2^24;
sizeVox  	= ceil((memchunk/dimp/8)) % 8 = sizeof(double)
  
    
V   	= spm_vol(Pimg);
Vr 	= spm_vol(Res);
dimx 	= V(1).dim(1);
dimy 	= V(1).dim(2);
Vm 	= spm_vol(Mask);
nbp 	= sizeVox/prod(V(1).dim(1:2));
nbp 	= min(max(1,round(nbp)),V(1).dim(3));
Afname	= [];
    
    
for U=1:size(u,2)
      
      Afname 	= [Afname; fullfile(cwd, ...
      		   sprintf('%s%03d.img',fname,U))]; % Eigenimage filename 
      UMGS(U)    = struct( ...
      	 'fname',	num2str(Afname(U,:)),...
         'dim',  	[V(1).dim(1:3),spm_type('float')],...
         'mat',  	V(1).mat,...
         'pinfo', 	V(1).pinfo',...
         'descrip', 	sprintf('%s %d','eigenimage',U) );
      UMGS(U)    = spm_create_image(UMGS(U)); %- image structure.
      
end % for U=1:size(u,2)
    
Eig	= Afname;
    
for p = 1:nbp:V(1).dim(3)
      
      endpl	= min(p+nbp-1,V(1).dim(3));	% position of last plane in bunch
      nb_plan 	= endpl - p + 1;
      plm 	= zeros(dimx*dimy,nb_plan);
      idp	= 1;
      
      for n = p:endpl
        Ma    	= spm_matrix([0 0 n]);
        iplm  	= spm_slice_vol(Vm,Ma,Vm.dim(1:2),holds);
        plm(:,idp) = iplm(:);idp=idp+1;
      end
      
      plm    	= plm(:) > 0;
      nvox   	= sum(plm); % nombre de voxel
      Nvox	= Nvox + nvox;
      
      if nvox
        
        BETAp   = zeros(floor(nvox),dimp);
        RES    	= zeros(floor(nvox),1);
        
        for t = 1:dimp
          plb  	= zeros(dimx*dimy,nb_plan);
          plr 	= zeros(dimx*dimy,nb_plan);
          idp	= 1;
          for n = p:endpl
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
        
	Yout = zeros(dimx*dimy*nb_plan,1);
        if nvox
	  if paramsAnal.temporalFilter
	     BETA	= spm_filter('apply',Filter,BETAp');
	  end
	  if paramsAnal.divideByRessd
	     BETA	= ((NF*BETA)./(ones(h,1)*RES'))';
	  end
          Yout(plm)	= BETA*u(:,U)/sqrt(ds(U));  
  	end
  
        i_plm    = 0;
        for ip = p:endpl
          img 	= reshape(Yout([1:dimx*dimy] + i_plm*dimx*dimy),dimx,dimy);
          spm_write_plane(UMGS(U),img,ip);
          i_plm = i_plm + 1;
        end
        
      end % for U=1:size(u,2)
      
end % for p = 1:nbp:V(1).dim(3)




