#!/usr/bin/env bash

echo Running $(basename "${BASH_SOURCE}")

cd "${out_dir}"

# Smooth all PPI con images if requested
if [[ "${ppi_fwhm_mm}" != "0" ]]; then
    echo Smoothing PPI con images
    ppi_sigma_mm=$(bc -e "scale=3; ${ppi_fwhm_mm}/2.354")
    for img in spm_nvs/con*.nii spm_nvs/con*.img spm_nvs/PPI_*/con*.nii spm_nvs/PPI_*/con*.img; do
        echo "${img}"
        fslmaths "${img}" -kernel gauss ${ppi_sigma_mm} "$(dirname ${img})/s$(basename ${img})"
    done
fi

# Zip nifti files in SPM outputs
find spm_nvs -name \*.nii -exec gzip {} \;
find spm_nvs -name \*.img -exec gzip {} \;

