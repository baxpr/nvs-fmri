#!/usr/bin/env python3

import argparse
from datetime import datetime
from datetime import timedelta
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

eprime_dt = datetime.strptime(f'{eprime_date} {eprime_time}', '%m-%d-%Y %H:%M:%S')

dcm_dt = datetime.strptime(dcm_datetime, '%Y%m%d%H%M%S.%f')

dt_diff = abs(eprime_dt - dcm_dt)

if dt_diff > timedelta(minutes=60):
    raise Exception(f'Time difference between eprime and fmri is {dt_diff}')
