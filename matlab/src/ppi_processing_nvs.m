function ppi_processing_nvs(inp)

disp('ppi_processing_nvs')
disp(inp)

tag = 'nvs';

spm_dir = fullfile(inp.out_dir,['spm_' tag]);

ppiroi_niigz = which(inp.ppiroi_niigz);
ppiroilabels_tsv = which(inp.ppiroilabels_tsv);

%% !! FIXME !!
% Clip VOIs to the SPM first-level mask to avoid PPI errors. First step is
% to resample the ROI image to the mask grid.

% Split the ROI file into individual images for PPI -
% Load, split into individual images for gppi, sanitizing ROI names
roi_dir = fullfile(inp.out_dir,['roiwkdir_' tag]);
mkdir(roi_dir);
copyfile(ppiroi_niigz,roi_dir)
[~,n,e] = fileparts(ppiroi_niigz);
gunzip(fullfile(roi_dir,[n e]))
ppiroi_nii = fullfile(roi_dir,n);

% Load ROIs and cross-check values
Vroi = spm_vol(ppiroi_nii);
Yroi = spm_read_vols(Vroi);
roiinds = unique(Yroi(:));
roiinds = roiinds(roiinds~=0);
roilabels = readtable(ppiroilabels_tsv,'FileType','text','Delimiter','tab');
if sort(roilabels.index)~=sort(roiinds)
    error('Mismatch in ROI indices')
end

% Sanitize ROI labels
roilabels.label = strrep(roilabels.label,' ','_');

% Write individual ROI files
for r = 1:height(roilabels)
    Yout = zeros(size(Yroi));
    Yout(Yroi(:)==r) = 1;
    Vout = Vroi;
    Vout.dt(1) = spm_type('uint16');
    Vout.pinfo(1:2) = [1;0];
    Vout.fname = fullfile(roi_dir,[roilabels.label{r} '.nii']);
    spm_write_vol(Vout,Yout);
end

% Loop through all ROIs and run PPIs
for r = 1:height(roilabels)

    % Basic PPI analysis parameters
    % There is a bug when specifying 'outdir', so use the default
    P = struct( ...
        'subject', inp.ppi_subjlabel, ...
        'directory', spm_dir, ...
        'VOI', fullfile(roi_dir, [roilabels.label{r} '.nii']), ...
        'Region', roilabels.label{r}, ...
        'analysis', 'psy', ...
        'method', 'cond', ...
        'extract', 'eig', ...
        'contrast', 0, ...
        'Estimate', 1, ...
        'equalroi', 1, ...
        'FLmask', 0, ...
        'CompContrasts', 1, ...
        'Weighted', 0, ...
        'SPMver', '8', ...
        'preservevarcorr', 1 ...
        );

    % Tasks to include in PPI analyses
    P.Tasks = { ...
        '1' ...
        'CueNeutral' ...
        'CueFear' ...
        'CueUnknown' ...
        'ImageNeutral' ...
        'ImageFear' ...
        'ImageUnknownNeutral' ...
        'ImageUnknownFear' ...
        };
    P.Weights = [];

    % Contrasts, one per task
    for c = 1:numel(P.Tasks)-1
        P.Contrasts(c) = struct( ...
            'left', {P.Tasks(c+1)}, ...
            'right', {{'none'}}, ...
            'STAT', 'T' ...
            );
    end

    % Additional desired contrasts
    c = c + 1;
    P.Contrasts(c) = struct('left',{{'CueFear'}},'right',{{'CueNeutral'}},'STAT','T');
    c = c + 1;
    P.Contrasts(c) = struct('left',{{'CueUnknown'}},'right',{{'CueNeutral'}},'STAT','T');
    c = c + 1;
    P.Contrasts(c) = struct('left',{{'CueUnknown'}},'right',{{'CueFear'}},'STAT','T');
    c = c + 1;
    P.Contrasts(c) = struct('left',{{'ImageFear'}},'right',{{'ImageNeutral'}},'STAT','T');
    c = c + 1;
    P.Contrasts(c) = struct('left',{{'ImageUnknownNeutral','ImageUnknownFear'}},'right',{{'ImageNeutral'}},'STAT','T');
    c = c + 1;
    P.Contrasts(c) = struct('left',{{'ImageUnknownNeutral','ImageUnknownFear'}},'right',{{'ImageFear'}},'STAT','T');
    c = c + 1;
    P.Contrasts(c) = struct('left',{{'ImageUnknownNeutral'}},'right',{{'ImageNeutral'}},'STAT','T');
    c = c + 1;
    P.Contrasts(c) = struct('left',{{'ImageUnknownFear'}},'right',{{'ImageNeutral'}},'STAT','T');
    c = c + 1;
    P.Contrasts(c) = struct('left',{{'ImageUnknownNeutral'}},'right',{{'ImageFear'}},'STAT','T');
    c = c + 1;
    P.Contrasts(c) = struct('left',{{'ImageUnknownFear'}},'right',{{'ImageFear'}},'STAT','T');
    c = c + 1;
    P.Contrasts(c) = struct('left',{{'ImageUnknownFear'}},'right',{{'ImageUnknownNeutral'}},'STAT','T');

    ppi_confmat = fullfile(spm_dir,['PPI_config_' roilabels.label{r} '.mat']);
    save(ppi_confmat,'P')
    PPPI(ppi_confmat)

    % Find PPI dir and smooth con images at inp.ppicon_fwhm_mm
    ppicon_fwhm_mm = str2double(inp.ppicon_fwhm_mm);
    if ppicon_fwhm_mm>0

        D = dir([P.directory filesep 'PPI_' P.Region filesep 'con*.img']);
        con_imgs = {D.name}';
        fprintf('Smoothing %d contrasts images for %s\n',numel(con_imgs),P.Region);
        for imgk = 1:numel(con_imgs)

            clear matlabbatch
            matlabbatch{1}.spm.spatial.smooth.data = con_imgs(imgk);
            matlabbatch{1}.spm.spatial.smooth.fwhm = [ppicon_fwhm_mm ppicon_fwhm_mm ppicon_fwhm_mm];
            matlabbatch{1}.spm.spatial.smooth.dtype = 0;
            matlabbatch{1}.spm.spatial.smooth.im = 0;
            matlabbatch{1}.spm.spatial.smooth.prefix = 's';
            spm_jobman('run',matlabbatch);

        end
    end

end
