function first_level_stats_nvs(inp)

disp(inp)

tag = 'nvs';

spm_dir = fullfile(inp.out_dir,['spm_' tag]);
disp(['spm_dir is ' spm_dir])
if ~exist(spm_dir, 'dir')
    mkdir(spm_dir)
end

nprocruns = numel(inp.fmri_nii);

% Filter param
hpf_sec = str2double(inp.hpf_sec);

% Get TRs and check
N = nifti(inp.fmri_nii{1});
tr = N.timing.tspace;
for procr = 2:nprocruns
	N = nifti(inp.fmri_nii{procr});
	if abs(N.timing.tspace-tr) > 0.001
		error('TR not matching')
	end
end
fprintf('ALERT: USING TR OF %0.3f sec FROM FMRI NIFTI\n',tr)


% Smooth fmriprep's fmri timeseries and get smoothed filenames
fwhm_mm = str2double(inp.fwhm_mm);
clear smfri_nii
procr = 0;
for imgs = inp.fmri_nii

    clear matlabbatch
    matlabbatch{1}.spm.spatial.smooth.data = imgs(1);
    matlabbatch{1}.spm.spatial.smooth.fwhm = [fwhm_mm fwhm_mm fwhm_mm];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
    spm_jobman('run',matlabbatch);

    [~,n,e] = fileparts(imgs{1});
    procr = procr + 1;
    sfmri_nii{procr} = fullfile(inp.out_dir,['s' n e]);

end


%% Design
clear matlabbatch
matlabbatch{1}.spm.stats.fmri_spec.dir = {spm_dir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = tr;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = -Inf;
matlabbatch{1}.spm.stats.fmri_spec.mask = {[spm('dir') '/tpm/mask_ICV.nii']};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

for procr = 1:nprocruns

	% Session-specific scans, regressors, params
	matlabbatch{1}.spm.stats.fmri_spec.sess(procr).scans = ...
		sfmri_nii(procr);
	matlabbatch{1}.spm.stats.fmri_spec.sess(procr).multi = {''};
	matlabbatch{1}.spm.stats.fmri_spec.sess(procr).regress = ...
		struct('name', {}, 'val', {});
	matlabbatch{1}.spm.stats.fmri_spec.sess(procr).multi_reg = {''};
    %matlabbatch{1}.spm.stats.fmri_spec.sess(r).multi_reg = ...
	%	{fullfile(inp.out_dir,['motpar' num2str(r) '.txt'])};
	matlabbatch{1}.spm.stats.fmri_spec.sess(procr).hpf = hpf_sec;
	
    % Conditions
    c = 0;
    for cond = inp.timings{procr}
    	c = c + 1;
    	matlabbatch{1}.spm.stats.fmri_spec.sess(procr).cond(c).name = cond.name;
    	matlabbatch{1}.spm.stats.fmri_spec.sess(procr).cond(c).onset = cond.onsets;
    	matlabbatch{1}.spm.stats.fmri_spec.sess(procr).cond(c).duration = 0;
    	matlabbatch{1}.spm.stats.fmri_spec.sess(procr).cond(c).tmod = 0;
    end

end


%% Estimate
matlabbatch{2}.spm.stats.fmri_est.spmmat = ...
	fullfile(matlabbatch{1}.spm.stats.fmri_spec.dir,'SPM.mat');
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;


%% Contrasts
%
% Predictors are
%
%    Cue_Neutral
%    Cue_Fear
%    Cue_Unknown
%    Image_Neutral
%    Image_Fear
%    Image_Unknown_Neutral
%    Image_Unknown_Fear

matlabbatch{3}.spm.stats.con.spmmat = ...
	matlabbatch{2}.spm.stats.fmri_est.spmmat;
matlabbatch{3}.spm.stats.con.delete = 1;
c = 0;

% Combined conditions for sanity check
c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'CueAll';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = [1/3 1/3 1/3 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'ImageAll';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = [0 0 0 1/4 1/4 1/4 1/4];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'ImageAllGtCueAll';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = [-1/3 -1/3 -1/3 1/4 1/4 1/4 1/4];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

% Individual predictors
c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'CueNeutral';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = [1 0 0 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'CueFear';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = [0 1 0 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'CueUnknown';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = [0 0 1 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'ImageNeutral';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = [0 0 0 1 0 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'ImageFear';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = [0 0 0 0 1 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'ImageUnknownNeutral';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = [0 0 0 0 0 1 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'ImageUnknownFear';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = [0 0 0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

% Comparisons
c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'CueFearGtNeutral';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = [-1 1 0 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'CueUnknownGtNeutral';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = [-1 0 1 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'CueUnknownGtFear';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = [0 -1 1 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'ImageFearGtNeutral';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = [0 0 0 -1 1 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'ImageUnknownEitherGtNeutral';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = [0 0 0 -1 0 0.5 0.5];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'ImageUnknownEitherGtFear';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = [0 0 0 0 -1 0.5 0.5];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'ImageUnknownNeutralGtNeutral';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = [0 0 0 -1 0 1 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'ImageUnknownFearGtNeutral';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = [0 0 0 -1 0 0 1];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'ImageUnknownNeutralGtFear';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = [0 0 0 0 -1 1 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'ImageUnknownFearGtFear';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = [0 0 0 0 -1 0 1];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'ImageUnknownFearGtUnknownNeutral';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = [0 0 0 0 0 -1 1];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';


% Inverse of all existing contrasts since SPM won't show us both sides
numc = numel(matlabbatch{3}.spm.stats.con.consess);
for k = 1:numc
        c = c + 1;
        matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = ...
                ['Neg ' matlabbatch{3}.spm.stats.con.consess{c-numc}.tcon.name];
        matlabbatch{3}.spm.stats.con.consess{c}.tcon.convec = ...
                - matlabbatch{3}.spm.stats.con.consess{c-numc}.tcon.convec;
        matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';
end


%% Review design
matlabbatch{4}.spm.stats.review.spmmat = ...
	matlabbatch{2}.spm.stats.fmri_est.spmmat;
matlabbatch{4}.spm.stats.review.display.matrix = 1;
matlabbatch{4}.spm.stats.review.print = false;

matlabbatch{5}.cfg_basicio.run_ops.call_matlab.inputs{1}.string = ...
        fullfile(inp.out_dir,['first_level_design_' tag '.png']);
matlabbatch{5}.cfg_basicio.run_ops.call_matlab.outputs = cell(1,0);
matlabbatch{5}.cfg_basicio.run_ops.call_matlab.fun = 'spm_window_print';


%% Save batch and run
save(fullfile(inp.out_dir,['spmbatch_first_level_stats_' tag '.mat']),'matlabbatch')
spm_jobman('run',matlabbatch);

% And save contrast names
numc = numel(matlabbatch{3}.spm.stats.con.consess);
connames = table((1:numc)','VariableNames',{'ConNum'});
for k = 1:numc
	try
		connames.ConName{k,1} = ...
			matlabbatch{3}.spm.stats.con.consess{k}.tcon.name;
	catch
		connames.ConName{k,1} = ...
			matlabbatch{3}.spm.stats.con.consess{k}.fcon.name;
	end
end
writetable(connames,fullfile(inp.out_dir,['spm_contrast_names_' tag '.csv']));


%% Results display
% Needed to create the spmT even if we don't get the figure window
xSPM = struct( ...
    'swd', matlabbatch{1}.spm.stats.fmri_spec.dir, ...
    'title', '', ...
    'Ic', 3, ...
    'n', 0, ...
    'Im', [], ...
    'pm', [], ...
    'Ex', [], ...
    'u', 0.005, ...
    'k', 10, ...
    'thresDesc', 'none' ...
    );
[hReg,xSPM] = spm_results_ui('Setup',xSPM);

% Show on the subject MNI anat
spm_sections(xSPM,hReg,inp.atlasT1_nii)

% Jump to global max activation
%spm_mip_ui('Jump',spm_mip_ui('FindMIPax'),'glmax');

% Jump to common location
spm_mip_ui('SetCoords',[0 -78 -15],spm_mip_ui('FindMIPax'));

% Screenshot
spm_window_print(fullfile(inp.out_dir,['first_level_result_' tag '.png']));
