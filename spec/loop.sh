#!/bin/bash
while [ true ] ; do
   read -n 1
   if [ $? = 0 ] ; then
      clear
      rspec -c -fd 
   else
      echo Press any key to run all tests...
   fi
done
