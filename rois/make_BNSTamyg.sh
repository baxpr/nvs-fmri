#!/usr/bin/env bash

# Extract some ROIs from the NegVal15 set. Matching label file created manually
#
#   index	label
#   3       Amygdala_L_HO50    ->  1
#   4       Amygdala_R_HO50        2
#   5       BNST_3t_L_90           3
#   6       BNST_3t_R_90           4
nv=space-MNI152NLin6Asym_atlas-NegVal15_dseg.nii.gz

fslmaths "${nv}" -thr 3 -uthr 3 -bin Amygdala_L_HO50
fslmaths "${nv}" -thr 4 -uthr 4 -bin Amygdala_R_HO50
fslmaths "${nv}" -thr 5 -uthr 5 -bin BNST_3t_L_90
fslmaths "${nv}" -thr 6 -uthr 6 -bin BNST_3t_R_90

fslmaths Amygdala_L_HO50 -mul 1 tmp
fslmaths Amygdala_R_HO50 -mul 2 -add tmp tmp
fslmaths BNST_3t_L_90 -mul 3 -add tmp tmp
fslmaths BNST_3t_R_90 -mul 4 -add tmp space-MNI152NLin6Asym_atlas-BNSTamyg_dseg.nii.gz

rm {Amygdala_L_HO50,Amygdala_R_HO50,BNST_3t_L_90,BNST_3t_R_90,tmp}.nii.gz
