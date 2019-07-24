#! /bin/bash

cfg_file=$1
if [ "${cfg_file}" = "" ]; then echo -e "Usage:\n\t3_run.sh cfg_file"; exit 1; fi
if [ ! -e ${cfg_file} ]; then echo "can't find configuration file [${cfg_file}]", exit 2; fi
source ${cfg_file}

# output_dir will be used in fio.sh, so make it global
if [ "${output_dir}" == "" ]; 
then
        echo "export output_dir=${result_dir}/ycsb-scylla-`date +%Y%m%d_%H%M%S`${case_id}_${threads}td_${scylladb_cql%.cql}"
        export output_dir=${result_dir}/ycsb-scylla-`date +%Y%m%d_%H%M%S`${case_id}_${threads}td_${scylladb_cql%.cql}
fi

echo "test output will be saved in ${output_dir}"

