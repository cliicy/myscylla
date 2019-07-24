#!/bin/bash

scylla_cql_list="none.cql lz4.cql deflate.cql"
scylla_cql_list="none.cql"
for cql in ${scylla_cql_list};
do
echo "==== scylla_cql=${scylla_cql} cql=${cql}===="
export scylla_cql=${cql}
./1_prep_dev.sh ./cfg/case.cfg
./2_initdb.sh   ./cfg/case.cfg
./3_run.sh   ./cfg/case.cfg
done
