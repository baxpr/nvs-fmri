function spm8_show_design(spmmat_path)
    if iscell(spmmat_path), spmmat_path = spmmat_path{1}; end
    load(spmmat_path);  % loads variable SPM

    % ensure Graphics window exists and is current
    spm_figure('GetWin','Graphics');
    spm_figure('Clear','Graphics');

    % Draw the design matrix into the SPM Graphics window
    % (this is the key bit for SPM8)
    spm_DesRep('DesMtx', SPM.xX);

    drawnow;
end
