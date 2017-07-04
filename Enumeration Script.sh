#!/bin/bash

# Running this script in a production environment would be a bad idea -
# it is very chatty and would likely get you in trouble. Don't use this
# anywhere you don't have permission!

# To do: 
# allow user to specify a folder to download content into
# allow to run against multiple ip address, might need for loop

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

for ip in $(cat /root/exam6/nmap_scans/iplist.txt); do
  mkdir -p /root/exam6/nmap_scans/$ip/

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Fast nmap scan for $ip...\n"
  printf "\n"
  nmap -v -sV -Pn -T4 -oX /root/exam6/nmap_scans/$ip/fast-scan.xml $ip && xsltproc /root/exam6/nmap_scans/$ip/fast-scan.xml -o /root/exam6/nmap_scans/$ip/fast-scan-report.html
  firefox /root/exam6/nmap_scans/$ip/fast-scan-report.html

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}UDP nmap scan for $ip...{RESET}\n"
  printf "\n"
  nmap -sU -vv -Pn --stats-every 3m --max-retries 2 -oX /root/exam6/nmap_scans/$ip/udp-scan.xml $ip && xsltproc /root/exam6/nmap_scans/$ip/udp-scan.xml -o /root/exam6/nmap_scans/$$
  firefox /root/exam6/nmap_scans/$ip/udp-scan-report.html

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Enum4linux scan for $ip...{RESET}\n"
  printf "\n"
  enum4linux -a $ip >> /root/exam6/nmap_scans/$ip/enum4linux_results.txt

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}onesixtyone scan for $ip...{RESET}\n"
  printf "\n"
  onesixtyone $ip -o /root/exam6/nmap_scans/$ip/onesixtyone_results.txt

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Gobuster scripts $ip...{RESET}\n"
  printf "\n"
  printf "Starting gobuster script with common.txt wordlist"
  gobuster -u http://$ip -w /root/wordlists/common.txt -s '200,204,301,302,307,403,500' -e >> /root/exam6/nmap_scans/$ip/gobuster-common_$ip.txt

# Do I really need this? It's a longer scan than common.txt wordlist..
# printf 'Starting gobuster script with big.txt wordlist"
# gobuster -u http://$ip -w /root/wordlists/big.txt -s "200,204,301,302,307,403,500' -e  >> /root/exam6/nmap_scans/$ip/gobuster-big_$ip.txt
  
  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Nikto for $ip...{RESET}\n"
  printf "\n"
  nikto -h $ip -F html -output /root/exam6/nmap_scans/$ip/nikto_$ip.html
  firefox /root/exam6/nmap_scans/$ip/nikto_$ip.html

  printf "\n"
  printf "++++++++++++++++++++"
  printf "${GREEN}starting next host!{RESET}"
  printf "++++++++++++++++++++"
done