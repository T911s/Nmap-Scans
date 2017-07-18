#!/bin/bash

  # Colours
  ESC="\e["
  RESET=$ESC"39m"
  RED=$ESC"31m"
  GREEN=$ESC"32m"
  BLUE=$ESC"34m"
  YELLOW=$ESC"33m"

  function enumeraton_scan {
  echo ""
  echo "               w----------------------------------------------------------------w"
  echo "               |                                                                |"
  echo "               |                        Multi Tool Scan                         |"
  echo "               |                                                         -t911  |"
  echo "               w----------------------------------------------------------------w"
  echo ""
}

  function next_host {
  printf "\n"
  printf "*************************************************"
  printf "       ${GREEN}Starting next host!${RESET}       "
  printf "*************************************************"
  printf "\n"
}

for ip in $(cat /root/exam/nmap_scans/iplist.txt); do
  mkdir -p /root/exam/nmap_scans/$ip/

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}onesixtyone scan for $ip...${RESET}\n"
  onesixtyone -c /root/wordlists/dict.txt $ip \
  >> /root/exam/nmap_scans/$ip/onesixtyone_results.txt
  printf "Completed!\n"
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Samrdump scan for $ip without credentials..${RESET}\n"
  samrdump $ip \
  >> /root/exam/nmap_scans/$ip/samrdump_nocreds_results.txt
  printf "Completed!\n"
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Enum4linux scan for $ip...${RESET}\n"
  printf "${RED}RID Cycling will not be run${RESET}\n"
  enum4linux -v -U -S -G -M -P -o -n $ip \
  >> /root/exam/nmap_scans/$ip/enum4linux_results.txt
  printf "Completed!\n"
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}snmp-check scan for $ip over UDP 161${RESET}\n"
  perl /root/tools/snmp-check/snmp-check.pl -t $ip -c public \
  >> /root/exam/nmap_scans/$ip/snmp-check_results.txt
  printf "Completed!\n"
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}smtp-user-enum scan for $ip...${RESET}\n"
  smtp-user-enum -M VRFY -U /root/wordlists/names.txt -t $ip \
  >> /root/exam/nmap_scans/$ip/smtp-users_results.txt
  printf "Completed!\n"
  sleep 5;  
  
  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Gobuster scripts $ip... on port 80..${RESET}\n"
  printf "Starting gobuster script with common.txt wordlist against http://$ip/\n"
  gobuster -v -u http://$ip -w /root/wordlists/common.txt -s '200,204,301,302,307,403,500' -e \
  >> /root/exam/nmap_scans/$ip/gobuster-common_wordlist.txt
  printf "Completed!\n"
  printf "Remember to check any subdirectories ;)\n"
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Nikto for $ip... on port 80..${RESET}\n"
  nikto -c all v -h http://$ip -Format html -output /root/exam/nmap_scans/$ip/nikto_scan.html
  firefox /root/exam/nmap_scans/$ip/nikto_scan.html
  printf "Completed!\n"
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Ident for $ip... on port 113..${RESET}\n"
  ident-user-enum $ip 22 53 111 113 512 513 514 515 \
  >> /root/exam/nmap_scans/$ip/ident_scan.html
  printf "Completed!\n"
  sleep 5;  
  next_host

printf "All results located at /root/exam/IP_Address/"
done
exit