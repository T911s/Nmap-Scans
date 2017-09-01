#!/bin/bash
#
# t911's sn@ke multi-tool scanner was used in the OSCP
# It is essentially a custom tool scanner, so if you dont have the tool installed it may just skip it.
# It was designed to enumerate fast while gathering as much information as possible.
# 
# It requires manually inputting the target IP address/es in /root/sn@ke/iplist2.txt
# 
# I am not responsible for this script being run on networks without approved authorization
# Use your head. Be smart about where you run this script.

  # Colours
  ESC="\e["
  RESET=$ESC"39m"
  RED=$ESC"31m"
  GREEN=$ESC"32m"
  BLUE=$ESC"34m"
  YELLOW=$ESC"33m"

function enumeration_scan {
  echo ""
  echo "               w---------------------------------------------------------------w"
  echo "               |                                                               |"
  echo "               |                     sn@ke Multi Tool Scanner                  |"
  echo "               |                         ----------()<                  -t911  |"
  echo "               w---------------------------------------------------------------w"
  echo ""
}

function next_host {
  printf "\n"
  printf "*************************************************"
  printf "       ${GREEN}Starting next host!${RESET}       "
  printf "*************************************************"
  printf "\n"
}

enumeration_scan

for ip in $(cat /root/sn@ke/iplist2.txt); do
  mkdir -p /root/sn@ke/hosts/$ip/enumeration/

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Fingerprinting NBT version for $ip...${RESET}\n"
  nbtscan -v $ip \
  > /root/sn@ke/hosts/$ip/enumeration/nbtscan_results.txt
  cat /root/sn@ke/hosts/$ip/enumeration/nbtscan_results.txt
  printf "Completed!\n"
  sleep 3;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Fingerprinting SMB version for $ip...${RESET}\n"
  smbclient -L //$ip \
  > /root/sn@ke/hosts/$ip/enumeration/smbclient_results.txt
  cat /root/sn@ke/hosts/$ip/enumeration/smbclient_results.txt
  printf "Completed!\n"
  printf "Make sure you test for null sessions ""...\n"
  sleep 3;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Enum4linux scan for $ip...${RESET}\n"
  printf "${RED}RID Cycling will not be run${RESET}\n"
  enum4linux -v -U -S -G -M -P -o -n $ip \
  > /root/sn@ke/hosts/$ip/enumeration/enum4linux_results.txt
  cat /root/sn@ke/hosts/$ip/enumeration/enum4linux_results.txt
  printf "Completed!\n"
  sleep 3;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Samrdump scan for $ip without credentials..${RESET}\n"
  samrdump.py $ip \
  > /root/sn@ke/hosts/$ip/enumeration/samrdump_nocreds_results.txt
  cat /root/sn@ke/hosts/$ip/enumeration/samrdump_nocreds_results.txt
  printf "Completed!\n"
  sleep 3;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}snmp-check scan for $ip over UDP 161${RESET}\n"
  perl /root/tools/snmp-check/snmp-check.pl -t $ip -c public \
  > /root/sn@ke/hosts/$ip/enumeration/snmp-check_results.txt
  cat /root/sn@ke/hosts/$ip/enumeration/snmp-check_results.txt
  printf "Completed!\n"
  sleep 3;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}onesixtyone scan for $ip...${RESET}\n"
  onesixtyone -c /root/wordlists/dict.txt $ip \
  > /root/sn@ke/hosts/$ip/enumeration/onesixtyone_results.txt
  cat /root/sn@ke/hosts/$ip/enumeration/onesixtyone_results.txt
  printf "Completed!\n"
  sleep 3;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}smtp-user-enum scan for $ip...${RESET}\n"
  smtp-user-enum -M VRFY -U /root/wordlists/names.txt -t $ip \
  > /root/sn@ke/hosts/$ip/enumeration/smtp-users_results.txt
  cat /root/sn@ke/hosts/$ip/enumeration/smtp-users_results.txt
  printf "Completed!\n"
  sleep 3;  
  
  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Gobuster scripts $ip... on port 80..${RESET}\n"
  printf "Starting gobuster script with common.txt wordlist against http://$ip/\n"
  gobuster -u http://$ip -w /root/wordlists/common.txt -s '200,204,301,302,307,403,500' -e \
  > /root/sn@ke/hosts/$ip/enumeration/gobuster-common_wordlist.txt
  cat /root/sn@ke/hosts/$ip/enumeration/gobuster-common_wordlist.txt
  printf "Completed!\n"
  printf "Remember to check any subdirectories ;)\n"
  sleep 3;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Nikto for $ip... on port 80..${RESET}\n"
  nikto -c all v -h http://$ip -Format xml -output /root/sn@ke/hosts/$ip/enumeration/nikto_scan.xml
  printf "Completed!\n"
  sleep 3;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Ident for $ip... on port 113..${RESET}\n"
  ident-user-enum $ip 22 53 111 113 512 513 514 515 \
  > /root/sn@ke/hosts/$ip/enumeration/ident_scan.txt
  cat /root/sn@ke/hosts/$ip/enumeration/ident_scan.txt
  printf "Completed!\n"
  sleep 3;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Reverse dnsrecon lookup for $ip... on port 53..${RESET}\n"
  dnsrecon -r $ip  \
  > /root/sn@ke/hosts/$ip/enumeration/reversedns_scan.txt
  cat /root/sn@ke/hosts/$ip/enumeration/reversedns_scan.txt
  printf "Completed!\n"
  sleep 3;

  next_host

printf "All results located at /root/sn@ke/hosts/IP_Address/\n"
done
exit