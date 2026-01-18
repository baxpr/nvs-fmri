#!/usr/bin/env bash

docker run \
    --mount type=bind,src=$(pwd -P)/INPUTS,dst=/INPUTS \
    --mount type=bind,src=$(pwd -P)/OUTPUTS,dst=/OUTPUTS \
    nvs-fmri:test \
    --fmriprep1_dir /INPUTS/fmriprep1 \
    --fmriprep2_dir /INPUTS/fmriprep2 \
    --fmriprep3_dir /INPUTS/fmriprep3 \
    --fmriprep4_dir /INPUTS/fmriprep4 \
    --eprime_txt /INPUTS/eprime.txt \
    --hpf_sec 300 \
    --fwhm_mm 6 \
    --out_dir /OUTPUTS
