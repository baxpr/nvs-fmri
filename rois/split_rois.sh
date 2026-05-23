#!/usr/bin/env bash
#
# Split BNST ROIs

fslmaths space-MNI152NLin6Asym_atlas-BNST_dseg.nii.gz -thr 1 -uthr 1 BNST_L
fslmaths space-MNI152NLin6Asym_atlas-BNST_dseg.nii.gz -thr 2 -uthr 2 BNST_R
