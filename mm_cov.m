function EY=mm_cov(vimg,id,vrms)
% Compute the dispersion matrix
% FORMAT EY=mm_cov(vimg,iM)
%        -vimg array of nifti.
%        -id   index in the mask.
%_______________________________________________________________________
% Copyright (C) 2001-2008
% Kherif Ferath

sub=size(vimg,2);
% sz=size(vimg(1).dat);
EY=zeros(size(vimg,2));
memchunk = 2^26; %chunk size
sizeVox  = ceil((memchunk/sub/8));
N=size(id,1);
rms=0;
if nargin >2
    rms=1;
end
for i=1:sizeVox:N
    n=min(i+sizeVox-1,N)-i+1;
    str   = sprintf('reading %3d-%3d %% of the data',round((i/N)*100),round(((i+n)/N)*100));

    Y=zeros(n,sub);
    S=1;
    if rms
        disp('scaling');
        S=vrms.dat(id(i:min(i+sizeVox-1,N)));
    end
    for k=1:sub
        Y(:,k)=vimg(k).dat(id(i:min(i+sizeVox-1,N)))./S;

        %bv=bv+n;spm_progress_bar('Set',bv)

    end
    EY=EY+Y'*Y;

    fprintf('\r%-40s',str)

end