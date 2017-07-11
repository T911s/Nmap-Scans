#!/bin/bash

# requires the administrator smb credentials

printf "[+]Running smb-psexec NSE script\n"
printf "Enter IP: "
read ip

nmap -vv -d -p 139,445 --script=smb-psexec.nse --script-args=smbuser=msfadmin,smbpass=msfadmin,config=experimental $ip \
  -oX /root/exam/nmap_scans/$ip/smb_nse_psexec.xml && xsltproc /root/exam/nmap_scans/$ip/smb_nse_psexec.xml \
  -o /root/exam/nmap_scans/$ip/smb_nse_psexec_report.html

firefox /root/exam/nmap_scans/$ip/smb_nse_psexec_report.html
sleep 5;
printf "\n"
exit