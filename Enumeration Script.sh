#!/bin/bash

# Update 07/07/2017
# included detailed scan, testing -A option on all ports
# identified takes about an hour for scan until detailed scan and then it could take up to 30 minutes per host

# Update: 08/07/2017
# Removed -A on the detailed scan, will note the 'new' IPs found and run it on than ALL PORTS
# this will decrease the the completion time of the script
# Fixed nikto from: nikto -h #ip to, nikto -h http://$ip
# need to script test time on 4 hosts

# Running this script in a production environment would be a bad idea -
# it is very chatty and would likely get you in trouble. Don't use this
# anywhere you don't have permission!

# You will need to mkdir -p /root/tools/snmp-check/ and have the file snmp-check.pl in the folder
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
  nmap -v -sV -Pn -T4 -oX /root/exam/nmap_scans/$ip/fast-scan.xml $ip && xsltproc /root/exam/nmap_scans/$ip/fast-scan.xml \
  -o /root/exam/nmap_scans/$ip/fast-scan-report.html
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}UDP nmap scan for $ip...${RESET}\n"
  printf "\n"
  nmap -sU -vv -Pn --stats-every 3m --max-retries 2 -oX /root/exam/nmap_scans/$ip/udp-scan.xml $ip && xsltproc /root/exam/nmap_scans/$ip/udp-scan.xml \
  -o /root/exam/nmap_scans/$ip/udp-scan-report.html
  sleep 5;

  printf "Nmap scan outputs: \n"
    #starts firefox to prevent script bug error occuring
    firefox
    sleep 5;
    firefox /root/exam/nmap_scans/$ip/fast-scan-report.html
    firefox /root/exam/nmap_scans/$ip/udp-scan-report.html
  next_host
done

  printf "\n"
  printf "*************************************************"
  printf "   ${GREEN}Now starting TCP NSE scan!${RESET}    "  
  printf "*************************************************"
  printf "\n"

# Run a TCP NSE Scan for all IP addresses in iplist.txt and output to firefox
for ip in $(cat /root/exam/nmap_scans/iplist.txt); do

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Who owns the services running on $ip ? if ident is running..${RESET}\n"
  printf "\n"
  nmap -sV -vv -sC -p 113 \
  -oX /root/exam/nmap_scans/$ip/service_owners.xml $ip && xsltproc /root/exam/nmap_scans/$ip/service_owners.xml \
  -o /root/exam/nmap_scans/$ip/service_owners_report_$ip.html
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap FTP NSE scan over port 21 for $ip...${RESET}\n"
  printf "\n"
  nmap -sS -vv -Pn -p 21 --script=ftp-anon,ftp-bounce,ftp-libopie,ftp-proftpd-backdoor,ftp-vsftpd-backdoor,ftp-vuln-cve2010-4221 \
  -oX /root/exam/nmap_scans/$ip/ftp_port21.xml $ip && xsltproc /root/exam/nmap_scans/$ip/ftp_port21.xml \
  -o /root/exam/nmap_scans/$ip/ftp_port21_report_$ip.html
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap SMTP NSE scan over port 25 for $ip...${RESET}\n"
  printf "\n"
  nmap -sS -vv -p 25 --script=smtp-commands,smtp-enum-users,smtp-open-relay,smtp-vuln-cve2010-4344,smtp-vuln-cve2011-1720,smtp-vuln-cve2011-1764 \
  -oX /root/exam/nmap_scans/$ip/smtp_nse.xml $ip && xsltproc /root/exam/nmap_scans/$ip/smtp_nse.xml \
  -o /root/exam/nmap_scans/$ip/smtp_nse_report.html
  sleep 5;  

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap HTTP NSE scan over port 80 for $ip...${RESET}\n"
  printf "\n"
  nmap -sS -vv -Pn -p 80,8080,8000 --script=http-auth-finder,http-comments-displayer,http-config-backup,http-method-tamper,http-passwd,http-default-accounts,http-robots.txt,http-enum,http-exif-spider,http-fileupload-exploiter,http-php-version,http-sql-injection,http-userdir-enum \
  -oX /root/exam/nmap_scans/$ip/http_port80.xml $ip && xsltproc /root/exam/nmap_scans/$ip/http_port80.xml \
  -o /root/exam/nmap_scans/$ip/http_port80_report.html
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap NFS NSE scan over port 111 for $ip...${RESET}\n"
  printf "\n"
  nmap -sS -vv -Pn -p 111 --script=nfs-ls,nfs-showmount,nfs-statfs \
  -oX /root/exam/nmap_scans/$ip/nfs_port111.xml $ip && xsltproc /root/exam/nmap_scans/$ip/nfs_port111.xml \
  -o /root/exam/nmap_scans/$ip/nfs_port111_report.html
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap HTTP Shellshock NSE scan over port 80 for $ip...${RESET}\n"
  printf "This will check if the host is vulnerable over /cgi-bin/admin.cgi\n"
  printf "\n"
  # checks if any if cgi-bin is accessible
  curl -i http://$ip/cgi-bin/
  printf "\n"
  #output to confirm if vulnable pages are accessible
  curl -i http://$ip/cgi-bin/admin.cgi
  printf "\n"
  curl -i http://$ip/cgi-bin/test.cgi
  printf "\n"
  curl -i http://$ip/cgi-bin/status
  printf "\n"
  #confirm if admin.cgi is accessible and vulnerable
  nmap -vv -p 80,8080,8000 --script=http-shellshock --script-args uri=/cgi-bin/admin.cgi \
  -oX /root/exam/nmap_scans/$ip/http_shellshock80.xml $ip && xsltproc /root/exam/nmap_scans/$ip/http_shellshock80.xml \
  -o /root/exam/nmap_scans/$ip/http_shellshock80_report.html
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
  printf "${RED}[+]${RESET} ${BLUE} Nmap MySQL NSE scan over port 3306 for $ip...${RESET}\n"
  printf "\n"
  nmap -sS -vv -p 1433,3306 --script=ms-sql-info,mysql-audit,mysql-databases,mysql-dump-hashes,mysql-empty-password,mysql-enum,mysql-info,mysql-query,mysql-users,mysql-variables,mysql-vuln-cve2012-2122 \
  -oX /root/exam/nmap_scans/$ip/mysql_nse.xml $ip && xsltproc /root/exam/nmap_scans/$ip/mysql_nse.xml \
  -o /root/exam/nmap_scans/$ip/mysql_nse_report.html
  sleep 5;

    printf "Now to output all NSE scans for $ip to firefox!\n"
    firefox /root/exam/nmap_scans/$ip/service_owners_report_$ip.html
    firefox /root/exam/nmap_scans/$ip/ftp_port21_report_$ip.html
    firefox /root/exam/nmap_scans/$ip/http_port80_report.html
    sleep 2;
    firefox /root/exam/nmap_scans/$ip/nfs_port111_report.html
    firefox /root/exam/nmap_scans/$ip/http_shellshock80_report.html
    firefox /root/exam/nmap_scans/$ip/smb_nse_report.html
    sleep 2;
    firefox /root/exam/nmap_scans/$ip/smb_nse_vuln_report.html
    firefox /root/exam/nmap_scans/$ip/snmp_nse_report.html
    firefox /root/exam/nmap_scans/$ip/mysql_nse_report.html
  
  next_host
done  

  printf "\n"
  printf "*************************************************"
  printf "  ${YELLOW}Now starting multi-tool scan!${RESET} "  
  printf "**************************************************"
  printf "\n"

# Run an Enum4linux, Onesixtyone, Gobuster, and Nikto Scan for all IP addresses in iplist.txt and output to txt file
# Are there other scripts I can run?

for ip in $(cat /root/exam/nmap_scans/iplist.txt); do
  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Enum4linux scan for $ip...${RESET}\n"
  printf "${RED}RID Cycling will not be run${RESET}\n"
  enum4linux -v -U -S -G -M -P -o -n $ip \
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
  printf "${RED}[+]${RESET} ${BLUE}Gobuster scripts $ip...${RESET}\n"
  printf "Starting gobuster script with common.txt wordlist against http://$ip/\n"
  gobuster -v -u http://$ip -w /root/wordlists/common.txt -s '200,204,301,302,307,403,500' -e \
  >> /root/exam/nmap_scans/$ip/gobuster-common_wordlist.txt
  printf "Completed!\n"
  printf "Remember to check any subdirectories ;)\n"
  sleep 5;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Nikto for $ip...${RESET}\n"
  nikto -h http://$ip -Format html -output /root/exam/nmap_scans/$ip/nikto_scan.html
  firefox /root/exam/nmap_scans/$ip/nikto_scan.html
  printf "Completed!\n"
  sleep 5;

  next_host
done

# Run a TCP and UDP Scan for all IP addresses on all ports in iplist.txt and output to firefox

  echo ""
  echo "                                **********************************************************"
  echo "                                |          Now starting detailed TCP scan !              |"  
  echo "                                |                  This may take a while...              |"
  echo "                                **********************************************************"
  echo ""

for ip in $(cat /root/exam/nmap_scans/iplist.txt); do
  mkdir -p /root/exam/nmap_scans/$ip/

  #might need to remove -A on all ports, 30 minutes per scan is just too long..

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Detailed TCP nmap scan for $ip...${RESET}\n"
  printf "\n"
  nmap -vv -sV -Pn --reason -p- -T3 -oX /root/exam/nmap_scans/$ip/detailed-scan.xml $ip && xsltproc /root/exam/nmap_scans/$ip/detailed-scan.xml \
  -o /root/exam/nmap_scans/$ip/detailed-scan-report.html
  firefox /root/exam/nmap_scans/$ip/detailed-scan-report.html
  sleep 5;

  next_host
done

printf "${RED}[+]${RESET} Scans completed\n"
printf "${RED}[+]${RESET} Make sure you run nmap -p (interesting_port/s) -A on newly discovered hosts\n"
printf "${RED}[+]${RESET} Results saved to /root/exam/nmap_scans/'IP_ADDRESS'\n"
printf "${RED}[+]${RESET} Now starting Burp Suite for Active Spidering/Web Applications\n"
burpsuite
printf "for more port information, follow: 0daySecurity Enumeration\n"
printf "Remember to fill out services enum excel spreadsheet\n"
exit

