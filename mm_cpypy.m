function [YpY,Nvox]=mm_cpypy(typeAnal,nbsub,P,Mask,Res,paramsAnal,gsf,K,W)
  
%- compute y'y (time x time) dispersion matrix.
%- Compute only for the voxels in the mask.
%- Data can be filtered or/and normalized.
%- 
%================================================================================
%-  Copyright (C) 1997-2002 CEA
%-  This software and supporting documentation were developed by
%-       CEA/DSV/SHFJ/UNAF
%-       4 place du General Leclerc
%-       91401 Orsay cedex
%-       France
%================================================================================


  
    
  hold=0;   % interpolation method
  sub = 1;  % subject 1
  [dimt tmp] = size(P{1}); % temporal dimension
  Nvox = 0;
  

  %====================================================================
  
  
  
  YpY = zeros(dimt);
  
  memchunk = 2^24; %chunk size
  sizeVox  = ceil((memchunk/(dimt/16))); % 8 = sizeof(double)
  
  for sub=1:nbsub
    
   fprintf('reading  data for subject %03d\n',sub); 
    Nvox(sub)=0;
    
    V  = spm_vol(char(P{sub}));
    
    %-    Normalisation by the scaling factor, if needed
    %--------------------------------------------------------------------
    
       sf=gsf{sub}; %scaling factor for the subject sub
       
      for v=1:dimt
        V(v,1).pinfo(1:2,:) = V(v,1).pinfo(1:2,:)*sf(v,1);
      end

   
    
    
    Vm = spm_vol(Mask{sub}); % Map Mask data
    Vr=spm_vol(Res{sub});    % Map Res data
    
    %compute mean spm_MskMean
      
     
	      
      
    
    
    nbp = sizeVox/prod(V(1).dim(1:2));
    nbp = min(max(1,round(nbp)),V(1).dim(3));
    all_nbp=length(1:nbp:V(1).dim(3));
    
    for p = 1:nbp:V(1).dim(3)
      
      
      % lire le mask pour le chunk p dans plm
      % lire les residu pour le chunk p dans plr
      %---------------------------------------
      nb_plan = min(p+nbp,V(1).dim(3)) - p + 1;
      plank=length(p:min(p+nbp,V(1).dim(3))); 
      dimx=V(1).dim(1);
      dimy=V(1).dim(2);
      
      fprintf('\r%-20s: ',sprintf('Plane %3d/%-3d ',...
          p,V(1).dim(3)))

      
      
      plm     = zeros(dimx*dimy,nb_plan);
      plr = zeros(dimx*dimy,nb_plan);
      i_plm   = 0;
    fprintf('%20s',' Reading Mask ');  
    for ip=p:min(p+nbp,V(1).dim(3))
        i_plm        = i_plm + 1;
	
	fprintf('%-20s\n',sprintf('plank %3d/%-3d',i_plm,plank))
% 	fprintf('%s',sprintf('\b')*ones(1,20))
        Ma           = spm_matrix([0 0 ip]);
        iplm         = spm_slice_vol(Vm,Ma,Vm.dim(1:2),hold);
        plm(:,i_plm) = iplm(:);
        iplr  = spm_slice_vol(Vr,Ma,Vr.dim(1:2),hold);
        plr(:,i_plm) = iplr(:);
      end
      plm   = plm(:) > 0;
      plr = plr(:);
      nvox  = sum(plm); % number of voxel
      Nvox(sub)	= Nvox(sub) + nvox;
      
      if nvox
        
        
        % boucle sur les temps
        %fprintf('%s',sprintf('\b')*ones(1,20))
	fprintf('%20s',' Reading data ')
        Y = zeros(floor(nvox),dimt);
        
        for t = 1:dimt
          pld     = zeros(dimx*dimy,nb_plan);
	  i_plm   = 0;
          
	for ip=p:min(p+nbp,V(1).dim(3))
            
	    
	    
	    i_plm   = i_plm + 1;
	    
	    
	    fprintf('%-20s',sprintf('plank %3d/%-3d',...
		i_plm,plank))
	    fprintf('%s',repmat(sprintf('\b'),1,20))
	    
            Ma      = spm_matrix([0 0 ip]);
            ipld    = spm_slice_vol(V(t),Ma,V(t).dim(1:2),hold);
            pld(:,i_plm) = ipld(:);
          end
          
          pld = pld(:);
          
          Y(:,t) = pld(plm);
          
        end % for t = 1:dimt
        
	
        if paramsAnal.temporalFilter
		%fprintf('%s',sprintf('\b')*ones(1,20))
		fprintf('%20s',' apply  filter ');	
          Y = (spm_filter(K,W*Y'))';
	  %fprintf('%s',sprintf('\b')*ones(1,20))
  	end
  
        if paramsAnal.divideByRessd
		%fprintf('%s',sprintf('\b')*ones(1,20))
		fprintf('%20s',' divide by Ressd ');
          Y = Y./repmat(sqrt(plr(find(plm))),1,dimt);
	  fprintf('%s',sprintf('\b')*ones(1,20))
        end
        %fprintf('%s',sprintf('\b')*ones(1,20))
	fprintf('%20s',' transposing ');
	
%         YpY      = spm_atranspa(real(Y)) + YpY;
          YpY      =Y'*Y+ YpY;
	%fprintf('%s',sprintf('\b')*ones(1,20))
      end %if nvox
    
    end % for p = 1:nbp:V(1).dim(3):
    
  end % for sub=1:nbsub
%fprintf('%s',sprintf('\b')*ones(1,60))
%fprintf('%s\r',sprintf(' ')*ones(1,80))
