## ssh_autocomplete
Usually when you have a large number of machines to manage via ssh, sftp...it becomes tedius to remember exactly each machine name/ip, so you rely on a spreadsheet somewhere where you have them all listed.
This quick script takes that (csv) spreadsheet (assuming ip is @column 1 and name is @column 3) parses all none empty names:
-	Makes sure it doesn’t have any special character
-	Replaces spaces with underscore
-	Check IPs are valid ipv4 and strip them from any spaces
Once the list of valid ip, name pairs is created it create an /etc/hosts entry for each none existent
Once /etc/hosts populated it takes the list of names and configure it for ssh, sftp autocompletion.

### run the script:
__sudo ./script_name__
The script will determine your MacOS home folder and adds ssh autocomplete to your .bash_profile
Should be fairly easy to adapt for Linux/Unix boxes.

