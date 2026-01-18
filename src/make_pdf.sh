#!/usr/bin/env bash

echo Making PDF

# Work in output directory
cd ${out_dir}

# Timestamp
thedate=$(date)

# Overall mean fmri
cmd=
let denom=0
for f in "${out_dir}"/meanfmri?.nii.gz; do
    cmd="${cmd} -add ${f}"
    ((denom++))
done
fslmaths "${f}" -mul 0 ${cmd} -div ${denom} mean_allfmri

# fMRI contrast image, slices
spm_dir=spm_nvs
for connum in 1 2 3; do
    connum0=$(printf "%04g\n" ${connum})
    conname=$(get_conname.py ${out_dir}/spm_contrast_names_nvs.csv ${connum})
    c=10
    for slice in -35 -20 -5 10 25 40 55 70  ; do
	    ((c++))
	    fsleyes render -of ${spm_dir}_${connum0}_${c}.png \
	        --scene ortho --worldLoc 0 0 ${slice} --displaySpace world --size 600 600 --yzoom 1000 \
	        --layout horizontal --hideCursor --hideLabels --hidex --hidey \
		    t1 --overlayType volume \
		    ${spm_dir}/spmT_${connum0} --overlayType volume --displayRange 2.5 7 \
		    --useNegativeCmap --cmap red-yellow --negativeCmap blue-lightblue
    done

    montage \
	    -mode concatenate ${spm_dir}_${connum0}_??.png \
	    -tile 3x -quality 100 -background black -gravity center \
	    -border 20 -bordercolor black ${spm_dir}_${connum0}.png

    convert -size 2600x3365 xc:white \
	    -gravity center \( ${spm_dir}_${connum0}.png -resize 2400x \) -composite \
	    -gravity North -pointsize 48 -annotate +0+100 \
	    "NVS fMRI, ${spm_dir}, contrast ${connum}: ${conname}" \
	    -gravity SouthEast -pointsize 48 -annotate +100+100 "${thedate}" \
	    page_${spm_dir}_${connum0}.png

done


# Combine
convert -size 2600x3365 xc:white \
	-gravity center \( first_level_design_nvs_001.png -resize 2000x \) -composite \
	-gravity SouthEast -pointsize 48 -annotate +100+100 "${thedate}" \
	page_design_nvs.png

convert -size 2600x3365 xc:white \
	-gravity center \( first_level_result_nvs_001.png -resize 2000x \) -composite \
	-gravity SouthEast -pointsize 48 -annotate +100+100 "${thedate}" \
	page_result_nvs.png

convert \
    page_design_nvs.png page_result_nvs.png page_spm_nvs_*.png \
    nvs-fmri.pdf

