function spm_MM5
% GUI gateway to MM toolbox

if ~isdeployed, addpath(fullfile(spm('dir'),'toolbox','MM12')); end

mm_ui;