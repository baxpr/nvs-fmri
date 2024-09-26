#!/usr/bin/env bash

docker run \
    --mount type=bind,src=$(pwd -P)/INPUTS,dst=/INPUTS \
    --mount type=bind,src=$(pwd -P)/OUTPUTS,dst=/OUTPUTS \
    nvs-fmri:test \
    --fmri1_niigz /INPUTS/fmri1.nii.gz \
    --fmri2_niigz /INPUTS/fmri2.nii.gz \
    --fmri3_niigz /INPUTS/fmri3.nii.gz \
    --fmri4_niigz /INPUTS/fmri4.nii.gz \
    --fmritopup_niigz /INPUTS/fmri_topup.nii.gz \
    --gm_niigz /INPUTS/gray_native.nii.gz \
    --wm_niigz /INPUTS/white_native.nii.gz \
    --icv_niigz /INPUTS/p0t1.nii.gz \
    --refimg_nii avg152T1.nii \
    --deffwd_niigz /INPUTS/y_t1.nii.gz \
    --biascorr_niigz /INPUTS/mt1.nii.gz \
    --biasnorm_niigz /INPUTS/wmt1.nii.gz \
    --eprime_txt /INPUTS/eprime.txt \
    --pedir "+j" \
    --vox_mm 2 \
    --hpf_sec 300 \
    --fwhm_mm 6 \
    --out_dir /OUTPUTS
