function EY=mm_cov2(vimg,id,XYZ)
% Compute the dispersion matrix 
% FORMAT EY=mm_cov(vimg,iM)
%        -vimg array of nifti.
%        -id   index in the mask.
%_______________________________________________________________________
% Copyright (C) 2001-2008 
% Kherif Ferath

sub=size(vimg,1);
sz=vimg(1).dim;
EY=zeros(size(vimg,1));
memchunk = 2^26; %chunk size
sizeVox  = ceil((memchunk/sub/8)); 
N=size(id,1);
N=round(N/5);
for i=1:sizeVox:N
   n=min(i+sizeVox-1,N)-i+1;
   str   = sprintf('reading %3d-%3d %% of the data',round((i/N)*100),round(((i+n)/N)*100));
xyz=XYZ(:,id(i:min(i+sizeVox-1,N)));
Y     = zeros(length(vimg),size(xyz,2));
%    Y=zeros(n,sub);
   %Y=spm_get_data(vimg,XYZ(:,);
    for k=1:sub
        Y(k,:)=spm_sample_vol(vimg(k),xyz(1,:),xyz(2,:),xyz(3,:),0);
        %bv=bv+n;spm_progress_bar('Set',bv)
      
    end
    EY=EY+Y*Y';
    
        fprintf('\r%-40s',str)
    
end