#!/bin/bash

# Running this script in a production environment would be a bad idea -
# it is very chatty and would likely get you in trouble. Don't use this
# anywhere you don't have permission!

# Usage: ./enumeration_script.sh
  printf "Enumeration Scan\n"
  printf "Please enter the folder location\n"
  printf "eg: /root/exam6/Nmap_Scans/Host_1/Results/\n"
  read folder

# Kick off general tasks - some in background
  printf "Enter IP: "
  read ip

  printf "Kicking off fast nmap scan for $ip...\n"
  nmap -v -sV -Pn -T4 -oX $folder/fast-scan.xml $ip && xsltproc $folder/fast-scan.xml -o $folder/fast-scan-report_$ip.html
  firefox $folder/fast-scan-report_$ip.html

  printf "Kicking off UDP nmap for $ip...\n"
  nmap -sU -v -Pn -oX $folder/udp-scan.xml $ip && xsltproc $folder/udp-scan.xml -o $folder/udp-scan-report_$ip.html
  firefox $folder/udp-scan-report_$ip.html

  printf "Kicking off enum4linux for $ip..."
  enum4linux -a $ip >> $folder/enum4linux_$ip.txt

  printf "Kicking off onesixtyone for $ip..."
  onesixtyone $ip -o $folder/onesixtyone_$ip.txt

  printf "Kicking off Gobuster scripts $ip..."
  gobuster -u http://$ip -w /root/wordlists/common.txt -s '200,204,301,302,307,403,500' -e >> $folder/gobuster-common_$ip.txt
  gobuster -u http://$ip -w /root/wordlists/big.txt -s '200,204,301,302,307,403,500' -e  >> $folder/gobuster-cgis_$ip.txt

  printf "Kicking off nikto for $ip..."
  nikto -h $ip >> $folder/nikto_$ip.txt
done