SPM8 must be installed to compile the Matlab code, but is not needed to run the 
compiled code. Its source is not included in the code repository or in the container.

SPM8 (r6313)
    https://github.com/spm/spm8/releases/tag/r6313

The mask_ICV.nii file from SPM12 (provided here) must be copied to spm8/tpm, as it 
doesn't exist in the SPM8 install.

The provided spm_defaults.m must be copied to spm8.

The PPPI toolbox v13.1 must be copied to the SPM8 toolbox/PPPI directory:
    https://www.nitrc.org/projects/gppi

spm8/toolbox/PPPI/contains.m msut be renamed to remove it from the path (it
blocks compilation).
