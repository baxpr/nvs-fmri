#!/usr/bin/env bash
#
# Primary entrypoint

echo Running $(basename "${BASH_SOURCE}")

# Initialize defaults
export hpf_sec=300
export input_fwhm_mm=0
export ppi_fwhm_mm=6
export ppiroi_niigz="none"
export ppiroilabels_tsv="none"
export ppi_subjlabel="subj"
export out_dir=/OUTPUTS

# Parse input 
while [[ $# -gt 0 ]]; do
    key="${1}"
    case $key in   
        --fmriprep1_dir)     export fmriprep1_dir="${2}";     shift; shift ;;
        --fmriprep2_dir)     export fmriprep2_dir="${2}";     shift; shift ;;
        --fmriprep3_dir)     export fmriprep3_dir="${2}";     shift; shift ;;
        --fmriprep4_dir)     export fmriprep4_dir="${2}";     shift; shift ;;
        --eprime_txt)        export eprime_txt="${2}";        shift; shift ;;
        --hpf_sec)           export hpf_sec="${2}";           shift; shift ;;
        --input_fwhm_mm)     export input_fwhm_mm="${2}";     shift; shift ;;
        --ppi_fwhm_mm)       export ppi_fwhm_mm="${2}";       shift; shift ;;
        --ppiroi_niigz)      export ppiroi_niigz="${2}";      shift; shift ;;
        --ppiroilabels_tsv)  export ppiroilabels_tsv="${2}";  shift; shift ;;
        --ppi_subjlabel)     export ppi_subjlabel="${2}";     shift; shift ;;
        --out_dir)           export out_dir="${2}";           shift; shift ;;
        *) echo "Input ${1} not recognized" ; shift ;;
    esac
done

# Convert the eprime file
eprime_to_csv.py -o "${out_dir}"/eprime.csv "${eprime_txt}"

# Run the matlab pipeline in xvfb
run_spm8.sh "${MATLAB_RUNTIME}" function matlab_entrypoint \
    fmriprep1_dir "${fmriprep1_dir}" \
    fmriprep2_dir "${fmriprep2_dir}" \
    fmriprep3_dir "${fmriprep3_dir}" \
    fmriprep4_dir "${fmriprep4_dir}" \
    eprime_csv "${out_dir}"/eprime.csv \
    ppiroi_niigz "${ppiroi_niigz}" \
    ppiroilabels_tsv "${ppiroilabels_tsv}" \
    ppi_subjlabel "${ppi_subjlabel}" \
    hpf_sec "${hpf_sec}" \
    input_fwhm_mm "${input_fwhm_mm}" \
    ppi_fwhm_mm "${ppi_fwhm_mm}" \
    out_dir "${out_dir}"

# Freeview-based PDF creation
make_pdf.sh

# Finalize and organize outputs
finalize.sh
