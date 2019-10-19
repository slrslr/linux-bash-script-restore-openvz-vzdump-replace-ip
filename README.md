Couple of Linux bash scripts that can help:

A) migrate all OpenVZ VPSs from one physical openvz server to another physical openvz server

B) restore one openvz vzdump file and do some post restore task like replacing old ip by new ip, restarting apache

C) restore multiple openvz vzdump files and do post restore tasks..

# **New and updated scripts (2019) (these more automate OVZ6 VPS migration and makes it more convenient):**

**vzdump_all_vps2_fix** and **vzdumprestoreandipfixing_noprompt_onlyfixing**
These two scripts will work together to backup, transfer (keeping source VPS running and inviting to stop it once remote vps is restored and running), restore, re-IP the openvz6 VPSs and guide admin thru the process.

First script place to the /root/ of the source OpenVZ6 server and second to the /root/ of the destination, target OpenVZ6 server (both servers should have openvz, vzdump installed and SSH password-less access to each other + have available IPs that will be assigned to a VPSs during the scripts runtime).

Admin launch first script **script vzdump_all_vps2_fix on source server** and it will do following for each openvz6 VPS that is not explicitly excluded in the script:
1. create online (nearly no downtimes) vzdump/backup file
2. transfer the dump to destination server
3. restore the VPS on remote server
4. start VPS on remote server
5. ask to delete remote dump file
6. ask which new IP should be assigned to a VPS
7. script vzdump_all_vps2_fix will now launch script **vzdumprestoreandipfixing_noprompt_onlyfixing** located in destination node server /root/ and this script will:
- delete old IP and add new defined IP in VPS VZ config file
- replace old IPs found inside VPS files (hosts, dns zone of various control panels like zpanel,kloxo,vestacp) by new IP
- add /var/log/httpd folder, restart named and httpd (vzdump may skipped log dir.)
- script will report old ip, new ip vzlist to the e-mail
8. once remote script in previous step finish, source server script will continue and ping restored remote VPS and invite admin to import it into hypervm control panel(if admin want - HyperVM/Import RAW VPS function) and replace IPs in billing system if admin is using it.
9. prompt to disable source node server OVZ VPS as it was copied and restored on destination node server already
10. prompt to continue to next VPS/CT

**Before executing scripts:**
- edit remoteserverip variable in first script and check line that contains "870|1120|4770|1810|1820|2680|2730|4320|4420|1122|86000|112000" and replace by the openvz CTs that you want to exclude from the transfer process, and or delete all CT IDs to work with all VPSs.
- both servers should have SSH password less access, openvz 6 running, vzdump, vzrestore, rsync, sed, awk utilities, enough disk space for vzdump/s and VPS data.

Do everything on your risk, but it should work.
