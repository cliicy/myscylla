#!/bin/bash

cfg_file=$1
if [ "$1" = "" ]; then echo -e "Usage:\n\t2_initdb.sh cfg_file"; exit 1; fi
if [ ! -e ${cfg_file} ]; then echo "can't find configuration file [${cfg_file}]", exit 2; fi
source ${cfg_file}

if [ "${scylla_datadir}" != "" ] && [ ! -e ${scylla_datadir} ];
then
        sudo chown -R tcn:tcn ${scylla_datadir}
	rm -rf ${scylla_datadir}/*
fi

if [ "${scylla_datadir}" != "" ] && [ ! -e ${scylla_datadir} ];
then 
        sudo mkdir -p ${scylla_datadir};
fi

if [ "${scylla_logdir}" != "" ] && [ ! -e ${scylla_logdir} ];
then 
        sudo mkdir -p ${scylla_logdir};
fi

#sudo chown -R `whoami`:`whoami` ${scylla_datadir}
sudo chown -R scylla:scylla ${scylla_datadir}


sh start_scylla_svr.sh

for i in {0..100};
do
    if [ "" ==  "`sudo netstat -anp| grep -w ${port}`" ];
    then 
        echo "starting cqlsh - waited $((${i}*${rpt_interval})) second(s)"; sleep ${rpt_interval};
    else  
        echo "cqlsh started"; 
        break;
    fi
done
#cqlsh 192.168.10.202 -f /opt/app-benchmark/scylladb3.0/scripts/vanda3.2t/cfg/ycsb.cql
cql_path=${cnfdir}/${scylla_cql}
echo "cqlsh ${hosts} -f ${cql_path}"
cqlsh ${hosts} -f ${cql_path}
