
wd = pwd;

inp = struct( ...
	'hpf_sec', '300', ...
	'motpar1_txt', '../../OUTPUTS/motpar1.txt', ...
	'motpar2_txt', '../../OUTPUTS/motpar2.txt', ...
	'motpar3_txt', '../../OUTPUTS/motpar3.txt', ...
	'motpar4_txt', '../../OUTPUTS/motpar4.txt', ...
	'out_dir', '../../OUTPUTS', ...
	'eprime_csv', '../../OUTPUTS/eprime.csv', ...
	'swfmri1_nii', '../../OUTPUTS/swctrrfmri1.nii', ...
	'swfmri2_nii', '../../OUTPUTS/swctrrfmri2.nii', ...
	'swfmri3_nii', '../../OUTPUTS/swctrrfmri3.nii', ...
	'swfmri4_nii', '../../OUTPUTS/swctrrfmri4.nii', ...
	'biasnorm_nii', '../../OUTPUTS/biasnorm.nii' ...
	);

first_level_stats_nvs(inp);

cd(wd);
