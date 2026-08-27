function matlab_entrypoint(varargin)

% Parse inputs
P = inputParser;
addOptional(P,'fmriprep1_dir','/INPUTS/fmriprep1')
addOptional(P,'fmriprep2_dir','/INPUTS/fmriprep2')
addOptional(P,'fmriprep3_dir','/INPUTS/fmriprep3')
addOptional(P,'fmriprep4_dir','/INPUTS/fmriprep4')
addOptional(P,'eprime_csv','/OUTPUTS/eprime.csv')
addOptional(P,'ppiroi_niigz','space-MNI152NLin6Asym_atlas-BNSTamyg_dseg.nii.gz')
addOptional(P,'ppiroilabels_tsv','atlas-BNSTamyg_dseg.tsv')
addOptional(P,'ppi_subjlabel','subj')
addOptional(P,'hpf_sec','300')
addOptional(P,'input_fwhm_mm','0')
addOptional(P,'ppicon_fwhm_mm','6')
addOptional(P,'out_dir','/OUTPUTS');
parse(P,varargin{:});
disp(P.Results)

% SPM init
spm_jobman('initcfg');
spm('defaults','fmri');

% Run the actual pipeline
outp = fileprep_nvs(P.Results);
first_level_stats_nvs(outp);
if exist(outp.ppiroi_niigz,'file')
    ppi_processing_nvs(outp);
else
    fprintf('PPI ROI file not found: %s\nSKIPPING PPI\n',outp.ppiroi_niigz)
end

% Exit
if isdeployed
	exit
end
