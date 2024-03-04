#!/usr/bin/bash
# et0
# 23/02/2024

hostname="$(hostnamectl | grep Static | cut -d' ' -f4)"
echo "Machine name : ${hostname}"

name="$(source /etc/os-release && echo $NAME)"
version="$(source /etc/os-release && echo $VERSION)"
echo "OS ${name} and kernel version is ${version}"

ip="$(ip a | grep "inet " | sed -n 2p | tr -s ' ' | cut -d' ' -f3)"
echo "IP : ${ip}"

ram_total="$(free | grep Mem | tr -s ' ' | cut -d' ' -f2)"
ram_free="$(free | grep Mem | tr -s ' ' | cut -d' ' -f4)"
echo "RAM : ${ram_free} memory available on ${ram_total} total memory"

disk="$(df -h / | awk 'NR==2 {print $4}')"
echo "Disk : ${disk} space left"

process="$(ps aux --sort=-%mem | awk 'NR<=6 && NR>1 {print "  - " $11}')"
echo -e "Top 5 processes by RAM usage : \n${process}"

ports="$(ss -tuln | awk '/^tcp/ {print "  - " $4 " : " $6}' | sed 's/\(.*\):\(.*\)/\1 tcp : \2/' && ss -uln | awk '/^udp/ {print "  - " $4 " : " $5}' | sed 's/\(.*\):\(.*\)/\1 udp : \2/')"
echo -e "Listening ports : \n${ports}"

path="$(IFS=: read -ra path_dirs <<< "$PATH" && printf "  - %s\n" "${path_dirs[@]}")"
echo -e "PATH directories : \n${path}"

json_data=$(curl -s "https://api.thecatapi.com/v1/images/search")
url=$(echo "$json_data" | grep -o '"url": *"[^"]*"' | cut -d '"' -f 4)
echo -e "Here is your random cat (jpg file) :\n${url}"

