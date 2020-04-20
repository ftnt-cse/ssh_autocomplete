#!/bin/bash
# (Works on macOS, Unix/Linux would need some modifications)
# Say you have all your lab IPs and names in a CSV, where each line looks like : 10.3.1.2,active,webserver_r_21
# You can use the below script to automatically read the list of hosts with their IP addresses and add it to /etc/hosts while configuring autocomplete to use this (/etc/hosts) list of hosts for ssh, sftp..

[ ! -f "$1" ] && echo "ip,name file required" && exit

source_file="$1"

TMPFILE="/tmp/host_list.txt"
#HOSTSFILE="/etc/hosts"
HOSTSFILE="/etc/hosts"

# check ip, takes IP as input and returns true or false
function check_ip(){
if [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  return 0
else
  return -1
fi
}

# takes csv file with ip/names as input
function format_entries(){
	while read line
	do
		t_name=$(echo "$line" | cut -d"," -f1)
		t_ip=$(echo "$line" | cut -d"," -f3)

		[ -z "$t_name" ] || [ -z "$t_ip" ] && continue

		name=$(echo $t_name | tr -s '[:blank:]' '_' | tr -s -c '[:alnum:]\r\n' '_' )
		ip=$(echo $t_ip | awk '{$1=$1};1' )

		if check_ip "$ip"
		then
			echo "$ip,$name" >> $TMPFILE
		fi

	done < $1
	res=$(cat $TMPFILE | sort | uniq)

	echo "$res" > $TMPFILE

}

# takes the formatted ip name files and update /etc/hosts
function update_hosts(){
while read line
	do
		ip=$(echo "$line" | cut -d"," -f1)		
		name=$(echo "$line" | cut -d"," -f2)

		if ! grep "$ip" $HOSTSFILE
		then
			echo "$ip $name" >> $HOSTSFILE
		fi

done < $1
}

# set autocomplete
_cook_ssh_autocomplete() 
{
	current_user=$(last | egrep "console.*still\s+logged\s+in"|awk '{print $1}')
	BASH_PROFILE="/Users/$current_user/.bash_profile"
 	if ! grep "complete -o default -o nospace" $BASH_PROFILE
 	then
 	host_list=$(egrep "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]" /etc/hosts | awk '{print $2}')	
 	echo "complete -o default -o nospace -W \"$host_list\" scp sftp ssh">> $BASH_PROFILE
 	fi
 	cat $BASH_PROFILE

}

#### Main
 
format_entries $source_file

update_hosts $TMPFILE

_cook_ssh_autocomplete
