#!/usr/bin/env bash

echo Running $(basename "${BASH_SOURCE}")

cd "${out_dir}"

# Zip nifti files in SPM outputs
find spm_nvs -name \*.nii -exec gzip {} \;
find spm_nvs -name \*.img -exec gzip {} \;

