#!/bin/bash

cat "$@" \
   | awk 'BEGIN {
            B=0;
            cmd="openssl x509 -startdate -enddate -subject -issuer -in /dev/stdin"
         }
         
         /-----BEGIN CERTIFICATE-----/ {
            B=1
            print "------------------------------"
         }
         
         B == 1 {
            print | cmd;
         }
         
         /-----END CERTIFICATE-----/ {
            B=0;
            close(cmd);
            print "------------------------------"
         }'
