echo "This script migrates all OpenVZ VMs/VPSs from one to another OVZ server (live mode) and can keep old server VMs running. Result log for each VM is sent to email provided.

If VPSs are running critical services, this migration can be issue because old server VPS will continue receiving traffic and new server VPSs may have outdated MySQL data as a result (if running some websites frequently visited).

Solution might be to edit this script, update \"--remove-area no\" to \"--remove-area yes\" but it may be little bit unsafe (what if vzdump file or migration failed somehow, you delete source file. Another way would be to add # sign before line starting \"mv\" in this script as that way old server VPS will stop responding its users probably.

Command used to backup one VM: vzmigrate -v --remove-area no --live --readonly --keep-dst --ssh="-p 22" destinationnodeip CTIDHERE
---------------------------------------------------"
echo "This script requires mutt package in order to send you logfile via e-mail. Trying to install it now:"
yum install mutt
echo "If mutt is not installed successfully, i would quit now, you may not find migration log."
echo ""
echo "IP of destination server:"
read ip
ls /etc/vz/conf
echo "Path to vm config files: (def. is /etc/vz/conf , hit enter to confirm or type path)"
read cpath
if [ "$cpath" == "" ];then
cpath=/etc/vz/conf
fi
echo "E-mail where report will be sent:"
read email
echo "That is ALL, migration can take many hours, you should run it in screen mode. You will receive an email after each VM migration finish. Hit any key to start."
read start
for CT in $(vzlist -H -o veid); do
vzmigrate -v --remove-area no --live --readonly --keep-dst --ssh="-p 22" $ip $CT | tee migration.log
# following line is to keep VPS running on old server
mv $cpath/$CT.conf.migrated $cpath/$CT.conf | tee -a migration.log
echo "Migration for $CT VM should be complete.. check following log. and new HyperVM server vzlist. Then run script vzdumprestore (https://github.com/slrslr/linux-bash-script-restore-openvz-vzdump-replace-ip) which contains VM IP changing & fixing routines.

$(cat migration.log)" | mutt -s "VM Migration logs" $email
done
rm -rf migration.log
