#!/bin/bash

./1_prep_dev.sh ./cfg/case.cfg
./2_initdb.sh   ./cfg/case.cfg
./3_run.sh      ./cfg/case.cfg
