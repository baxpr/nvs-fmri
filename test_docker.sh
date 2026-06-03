#!/usr/bin/env bash

# Smoothing, no PPI
mkdir -p $(pwd -P)/OUTPUTS_smoothed
podman run \
    --mount type=bind,src=$(pwd -P)/INPUTS,dst=/INPUTS \
    --mount type=bind,src=$(pwd -P)/OUTPUTS_smoothed,dst=/OUTPUTS \
    baxterprogers/nvs-fmri:test \
    --fmriprep1_dir /INPUTS/fmriprep1 \
    --fmriprep2_dir /INPUTS/fmriprep2 \
    --fmriprep3_dir /INPUTS/fmriprep3 \
    --fmriprep4_dir /INPUTS/fmriprep4 \
    --eprime_txt /INPUTS/eprime.txt \
    --hpf_sec 300 \
    --fwhm_mm 6 \
    --out_dir /OUTPUTS

# No smoothing, some PPI
mkdir -p $(pwd -P)/OUTPUTS_ppi
podman run \
    --mount type=bind,src=$(pwd -P)/INPUTS,dst=/INPUTS \
    --mount type=bind,src=$(pwd -P)/OUTPUTS_ppi,dst=/OUTPUTS \
    baxterprogers/nvs-fmri:test \
    --fmriprep1_dir /INPUTS/fmriprep1 \
    --fmriprep2_dir /INPUTS/fmriprep2 \
    --fmriprep3_dir /INPUTS/fmriprep3 \
    --fmriprep4_dir /INPUTS/fmriprep4 \
    --eprime_txt /INPUTS/eprime.txt \
    --ppiroi_niigz space-MNI152NLin6Asym_atlas-BNST_dseg.nii.gz \
    --ppiroilabels_tsv atlas-BNST_dseg.tsv \
    --hpf_sec 300 \
    --fwhm_mm 0 \
    --out_dir /OUTPUTS

