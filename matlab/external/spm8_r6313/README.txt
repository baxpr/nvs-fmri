This is a slightly modified version of SPM8 r6313, with modifications to allow use
of the PPPI toolbox and permit compilation without error in Matlab 2023a.

SPM8 (r6313) original source
    https://github.com/spm/spm8/releases/tag/r6313

Added file (Intracranial mask obtained from SPM12)
   spm8/tpm/mask_ICV.nii

Added directory (gPPI, from https://www.nitrc.org/projects/gppi)
   spm8/toolbox/PPPI

Edited file (Some adjustments to defaults)
   spm8/spm_defaults.m

Deleted file (blocks compilation)
   spm8/toolbox/PPPI/contains.m

Deleted directories (block compilation)
   spm8/external/fieldtrip
   spm8/external/yokagawa
