#!/bin/bash

# Note: this script requires a pre-existing text file
# '/root/iplist.txt)' with one IP address per line to scan.
# You will also need 'seclists' installed here: /root/scripts/seclists
# (find it at https://github.com/danielmiessler/SecLists)

# Running this script in a production environment would be a bad idea -
# it is very chatty and would likely get you in trouble. Don't use this
# anywhere you don't have permission!

# The output is individual text files sorted in folders by target IP located
# in '/root/recon/'

# Usage: ./initial-scan.sh
  printf "Enumeration Scan\n"
  printf "Please enter the folder location\n"
  printf "eg: /root/exam6/Nmap_Scans/Host_1/Results/\n"
  read folder


# Kick off general tasks - some in background
  printf "Enter IP: "
  read ip

  echo "Kicking off top ports nmap for $ip..."; \
  nmap -v -sV -Pn -T4 --reason -v \
    -oX $folder/fast-scan.xml $ip \
    && xsltproc $folder/fast-scan.xml \
    -o $folder/fast-scan-report_$ip.xml \
  firefox $folder/fast-scan-report_$ip.xml & \ 

  printf "Sleeping 10 seconds...\n"; sleep 10; \
  printf "Kicking off UDP nmap for $ip...\n"; \
  nmap -sU -v -Pn $ip 
   -oX $folder/udp-scan.xml $ip \
   && xsltproc $folder/udp-scan.xml \
   -o $folder/udp-scan-report_$ip.xml \
   firefox $folder/udp-scan-report_$ip.xml & \

  printf "Sleeping 10 seconds...\n"; sleep 10; \
  printf "Kicking off enum4linux for $ip... in background"; \
  nohup enum4linux -a $ip
  >> $folder/$ip-enum4linux.txt & \
  
  echo "Sleeping 10 seconds..."; sleep 10; \
  echo "Kicking off onesixtyone for $ip..."; \
  nohup onesixtyone $ip 
  >> $folder/$ip-onesixtyone.txt & \

  echo "Sleeping 10 seconds..."; sleep 10; \
  echo "Kicking off Gobuster scripts in background for $ip..."; \
  gobuster -u http://$ip \
    -w /root/worldlists/common.txt \
    -s '200,204,301,302,307,403,500' -e \
    >> $folder/$ip-gobuster-common.txt & \
  sleep 5; \
  gobuster -u http://$ip \
    -w /root/worldlists/cgis.txt \
    -s '200,204,301,302,307,403,500' -e \
    >> $folder/$ip-gobuster-cgis.txt & \

  echo "Sleeping 10 seconds..."; sleep 10; \
  echo "Kicking off nikto in background for $ip..."; \
  nohup nikto -h $ip >> /root/recon/$ip/$ip-nikto.txt & \

  echo "Sleeping 10 seconds..."; sleep 10; \
done
