#!/usr/bin/env bash

echo Running $(basename "${BASH_SOURCE}")

cd "${out_dir}"

# Zip nifti files in SPM outputs
for d in \
    spm_nvs \
; do
    gzip "${d}"/*.nii
done

