function matlab_entrypoint(varargin)

% Parse inputs
P = inputParser;
addOptional(P,'fmriprep1_dir','/INPUTS/fmriprep1')
addOptional(P,'fmriprep2_dir','/INPUTS/fmriprep2')
addOptional(P,'fmriprep3_dir','/INPUTS/fmriprep3')
addOptional(P,'fmriprep4_dir','/INPUTS/fmriprep4')
addOptional(P,'eprime_csv','/OUTPUTS/eprime.csv')
addOptional(P,'ppiroi_niigz','space-MNI152NLin6Asym_atlas-BNST_dseg.nii.gz')
addOptional(P,'ppiroilabels_tsv','atlas-BNST_dseg.tsv')
addOptional(P,'hpf_sec','300')
addOptional(P,'fwhm_mm','6')
addOptional(P,'out_dir','/OUTPUTS');
parse(P,varargin{:});
disp(P.Results)

% SPM init
%spm_jobman('initcfg');
spm('defaults','fmri');

% Run the actual pipeline
outp = fileprep_nvs(P.Results);
first_level_stats_nvs(outp);
ppi_processing(outp);

% Exit
if isdeployed
	exit
end
