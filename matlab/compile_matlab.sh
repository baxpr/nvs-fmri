#!/bin/sh

# Working dir
WD=$(pwd)

# Where to find SPM on our compilation machine
SPM_PATH="${WD}"/external/spm8_r6313/spm8

# Add Matlab to the path on the compilation machine
export MATLABROOT=/panfs/accrepfs.vampire/accre/software/easybuild/software/2023/x86-64-v3/Core/matlab/2023a
export PATH=${MATLABROOT}/bin:${PATH}

# We use SPM's standalone tool, but edited to add our own code to the 
# compilation path
matlab -nodisplay -nodesktop -nosplash -sd "${WD}" -r \
    "spm_make_standalone_local('${SPM_PATH}','${WD}/bin','${WD}/src','${WD}/external/gppi','${WD}/../rois'); exit"

# We grant lenient execute permissions to the matlab executable and runscript so
# we don't have hiccups later.
chmod go+rx "${WD}"/bin/spm8
chmod go+rx "${WD}"/bin/run_spm8.sh

