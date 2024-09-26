function first_level_stats_nvs(inp)

tag = 'nvs';

% Filter param
hpf_sec = str2double(inp.hpf_sec);

% Save motion params as .mat
for r = 1:4
	mot = readtable(inp.(['motpar' num2str(r) '_txt']),'FileType','text');
	mot = zscore(table2array(mot(:,1:6)));
	writematrix(mot, fullfile(inp.out_dir,['motpar' num2str(r) '.txt']))
end

% Get TRs and check
N = nifti(inp.swfmri1_nii);
tr = N.timing.tspace;
for r = 2:4
	N = nifti(inp.(['swfmri' num2str(r) '_nii']));
	if abs(N.timing.tspace-tr) > 0.001
		error('TR not matching for run %d',r)
	end
end
fprintf('ALERT: USING TR OF %0.3f sec FROM FMRI NIFTI\n',tr)

% Load condition timing info
timings = get_timings(inp.eprime_csv);


%% Design
clear matlabbatch
matlabbatch{1}.spm.stats.fmri_spec.dir = ...
	{fullfile(inp.out_dir,['spm_' tag])};
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

for r = 1:4

	% Session-specific scans, regressors, params
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).scans = ...
		{inp.(['swfmri' num2str(r) '_nii'])};
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).multi = {''};
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).regress = ...
		struct('name', {}, 'val', {});
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).multi_reg = {''};
    %matlabbatch{1}.spm.stats.fmri_spec.sess(r).multi_reg = ...
	%	{fullfile(inp.out_dir,['motpar' num2str(r) '.txt'])};
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).hpf = hpf_sec;
	
    % Conditions
    c = 0;
    for cond = timings{r}
    	c = c + 1;
    	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).name = cond.name;
    	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).onset = cond.onsets;
    	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).duration = 0;
    	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).tmod = 0;
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
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Cue All';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [1/3 1/3 1/3 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Image All';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [0 0 0 1/4 1/4 1/4 1/4];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Image All gt Cue All';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [-1/3 -1/3 -1/3 1/4 1/4 1/4 1/4];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

% Individual predictors
c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Cue Neutral';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [1 0 0 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Cue Fear';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [0 1 0 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Cue Unknown';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [0 0 1 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Image Neutral';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [0 0 0 1 0 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Image Fear';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [0 0 0 0 1 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Image Unknown Neutral';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [0 0 0 0 0 1 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Image Unknown Fear';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [0 0 0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

% Comparisons
c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Cue Fear gt Neutral';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [-1 1 0 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Cue Unknown gt Neutral';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [-1 0 1 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Cue Unknown gt Fear';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [0 -1 1 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Image Fear gt Neutral';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [0 0 0 -1 1 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Image UnknownEither gt Neutral';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [0 0 0 -1 0 0.5 0.5];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Image UnknownEither gt Fear';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [0 0 0 0 -1 0.5 0.5];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Image UnknownNeutral gt Neutral';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [0 0 0 -1 0 1 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Image UnknownFear gt Neutral';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [0 0 0 -1 0 0 1];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Image UnknownNeutral gt Fear';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [0 0 0 0 -1 1 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Image UnknownFear gt Fear';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [0 0 0 0 -1 0 1];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Image UnknownFear gt UnknownNeutral';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [0 0 0 0 0 -1 1];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';


% Inverse of all existing contrasts since SPM won't show us both sides
numc = numel(matlabbatch{3}.spm.stats.con.consess);
for k = 1:numc
        c = c + 1;
        matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = ...
                ['Neg ' matlabbatch{3}.spm.stats.con.consess{c-numc}.tcon.name];
        matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = ...
                - matlabbatch{3}.spm.stats.con.consess{c-numc}.tcon.weights;
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
spm_sections(xSPM,hReg,inp.biasnorm_nii)

% Jump to global max activation
%spm_mip_ui('Jump',spm_mip_ui('FindMIPax'),'glmax');

% Jump to common location
spm_mip_ui('SetCoords',[0 -78 -15],spm_mip_ui('FindMIPax'));

% Screenshot
spm_window_print(fullfile(inp.out_dir,['first_level_result_' tag '.png']));
