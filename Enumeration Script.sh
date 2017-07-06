#!/bin/bash

# Running this script in a production environment would be a bad idea -
# it is very chatty and would likely get you in trouble. Don't use this
# anywhere you don't have permission!

# This requires a file with IP addresses in the folder: /root/exam/nmap_scans/iplist.txt
# sleep command was added to script as an error would occur between scans.
# Usage: ./enumeration_script.sh


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
  echo "               |                        Enumeration Scan                        |"
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

  enumeraton_scan

# Run a TCP and UDP Scan for all IP addresses in iplist.txt and output to firefox

for ip in $(cat /root/exam/nmap_scans/iplist.txt); do
  mkdir -p /root/exam/nmap_scans/$ip/

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Fast nmap scan for $ip...${RESET}\n"
  printf "\n"
  nmap -v -sV -Pn -T4 -O -oX /root/exam/nmap_scans/$ip/fast-scan.xml $ip && xsltproc /root/exam/nmap_scans/$ip/fast-scan.xml \
  -o /root/exam/nmap_scans/$ip/fast-scan-report.html
  firefox /root/exam/nmap_scans/$ip/fast-scan-report.html
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}UDP nmap scan for $ip...${RESET}\n"
  printf "\n"
  nmap -sU -vv -Pn --stats-every 3m --max-retries 2 -oX /root/exam/nmap_scans/$ip/udp-scan.xml $ip && xsltproc /root/exam/nmap_scans/$ip/udp-scan.xml \
  -o /root/exam/nmap_scans/$ip/udp-scan-report.html
  firefox /root/exam/nmap_scans/$ip/udp-scan-report.html
    sleep 5;
done

  printf "\n"
  printf "*************************************************"
  printf "   ${GREEN}Now starting TCP NSE scan!${RESET}    "  
  printf "*************************************************"
  printf "\n"

# Run a TCP NSE Scan for all IP addresses in iplist.txt and output to firefox

for ip in $(cat /root/exam/nmap_scans/iplist.txt); do
  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap FTP NSE scan over port 21 for $ip...${RESET}\n"
  printf "\n"
  nmap -sS -vv -Pn -p 21 -T3 --script=ftp-anon,ftp-bounce,ftp-libopie,ftp-proftpd-backdoor,ftp-vsftpd-backdoor,ftp-vuln-cve2010-4221 \
  -oX /root/exam/nmap_scans/$ip/ftp_port21.xml $ip && xsltproc /root/exam/nmap_scans/$ip/ftp_port21.xml \
  -o /root/exam/nmap_scans/$ip/ftp_port21_report_$ip.html
  firefox /root/exam/nmap_scans/$ip/ftp_port21_report_$ip.html
  sleep 5;

  # might skip this one... its a long scan time!
  #printf "\n"
  #printf "${RED}[+]${RESET} ${BLUE} Nmap HTTP NSE scan over port 80 for $ip...${RESET}\n"
  #printf "\n"
  #nmap -sS -vv -Pn -p 80 -T3 --script=http-apache-server-status,http-auth-finder,http-backup-finder,http-cakephp-version,http-comments-displayer,http-config-backup,http-default-accounts,http-enum,http-exif-spider,http-fileupload-exploiter,http-php-version,http-passwd,http-sql-injection,http-userdir-enum \
  #-oX /root/exam/nmap_scans/$ip/http_port80.xml $ip && xsltproc /root/exam/nmap_scans/$ip/http_port80.xml \
  #-o /root/exam/nmap_scans/$ip/http_port80_report.html
  #firefox /root/exam/nmap_scans/$ip/http_port80_report.html
  #sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap SMB NSE scan over port 139 and 445 for $ip...${RESET}\n"
  printf "\n"
  nmap -sS -Pn -vv -p 139,445 --script=smb-enum-domains,smb-os-discovery,smb-enum-shares,smb-enum-users,smb-enum-sessions,smb-enum-groups,smb-enum-processes,smb-server-stats,smb-system-info,smbv2-enabled \
  -oX /root/exam/nmap_scans/$ip/smb_nse.xml $ip && xsltproc /root/exam/nmap_scans/$ip/smb_nse.xml \
  -o /root/exam/nmap_scans/$ip/smb_nse_report.html
  firefox /root/exam/nmap_scans/$ip/smb_nse_report.html
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap SMB_Vulns NSE scan over port 139 and 445 for $ip...${RESET}\n"
  printf "\n"
  nmap -sS -vv -p 139,445 --script-args=unsafe=1 --script=smb-vuln-conficker,smb-vuln-cve2009-3103,smb-vuln-ms06-025,smb-vuln-ms07-029,smb-vuln-ms08-067,smb-vuln-ms10-054,smb-vuln-ms10-061,smb-vuln-regsvc-dos \
  -oX /root/exam/nmap_scans/$ip/smb_nse_vuln.xml $ip && xsltproc /root/exam/nmap_scans/$ip/smb_nse_vuln.xml \
  -o /root/exam/nmap_scans/$ip/smb_nse_vuln_report.html
  firefox /root/exam/nmap_scans/$ip/smb_nse_vuln_report.html
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap SNMP NSE scan over port 161 for $ip...${RESET}\n"
  printf "\n"
  nmap -sS -vv -p 161 --script=snmp-info,snmp-netstat,snmp-processes,snmp-sysdescr,snmp-win32-services,snmp-win32-shares,snmp-win32-software,snmp-win32-users \
  -oX /root/exam/nmap_scans/$ip/snmp_nse.xml $ip && xsltproc /root/exam/nmap_scans/$ip/snmp_nse.xml \
  -o /root/exam/nmap_scans/$ip/snmp_nse_report.html
  firefox /root/exam/nmap_scans/$ip/snmp_nse_report.html
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap MySQL NSE scan over port 3306 for $ip...${RESET}\n"
  printf "\n"
  nmap -sS -vv -p 1433,3306 --script=ms-sql-info,mysql-audit,mysql-databases,mysql-dump-hashes,mysql-empty-password,mysql-enum,mysql-info,mysql-query,mysql-users,mysql-variables,mysql-vuln-cve2012-2122 \
  -oX /root/exam/nmap_scans/$ip/mysql_nse.xml $ip && xsltproc /root/exam/nmap_scans/$ip/mysql_nse.xml \
  -o /root/exam/nmap_scans/$ip/mysql_nse_report.html
  firefox /root/exam/nmap_scans/$ip/mysql_nse_report.html
  sleep 5;
  
  next_host
done  

  printf "\n"
  printf "*************************************************"
  printf "  ${YELLOW}Now starting multi-tool scan!${RESET} "  
  printf "**************************************************"
  printf "\n"

# Run an Enum4linux, Onesixtyone, Gobuster, and Nikto Scan for all IP addresses in iplist.txt and output to txt file

for ip in $(cat /root/exam/nmap_scans/iplist.txt); do
  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Enum4linux scan for $ip...${RESET}\n"
  printf "${RED}RID Cycling will not be run${RESET}\n"
  enum4linux -U -S -G -M -P -o -n $ip \
  >> /root/exam/nmap_scans/$ip/enum4linux_results.txt
  printf "Completed!\n"
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}onesixtyone scan for $ip...${RESET}\n"
  onesixtyone -c dict.txt $ip \
  >> /root/exam/nmap_scans/$ip/onesixtyone_results.txt
  printf "Completed!\n"
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Gobuster scripts $ip...${RESET}\n"
  printf "Starting gobuster script with common.txt wordlist against http://$ip/\n"
  gobuster -u http://$ip -w /root/wordlists/common.txt -s '200,204,301,302,307,403,500' -e \
  >> /root/exam/nmap_scans/$ip/gobuster-common_wordlist.txt
  printf "Completed!\n"
  printf "Remember to check any subdirectories ;)\n"
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Nikto for $ip...${RESET}\n"
  nikto -h $ip \
  >> /root/exam/nmap_scans/$ip/nikto_$ip.txt
  printf "Completed!\n"
  sleep 5;

  # this is testing for nikto output to html (needs testing)

  #-o /root/exam/nmap_scans/$ip/nikto_$ip.xml && xsltproc /root/exam/nmap_scans/$ip/nikto_$ip.xml \
  #-o /root/exam/nmap_scans/$ip/nikto_$ip.html
  #firefox /root/exam/nmap_scans/$ip/nikto_$ip.html

  next_host
done

# Run a TCP and UDP Scan for all IP addresses on all ports in iplist.txt and output to firefox

  echo ""
  echo "********************************************************"
  echo "  ${YELLOW}Now starting detailed TCP/UDP scan!${RESET}  "  
  echo "                  This may take a while...              "
  echo "********************************************************"
  echo ""

for ip in $(cat /root/exam/nmap_scans/iplist.txt); do
  mkdir -p /root/exam/nmap_scans/$ip/

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Detailed TCP nmap scan for $ip...${RESET}\n"
  printf "\n"
  nmap -v -sV -Pn -T3 --reason -p- -A -oX /root/exam/nmap_scans/$ip/detailed-scan.xml $ip && xsltproc /root/exam/nmap_scans/$ip/detailed-scan.xml \
  -o /root/exam/nmap_scans/$ip/detailed-scan-report.html
  firefox /root/exam/nmap_scans/$ip/detailed-scan-report.html

  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Detailed UDP nmap scan for $ip...${RESET}\n"
  printf "\n"
  nmap -sU -vv -Pn -A --stats-every 3m --max-retries 2 -oX /root/exam/nmap_scans/$ip/detailed-udp-scan.xml $ip && xsltproc /root/exam/nmap_scans/$ip/detailed-udp-scan.xml \
  -o /root/exam/nmap_scans/$ip/detailed-udp-scan-report.html
  firefox /root/exam/nmap_scans/$ip/detailed-udp-scan-report.html

  sleep 5;

  next_host
done

printf "${RED}[+]{RESET} Scans completed\n"
printf "${RED}[+]{RESET} Results saved to /root/exam/nmap_scans/'IP_ADDRESS'\n"