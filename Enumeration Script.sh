#!/bin/bash

# Running this script in a production environment would be a bad idea -
# it is very chatty and would likely get you in trouble. Don't use this
# anywhere you don't have permission!

# This requires a file with IP addresses in the folder: /root/exam/nmap_scans/iplist.txt
# Also requires the folder /root/exam/nmap_scans/

# Usage: ./enumeration_script.sh


  # Colours
  ESC="\e["
  RESET=$ESC"39m"
  RED=$ESC"31m"
  GREEN=$ESC"32m"
  BLUE=$ESC"34m"

  printf ""
  printf "w------------------w\n"
  printf "| Enumeration Scan |\n"
  printf "w------------------w\n"
  printf ""

for ip in $(cat /root/exam/nmap_scans/iplist.txt); do
  mkdir -p /root/exam/nmap_scans/$ip/

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Fast nmap scan for $ip...${RESET}\n"
  printf "\n"
  nmap -v -sV -Pn -T4 -oX /root/exam/nmap_scans/$ip/fast-scan.xml $ip && xsltproc /root/exam/nmap_scans/$ip/fast-scan.xml -o /root/exam/nmap_scans/$ip/fast-scan-report.html
  firefox /root/exam/nmap_scans/$ip/fast-scan-report.html

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}UDP nmap scan for $ip...${RESET}\n"
  printf "\n"
  nmap -sU -vv -Pn --stats-every 3m --max-retries 2 -oX /root/exam/nmap_scans/$ip/udp-scan.xml $ip && xsltproc /root/exam/nmap_scans/$ip/udp-scan.xml \
  -o /root/exam/nmap_scans/$ip/udp-scan-report.html
  firefox /root/exam/nmap_scans/$ip/udp-scan-report.html

  # enum4linux is set for background process due to its time to complete over VPN
  # thus allowing time to complete until the next ip address runs enum4linx
  # as it runs the same PID, and stops processing any previous enum4linux scans

  #nohup is not currently working.. needs to be run without it until solution found.

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Enum4linux scan for $ip...${RESET}\n"
  printf "\n"
  nohup enum4linux -a $ip &>/dev/null & \
  >> /root/exam/nmap_scans/$ip/enum4linux_results.txt

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}onesixtyone scan for $ip...${RESET}\n"
  printf "\n"
  onesixtyone $ip \
  >> /root/exam/nmap_scans/$ip/onesixtyone_results.txt

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Gobuster scripts $ip...${RESET}\n"
  printf "\n"
  printf "Starting gobuster script with common.txt wordlist"
  printf "\n"
  gobuster -u http://$ip -w /root/wordlists/common.txt -s '200,204,301,302,307,403,500' -e \
  >> /root/exam/nmap_scans/$ip/gobuster-common_$ip.txt

# Do I really need this? It's a longer scan than common.txt wordlist..
# printf 'Starting gobuster script with big.txt wordlist"
# gobuster -u http://$ip -w /root/wordlists/big.txt -s "200,204,301,302,307,403,500' -e  >> /root/exam6/nmap_scans/$ip/gobuster-big_$ip.txt
  
  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Nikto for $ip...${RESET}\n"
  printf "\n"
  nohup nikto -h $ip &>/dev/null & \
  -F html -output /root/exam/nmap_scans/$ip/nikto_$ip.html
  
  # cant output file unless it has completed and especially if run in background process
  # firefox /root/exam/nmap_scans/$ip/nikto_$ip.html

  printf "\n"
  printf "++++++++++++++++++++"
  printf "${GREEN}Starting next host!${RESET}"
  printf "++++++++++++++++++++"
  printf "\n"
done