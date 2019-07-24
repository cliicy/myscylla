#!/bin/bash

cfg_file=$1
if [ "$1" = "" ]; then echo -e "Usage:\n\t2_initdb.sh cfg_file"; exit 1; fi
if [ ! -e ${cfg_file} ]; then echo "can't find configuration file [${cfg_file}]", exit 2; fi
source ${cfg_file}

if [ "${scylladb_datadir}" != "" ] && [ ! -e ${scylladb_datadir} ];
then 
        sudo mkdir -p ${scylladb_datadir};
fi

if [ "${scylladb_logdir}" != "" ] && [ ! -e ${scylladb_logdir} ];
then 
        sudo mkdir -p ${scylladb_logdir};
fi

#sudo chown -R `whoami`:`whoami` ${scylladb_datadir}
sudo chown -R scylla:scylla ${scylladb_datadir}


sh start_scylla_svr.sh

for i in {0..100};
do
    if [ "" ==  "`netstat -anp| grep 9042`" ];
    then 
        echo "starting cqlsh - waited $((${i}*${rpt_interval})) second(s)"; sleep ${rpt_interval};
    else  
        echo "cqlsh started"; 
        break;
    fi
done
#cqlsh 192.168.10.202 -f /opt/app-benchmark/scylladb3.0/scripts/vanda3.2t/cfg/ycsb.cql
cqlsh 192.168.10.202 -f ${scylladb_cql}
