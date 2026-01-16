function outp = fileprep_nvs(inp)

% Input variables
%   eprime_csv
%   fmriprep1_dir
%   fmriprep2_dir
%   fmriprep3_dir
%   fmriprep4_dir
%   hpf_sec
%   fwhm_mm
%   out_dir

% Output variables listed at end


%% Get eprime timing info
warning('off','MATLAB:table:ModifiedAndSavedVarnames');
timings = get_timings(inp.eprime_csv);



%% Find fmriprep files
%
% scanr is the run 1-4 as specified on the scanner
% procr is the run for the processing, with missing ones skipped

% Scale motion params and save in SPM friendly format
clear procr_scan motpar_txt fmri_nii finaltimings
procr = 0;
for scanr = 1:4
    fmriprep_dir = inp.(['fmriprep' num2str(scanr) '_dir']);
    if ~strcmp(fmriprep_dir,'NONE')

        confD = dir([fmriprep_dir '/sub*/ses*/func/*_desc-confounds_timeseries.tsv']);
        conffile = fullfile(confD(1).folder,confD(1).name);

        procr = procr + 1;
        procr_scan(procr) = scanr;

        conf = readtable(conffile,'FileType','text','Delimiter','tab');
        motT = conf(:,{'trans_x','trans_y','trans_z','rot_x','rot_y','rot_z'});
        mot = zscore(table2array(motT));
        motpar_txt{procr} = fullfile(inp.out_dir,['motpar' num2str(scanr) '.txt']);
        writematrix(mot, motpar_txt{procr})

        niigzD = dir([fmriprep_dir '/sub*/ses*/func/*_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz']);
        fmri_nii{procr} = fullfile(inp.out_dir,['fmri' num2str(r) '.nii']);
        copyfile( ...
            fullfile(niigzD(1).folder,niigzD(1).name), ...
            [fmri_nii{procr} '.gz'] ...
            );
        
        finaltimings{procr} = timings{scanr};

    end
end

gunzip(fullfile(inp.out_dir,'fmri*.nii.gz'));
delete(fullfile(inp.out_dir,'fmri*.nii.gz'));



% Also the T1
niigzD = dir([inp.(['fmriprep' num2str(procr_scan(1)) '_dir']) ...
    '/sub*/ses*/anat/*_space-MNI152NLin6Asym_desc-preproc_T1w.nii.gz']);
atlasT1_nii = fullfile(inp.out_dir,'t1.nii');
copyfile( ...
    fullfile(niigzD(1).folder,niigzD(1).name), ...
    [atlasT1_nii '.gz'] ...
    );
gunzip(fullfile(inp.out_dir,'t1.nii.gz'));
delete(fullfile(inp.out_dir,'t1.nii.gz'));


% Outputs for next step
outp = struct( ...
    'fmri_nii', {fmri_nii}, ...
    'motpar_txt', {motpar_txt}, ...
    'timings', {finaltimings}, ...
    'hpf_sec', inp.hpf_sec, ...
    'fwhm_mm', inp.fwhm_mm, ...
    'atlasT1_nii', atlasT1_nii, ...
    'out_dir', inp.out_dir ...
    );

