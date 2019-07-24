#!/bin/bash

kill `ps aux | grep -v grep | grep -e ycsb | cut -c 10-15`

sudo systemctl stop scylla-server
sudo systemctl status scylla-server
