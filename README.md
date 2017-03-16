# linux-bash-script-restore-openvz-vzdump-replace-ip

This script can help:
- restore vzdump file
- delete old VM ip and replace by new one set by user
- replace old ips in hosts, dns zone files
- add /var/log/httpd folder, restart named and httpd
- script will report old ip, new ip and vzlist before change to the email $mail

This is amateur script, but i ran it without issue and it worked to fix issues i faced when i was restoring old vzdump files on new openvz host server with different set of IPs.

Some VPS's Apache's was stopped, some issues because of old VPS IP, so this script may help in that.
