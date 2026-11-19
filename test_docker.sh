#!/usr/bin/env bash


mkdir -p $(pwd -P)/OUTPUTS
podman run \
    --mount type=bind,src=$(pwd -P)/INPUTS,dst=/INPUTS \
    --mount type=bind,src=$(pwd -P)/OUTPUTS,dst=/OUTPUTS \
    baxterprogers/nvs-fmri:test \
    --fmriprep1_dir /INPUTS/fmriprep1 \
    --fmriprep2_dir /INPUTS/fmriprep2 \
    --fmriprep3_dir /INPUTS/fmriprep3 \
    --fmriprep4_dir /INPUTS/fmriprep4 \
    --eprime_csv /INPUTS/eprime.csv \
    --ppiroi_niigz atlas-BNSTamyg_space-MNI152NLin6Asym_dseg.nii.gz \
    --ppiroilabels_tsv atlas-BNSTamyg_dseg.tsv \
    --hpf_sec 300 \
    --mask_dilate_voxels 1 \
    --atlas_space MNI152NLin6Asym \
    --input_fwhm_mm 0 \
    --ppi_fwhm_mm 4 \
    --out_dir /OUTPUTS


exit 0


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
