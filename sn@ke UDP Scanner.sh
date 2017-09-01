#!/bin/bash
#
# t911's sn@ke information gathering script was used in the OSCP
# It was designed to enumerate fast while gathering as much information as possible then outputs to html and opens firefox.
#
# Note: It will only do a UDP ssscan, if you want a TCP ssscan, run the other ssscaner..
# 
# It requires manually inputting the target IP address/es in /root/s@nke/iplist.txt
# 
# I am not responsible for this script being run on networks without approved authorization
# Use your head. Be smart about where you run this script.


function udp_all_ports {
  echo ""
  echo "            *********************************************************************"
  echo "            |                                                                   |"
  echo "            |                    sn@ke UDP all ports Scanner                    |"
  echo "            |                          ----------()<                      -t911 |"
  echo "            *********************************************************************"
  echo ""
}

udp_all_ports

function next_host {
  printf "\n"
  printf "*************************************************"
  printf "       ${GREEN}Starting next host!${RESET}       "
  printf "*************************************************"
  printf "\n"
}


for ip in $(cat /root/sn@ke/iplist.txt); do
  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}UDP nmap scan for $ip...${RESET}\n"
  printf "\n"
  nmap -sU -vv -Pn --stats-every 3m --max-retries 2 -oX /root/sn@ke/hosts/$ip/nmap_scans/udp-scan.xml $ip && xsltproc /root/sn@ke/hosts/$ip/nmap_scans/udp-scan.xml \
  -o /root/sn@ke/hosts/$ip/nmap_scans/udp-scan-report.html

  sleep 2;

  firefox /root/sn@ke/hosts/$ip/nmap_scans/udp-scan-report.html

  next_host

  done

  exit