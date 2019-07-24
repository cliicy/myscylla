#!/bin/bash
## $1 /dev/sfxxxx
## $2 2 or 4 or 6 how many partitions of disk will be parted


case $2 in 
       1) 
         echo "1 partion" 
         echo "mklabel gpt
yes
mkpart primary 0% 100%
quit
" | sudo parted $1
         ;; 
esac 

