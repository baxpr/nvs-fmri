
addpath([pwd '/../external/spm8_r6313/spm8'])
addpath(genpath([pwd '/../external/gppi']))

wd = pwd;

inp = struct( ...
    'out_dir', '../../OUTPUTS', ...
    'ppiroi_niigz', '../../rois/space-MNI152NLin6Asym_atlas-BNST_dseg.nii.gz', ...
    'ppiroilabels_tsv', '../../rois/atlas-BNST_dseg.tsv' ...
	);

ppi_processing_nvs(inp);

cd(wd);
