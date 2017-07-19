#!/bin/bash
# requires list of addresses in /root/exam/nmap_scans/iplist.txt

  # Colours
  ESC="\e["
  RESET=$ESC"39m"
  RED=$ESC"31m"
  GREEN=$ESC"32m"
  BLUE=$ESC"34m"
  YELLOW=$ESC"33m"

function enumeration_scan {
  echo ""
  echo "               w----------------------------------------------------------------w"
  echo "               |                                                                |"
  echo "               |                   Nmap Enumeration Scan                        |"
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

  enumeration_scan  

# do a nmap tcp all ports scan and run searchsploit on the results

  echo ""
  echo "                ***********************************************************************"
  echo "                |                                                                     |"
  echo "                |               Now starting a TCP all ports/UDP scan!                |"  
  echo "                |                                                                     |"
  echo "                ***********************************************************************"
  echo ""

for ip in $(cat /root/exam/nmap_scans/iplist.txt); do
mkdir -p /root/exam/nmap_scans/$ip/

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}TCP all ports nmap scan for $ip...${RESET}\n"
  printf "\n"
  nmap -vv -sS -Pn -T4 -p- -oX /root/exam/nmap_scans/$ip/allports-scan.xml $ip && xsltproc /root/exam/nmap_scans/$ip/allports-scan.xml \
  -o /root/exam/nmap_scans/$ip/allports-scan-report.html
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}UDP nmap scan for $ip...${RESET}\n"
  printf "\n"
  nmap -sU -vv -Pn --stats-every 3m --max-retries 2 -oX /root/exam/nmap_scans/$ip/udp-scan.xml $ip && xsltproc /root/exam/nmap_scans/$ip/udp-scan.xml \
  -o /root/exam/nmap_scans/$ip/udp-scan-report.html
  
  sleep 5;
  /usr/bin/firefox &
  firefox /root/exam/nmap_scans/$ip/allports-scan-report.html
  firefox /root/exam/nmap_scans/$ip/udp-scan-report.html
  
  next_host
done
    
# do a detailed nmap scan over all tcp ports

  echo ""
  echo "                 ************************************************************************"
  echo "                 |                                                                       |"
  echo "                 |               Now starting detailed all ports TCP scan!               |"  
  echo "                 |                       This may take a while...                        |"
  echo "                 |                                                                       |"
  echo "                 ************************************************************************"
  echo ""

for ip in $(cat /root/exam/nmap_scans/iplist.txt); do

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Detailed TCP nmap scan for $ip...${RESET}\n"
  printf "\n"
  nmap -vv -sV -sC -Pn --reason --version-all -T4 -p- -A -oX /root/exam/nmap_scans/$ip/detailed-scan.xml $ip && xsltproc /root/exam/nmap_scans/$ip/detailed-scan.xml \
  -o /root/exam/nmap_scans/$ip/detailed-scan-report.html
  printf "\n"
  printf "Now running searchsploit over results\n"
  printf "Please advise this is not 100 percent and manual testings are preferred, due to nmap output\n"
  printf "\n"
  # printf "View results with #cat searchsploit-results.xml\n"
  sleep 2;
  searchsploit -v --nmap /root/exam/nmap_scans/$ip/detailed-scan.xml >> /root/exam/nmap_scans/$ip/detailed_searchsploit-results.xml
  printf "\n"
  firefox /root/exam/nmap_scans/$ip/detailed-scan-report.html
  sleep 5;
  
  next_host
done

  echo ""
  echo "                *****************************************************************"
  echo "                |                                                               |"
  echo "                |                Now starting the Nmap NSE scan!                |"  
  echo "                |                                                               |"
  echo "                *****************************************************************"
  echo ""

# Run a NSE Scan for all IP addresses in iplist.txt and output to firefox

for ip in $(cat /root/exam/nmap_scans/iplist.txt); do

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap FTP NSE scan over port 21 for $ip...${RESET}\n"
  printf "\n"
  nmap -sS -vv -Pn -p 21 --script=ftp-anon,ftp-bounce,ftp-libopie,ftp-proftpd-backdoor,ftp-vsftpd-backdoor,ftp-vuln-cve2010-4221 \
  -oX /root/exam/nmap_scans/$ip/ftp_port21.xml $ip && xsltproc /root/exam/nmap_scans/$ip/ftp_port21.xml \
  -o /root/exam/nmap_scans/$ip/ftp_port21_report_$ip.html
  sleep 5;

# I havent added nmap nse script for port 22
# This will usually just be for brute forcing the host

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap SMTP NSE scan over port 25 for $ip...${RESET}\n"
  printf "\n"
  nmap -sS -vv -p 25 --script=smtp-commands,smtp-enum-users,smtp-open-relay,smtp-vuln-cve2010-4344,smtp-vuln-cve2011-1720,smtp-vuln-cve2011-1764 \
  -oX /root/exam/nmap_scans/$ip/smtp_nse.xml $ip && xsltproc /root/exam/nmap_scans/$ip/smtp_nse.xml \
  -o /root/exam/nmap_scans/$ip/smtp_nse_report.html
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap DNS NSE scan over port 53 for $ip..${RESET}\n"
  printf "\n"
  nmap -sV -vv -sC -p 53 --script=broadcast-dns-service-discovery \
  -oX /root/exam/nmap_scans/$ip/dns_nse.xml $ip && xsltproc /root/exam/nmap_scans/$ip/dns_nse.xml \
  -o /root/exam/nmap_scans/$ip/dns_nse_report_$ip.html
  sleep 5;  

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap HTTP NSE scan over port 80 for $ip...${RESET}\n"
  printf "\n"
  nmap -sS -vv -Pn -p 80,8080,8000 --script=http-auth-finder,http-comments-displayer,http-config-backup,http-method-tamper,http-passwd,http-default-accounts,http-robots.txt,http-enum,http-exif-spider,http-fileupload-exploiter,http-php-version,http-sql-injection,http-userdir-enum \
  -oX /root/exam/nmap_scans/$ip/http_port80.xml $ip && xsltproc /root/exam/nmap_scans/$ip/http_port80.xml \
  -o /root/exam/nmap_scans/$ip/http_port80_report.html
  sleep 5;

# not scanning for pop3
# not running pop3-brute in this scan

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap NFS NSE scan over port 111 for $ip...${RESET}\n"
  printf "\n"
  nmap -sS -vv -Pn -p 111 --script=nfs-ls,nfs-showmount,nfs-statfs \
  -oX /root/exam/nmap_scans/$ip/nfs_port111.xml $ip && xsltproc /root/exam/nmap_scans/$ip/nfs_port111.xml \
  -o /root/exam/nmap_scans/$ip/nfs_port111_report.html
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap SMB NSE scan over port 139 and 445 for $ip...${RESET}\n"
  printf "\n"
  nmap -sS -Pn -vv -p 139,445 --script=smb-enum-domains,smb-os-discovery,smb-enum-shares,smb-enum-users,smb-enum-sessions,smb-enum-groups,smb-enum-processes,smb-server-stats,smb-system-info,smbv2-enabled \
  -oX /root/exam/nmap_scans/$ip/smb_nse.xml $ip && xsltproc /root/exam/nmap_scans/$ip/smb_nse.xml \
  -o /root/exam/nmap_scans/$ip/smb_nse_report.html
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap SMB_Vulns NSE scan over port 139 and 445 for $ip...${RESET}\n"
  printf "\n"
  nmap -sS -vv -p 139,445 --script-args=unsafe=1 --script=smb-vuln-conficker,smb-vuln-cve2009-3103,smb-vuln-ms06-025,smb-vuln-ms07-029,smb-vuln-ms08-067,smb-vuln-ms10-054,smb-vuln-ms10-061,smb-vuln-regsvc-dos \
  -oX /root/exam/nmap_scans/$ip/smb_nse_vuln.xml $ip && xsltproc /root/exam/nmap_scans/$ip/smb_nse_vuln.xml \
  -o /root/exam/nmap_scans/$ip/smb_nse_vuln_report.html
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap SNMP NSE scan over port 161 for $ip...${RESET}\n"
  printf "\n"
  nmap -sS -vv -p 161 --script=snmp-info,snmp-netstat,snmp-processes,snmp-sysdescr,snmp-win32-services,snmp-win32-shares,snmp-win32-software,snmp-win32-users \
  -oX /root/exam/nmap_scans/$ip/snmp_nse.xml $ip && xsltproc /root/exam/nmap_scans/$ip/snmp_nse.xml \
  -o /root/exam/nmap_scans/$ip/snmp_nse_report.html
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap HTTPS NSE scan over port 443 for $ip...${RESET}\n"
  printf "\n"
  nmap -sS -vv -p 443 --script-args vulns.showall --script=ssl-heartbleed,ssl-poodle,ssl-dh-params \
  -oX /root/exam/nmap_scans/$ip/https_nse.xml $ip && xsltproc /root/exam/nmap_scans/$ip/https_nse.xml \
  -o /root/exam/nmap_scans/$ip/https_nse_report.html
  sleep 5;  

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap MySQL NSE scan over port 3306 for $ip...${RESET}\n"
  printf "\n"
  nmap -sS -vv -p 445,1433,3306 --script=ms-sql-info,mysql-audit,mysql-databases,mysql-dump-hashes,mysql-empty-password,mysql-enum,mysql-info,mysql-query,mysql-users,mysql-variables,mysql-vuln-cve2012-2122 \
  -oX /root/exam/nmap_scans/$ip/mysql_nse.xml $ip && xsltproc /root/exam/nmap_scans/$ip/mysql_nse.xml \
  -o /root/exam/nmap_scans/$ip/mysql_nse_report.html
  sleep 5;

    printf "Now to output all NSE scans for $ip to firefox!\n"
    firefox /root/exam/nmap_scans/$ip/ftp_port21_report_$ip.html
    firefox /root/exam/nmap_scans/$ip/dns_nse_report_$ip.html
    firefox /root/exam/nmap_scans/$ip/http_port80_report.html
    sleep 2;
    firefox /root/exam/nmap_scans/$ip/nfs_port111_report.html
    firefox /root/exam/nmap_scans/$ip/smb_nse_report.html
    firefox /root/exam/nmap_scans/$ip/smb_nse_vuln_report.html
    sleep 2;
    firefox /root/exam/nmap_scans/$ip/snmp_nse_report.html
    firefox /root/exam/nmap_scans/$ip/https_nse_report.html
    firefox /root/exam/nmap_scans/$ip/mysql_nse_report.html
    sleep 2;
done

printf "${RED}[+]${RESET} Scans completed\n"
printf "${RED}[+]${RESET} Results saved to /root/exam/nmap_scans/'IP_ADDRESS'\n"
printf "${RED}[+]${RESET} For more port information, follow: 0daySecurity Enumeration\n"
printf "${RED}[+]${RESET} Now starting Burp Suite for Active Spidering/Web Applications\n"
burpsuite
exit