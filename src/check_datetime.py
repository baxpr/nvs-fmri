#!/usr/bin/env python3

import argparse
from datetime import datetime
import pydicom

parser = argparse.ArgumentParser()
parser.add_argument('--fmri_dcm', required=True)
parser.add_argument('--eprime_txt', required=True)
args = parser.parse_args()

# Get date/time from eprime .txt
eprime_date = ''
eprime_time = ''
with open(args.eprime_txt, encoding='utf-16') as ep:
    ln = ep.readline()
    while ln:
        pfx = 'SessionDate: '
        if ln.startswith(pfx):
            eprime_date = ln[len(pfx):-1]
        pfx = 'SessionTime: '
        if ln.startswith(pfx):
            eprime_time = ln[len(pfx):-1]
            break
        ln = ep.readline()

if not eprime_time:
    raise Exception('Could not get date/time from eprime .txt')

ds = pydicom.dcmread(args.fmri_dcm)
dcm_datetime = ds['AcquisitionDateTime'].value

print(eprime_date)
print(eprime_time)
print(dcm_datetime)
