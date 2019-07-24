#! /bin/bash

cfg_file=$1
if [ "${cfg_file}" = "" ]; then echo -e "Usage:\n\t3_run.sh cfg_file"; exit 1; fi
if [ ! -e ${cfg_file} ]; then echo "can't find configuration file [${cfg_file}]", exit 2; fi
source ${cfg_file}

# output_dir will be used in fio.sh, so make it global
if [ "${output_dir}" == "" ]; 
then
        export output_dir=${result_dir}/ycsb-scylla-`date +%Y%m%d_%H%M%S`${case_id}_${threads}td_${scylla_cql%.cql}
fi

echo "test output will be saved in ${output_dir}"

if [ ! -e ${output_dir} ]; then mkdir -p ${output_dir}; fi

# collect Scylla startup options / configuration / test script
cp $0 ${output_dir}
cp ${cfg_file} ${output_dir}

source ./common-lib

collect_sys_info ${output_dir} ${css_status}

echo "will run workload(s) ${workload_set}"
for workload in ${workload_set};
    do
        echo "run workload ${workload}"
	cmd="run"
        # workload friendly name. it will be used in fio.sh, so make it global
        export workload_fname=${workload}
        echo ${workload} | grep load
	if [ $? -eq 0 ]; then cmd="load"; fi
        echo -e "sfx_message starts at: " `date +%Y-%m-%d\ %H:%M:%S` "\n"  > ${output_dir}/${workload_fname}.sfx_message
        sudo chmod 666 /var/log/sfx_messages;
	tail -f -n 0 /var/log/sfx_messages >> ${output_dir}/${workload_fname}.sfx_message &
        echo $! > ${output_dir}/tail.${workload_fname}.pid
        echo "iostat start at: " `date +%Y-%m-%d\ %H:%M:%S` > ${output_dir}/${workload_fname}.iostat
        # try to keep existing result file
        if [ -e ${output_dir}/${workload_fname}.result ];
        then
                mv ${output_dir}/${workload_fname}.result ${output_dir}/${workload_fname}-`date +%Y%m%d_%H%M%S`.result
        fi
        echo "${workload_fname} starts at: " `date +%Y-%m-%d\ %H:%M:%S` > ${output_dir}/${workload_fname}.result

        sudo ps -ef | grep ${scylla_basedir} | grep -v grep >> ${output_dir}/${workload_fname}.result
        iostat -txdmc ${rpt_interval} ${disk} >> ${output_dir}/${workload_fname}.iostat &
        echo $! > ${output_dir}/${workload_fname}.iostat.pid
 	
	cp ./workload/${workload} ${output_dir}      
	# run ycsb workload, all parameters are from case-cfg/cfg_file
        time ${yscb_dir}/bin/ycsb.sh ${cmd} cassandra-cql -s -threads ${threads} -p hosts=${hosts} -p status.interval=${rpt_interval} \
                -P ./workload/${workload} \
                >> ${output_dir}/${workload_fname}.result 2>&1

        du --block-size=1G ${scylla_datadir} > ${output_dir}/${workload_fname}.dbsize
        cat /sys/block/${dev_id}/sfx_smart_features/sfx_capacity_stat >> ${output_dir}/${workload_fname}.dbsize
        cp ${scylla_datadir}/LOG ${output_dir}/${workload_fname}.scylla.log
        cp ${scylla_conf} ${output_dir}
        cp ${scylla_svr_conf} ${output_dir}
        sudo du -h ${scylla_ycsb_dir} > ${output_dir}/${workload_fname}.szinfo

        echo -e "\nsfx_messages ends at: `date +%Y-%m-%d_%H:%M:%S`\n"  >> ${output_dir}/${workload_fname}.sfx_message
        echo ${output_dir}/tail.${workload_fname}.pid
        kill `cat ${output_dir}/tail.${workload_fname}.pid`
        rm -f ${output_dir}/tail.${workload_fname}.pid
        echo -e "\niostat ends at: " `date +%Y-%m-%d_%H:%M:%S` >> ${output_dir}/${workload_fname}.iostat
        echo -e "\n${workload_fname}" "\nends at: " "`date +%Y-%m-%d_%H:%M:%S`" >> ${output_dir}/${workload_fname}.result
        echo ${output_dir}/${workload_fname}.iostat.pid
        kill `cat ${output_dir}/${workload_fname}.iostat.pid`
        rm -f ${output_dir}/${workload_fname}.iostat.pid
        # sleep ${sleep_after_case}
    done

generate_csv ${output_dir}
