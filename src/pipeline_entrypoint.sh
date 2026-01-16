#!/usr/bin/env bash
#
# Primary entrypoint

echo Running $(basename "${BASH_SOURCE}")

# Initialize defaults
export hpf_sec=300
export fwhm_mm=6
export out_dir=/OUTPUTS

# Parse input 
while [[ $# -gt 0 ]]; do
    key="${1}"
    case $key in   
        --fmriprep1_dir) export fmriprep1_dir="${2}"; shift; shift ;;
        --fmriprep2_dir) export fmriprep2_dir="${2}"; shift; shift ;;
        --fmriprep3_dir) export fmriprep3_dir="${2}"; shift; shift ;;
        --fmriprep4_dir) export fmriprep4_dir="${2}"; shift; shift ;;
        --eprime_txt)    export eprime_txt="${2}";    shift; shift ;;
        --hpf_sec)       export hpf_sec="${2}";       shift; shift ;;
        --fwhm_mm)       export fwhm_mm="${2}";       shift; shift ;;
        --out_dir)       export out_dir="${2}";       shift; shift ;;
        *) echo "Input ${1} not recognized" ; shift ;;
    esac
done

# Convert the eprime file
eprime_to_csv.py -o "${out_dir}"/eprime.csv "${eprime_txt}"

# Run the matlab pipeline in xvfb
xvfb-run -n $(($$ + 99)) -s '-screen 0 1600x1200x24 -ac +extension GLX' \
    matlabcommandline
