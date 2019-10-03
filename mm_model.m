function varargout = mm_model(varargin)
%-  Set model sub-space of interest and the related matrix of normalisation and projection. 
%-  Format varargout = mm_model(varargin)
%-  See subfunction for details.
%================================================================================



if nargin
	typeAnal = varargin{1};
else 
	error('no input argument in mm_model')
end


switch typeAnal
	case 'MLM'
		[NF,nu,h,d,M12,XG,sXG] = sf_model_mlm(varargin{2:nargin});
		varargout 	= {NF,nu,h,d,M12,XG,sXG};
		% varargin	= {cwd,nbsub,xC};

	case 'SVD'
		[NF,h,RNF] = sf_model_svd(varargin{2:nargin});
		varargout 	= {NF,h,RNF};
		
		
	otherwise
		error('unknown type of analysis')
end
		


	
%===================================================================
function [NF,nu,h,d,M12,XG,sXG] = sf_model_mlm(cwd,nbsub,xC);
% Set sub-space of interest and the related matrix of normalisation. 
% FORMAT [NF,nu,h,d,M12,XG] = mm_model(cwd,nbsub,xC);
%- nu, h, d : degrees of freedom
%- NF : matrix of normalisation
%===================================================================

%- load the design matrix
%--------------------------------------------------------------------
Pmat	= fullfile(cwd{1},'SPM.mat');
load(Pmat);
xX=SPM.xX
%--------------------------------------------------------------------
%- SET, COMPUTE,NORMALIZE SPACES OF INTEREST
%--------------------------------------------------------------------
%- set X10 and XG
%- XG= X -PG(X), PG projection operator on XG (cf. eq 1, 2)
%--------------------------------------------------------------------

sX1o	= spm_sp('set',spm_FcUtil('X1o',xC,xX.xKXs));
sXG	= spm_sp('set',spm_FcUtil('X0',xC,xX.xKXs));
X1o 	= spm_sp('oP',sX1o,xX.xKXs.X);
XG  	= spm_sp('r',sXG,xX.xKXs.X);

%- Compute Normalized effexts : M1/2=X'G*V*XG (cf eq 3)
%--------------------------------------------------------------------
warning off;
up	= spm_sp('uk',sX1o); ; %- PG=up*up'
qi	= up'*xX.xKXs.X;
sigma	= up'*xX.V*up;
M12	= (chol(sigma)*qi)';
M_12	= pinv(M12);


%- Compute NF : normalise factor (cf eq 4)
%--------------------------------------------------------------------

NF	= M_12*spm_sp('X',xX.xKXs)'*spm_sp('r',sXG,spm_sp('X',xX.xKXs));

%- degrees of freedom
%- R :resel counts. Rtot sum of all the subject resel 
%--------------------------------------------------------------------

%load(Pmat,'R');
R=SPM.xVol.R;
Rtot	= R(4);
for sub=2:nbsub
   Pmat	= fullfile(cwd{sub});
   R=SPM.xVol.R;	 
   Rtot=Rtot+R(4);
end
clear R

d	= Rtot*(4*log(2)/pi)^(3/2);
h	= sX1o.rk; %-rank of the sub-space of interest.
nu	= xX.erdf;





%===================================================================
function  [NF,h,RNF] = sf_model_svd(cwd, xC, paramsAnal);
%===================================================================
	
%- load the design matrix
%--------------------------------------------------------------------
Pmat	= fullfile(cwd{1},'SPM.mat');
load(Pmat);
xX=SPM.xX;


%- compute projector
%--------------------------------------------------------------------
% RNF 	= spm_sp('r',xX.xKXs);
NF	= spm_sp('op',spm_sp('set',xX.X*xC.c));

%- residual contrast space ...
if paramsAnal.resContSp
	NF = eye(size(NF)) - NF;
    RNF=NF;
end
h	= size(NF,1);

