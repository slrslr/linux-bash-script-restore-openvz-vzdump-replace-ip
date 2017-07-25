echo -e "---------------------------------------------\n
This script migrates all VMs to another server (live mode) and can keep old server VMs running. Result log for each VM is sent to email provided.
Script should run in SCREEN mode!!

Command used to backup one VM: vzmigrate -v --remove-area no --live --readonly --keep-dst --ssh="-p 22" destinationnodeip 110
---------------------------------------------------"
echo "This script requires mutt package in order to send you logfile via e-mail. Trying to install it now:"
echo -e "If mutt is not installed successfully, i would quit now, or you would have to tail migration_all.log file which is updated after each CT migration is complete (log will be in same dir as this script)\n"

yum --quiet install mutt
rm -f migration_all.log
echo ""
vzlist -a
echo -e "\nType container IDs (CTID) which should be excluded from migration. Separate using space. (Example: 860 1120 1130):"
read excludects

echo ""
echo "IP of the destination server:"
read ip

echo "SSH port of the destination server:"
read port

ls /etc/vz/conf
echo "Path to vm config files: (def. is /etc/vz/conf (listed above), hit enter to confirm or type path - no trailing slash!! correct format: /some/directory)"
read cpath
if [ "$cpath" == "" ];then
cpath=/etc/vz/conf
fi

echo "E-mail where report will be sent:"
read email

echo "That is ALL, migration can take many hours, you should run it in screen mode. You will receive an email after each VM migration finish. Hit any key to start."
read start

for CT in $(vzlist -H -o veid); do
if [[ "$(echo \"$excludects\")" == *"$CT"* ]];then
echo "$CT is in exclude list, continue to next one"
continue
fi
vzmigrate -v --remove-area no --live --readonly --keep-dst --ssh="-p $port" $ip $CT | tee migration.log
mv $cpath/$CT.conf.migrated $cpath/$CT.conf | tee -a migration.log
echo "Migration for $CT VM should be complete.. check following log. and new HyperVM server vzlist. Then run script vzdumprestore (https://github.com/slrslr/linux-bash-script-restore-openvz-vzdump-replace-ip) which contains VM IP changing & fixing routines.

$(cat migration.log)" | mutt -s "VM Migration logs" $email
cat migration.log >> migration_all.log
echo " " >> migration_all.log
done
rm -f migration.log
echo "All finished. Check e-mail or migration_all.log in this dir. Any key to open the log now:"
read lfkgkggi
vi migration_all.log
#
