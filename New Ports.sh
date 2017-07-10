#!/bin/bash

    # create newly_discovered ports
    # this will need to be run after the enumeration script
    # means we wont need to re-create the folder path

    printf "Newly discovered ports scan\n"
    printf "Enter ip: \n"
        read ip
    printf "Enter port/s: \n" 
        read ports
            nmap -v -sV -sT -p $ports -oX /root/exam/nmap_scans/$ip/new-ports.xml $ip && xsltproc /root/exam/nmap_scans/$ip/new-ports.xml \
            -o /root/exam/nmap_scans/$ip/new-ports-report.html
        firefox /root/exam/nmap_scans/$ip/new-ports-report.html
    printf "If you think you need to run nmap -A -p $ports then do it \n"
    
    sleep 5;