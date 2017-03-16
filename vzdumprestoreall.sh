mail=YOUR@EMAIL.HERE
clear
echo "This script can:
- restore all OpenVZ vzdump files
- delete old VM ip and replace by new one set by user
- replace old ips in hosts, dns zone files
- add /var/log/httpd folder, restart named and httpd
- script will report old ip, new ip and vzlist before change to the email $mail"
echo "
THIS SCRIPT SHOULD BE EXECUTED IN SCREEN SESSION!"
echo "
Now listing possible backup dirs in /"
ls | grep tgz
ls / | grep backup_
echo "What is directory with VZDUMPs (.tgz)? (probably /backup_OLDSERVIP/1) just enter directory where is vzdump files:"
read vzdumpdir
echo "ok, lets see if there are really that files (just first few files):"
ls -lh $vzdumpdir | head
ls -rA1 $vzdumpdir | grep -o '[0-9]*'
echo "list of vmids got from vzdump directory should be seen above. Hit any key to BEGIN VZDUMp RESTORE? all existing VMS can be replaced. An email will be sent to the $mail after all restored"
read continuex
for VMID in $(ls -rA1 $vzdumpdir | grep -o '[0-9]*');do
vzdump --restore $vzdumpdir/vzdump-$VMID.tgz $VMID;vzctl start $VMID;sleep 1
done
echo "vzdump --restore process should be complete. check vzlist -a or tail /var/log/vzdump/* . Now probably try to do hardrefresh in hypervm to see if all vpss recognized and then change IPs. One may do vzdumprestore script which contains routines to make httpd restart and replace old ips by new ips.." | mail -s "All VM vzdump restore completed at $(hostname)" $mail
echo "An email sent to $mail with details on what to do"

exit


echo "VM $VMID vzdump restore finished, now respond to the script questions in SSH terminal to continue."
listofvms="vzlist at $(hostname):

$(vzlist -o ctid,ip,hostname)"

stat /vz/root
echo "
What is the openvz root path? /vz/root or other? if dont know or not changed anything, hit Enter"
read vzroot
if [ "$vzroot" == "" ];then vzroot=/vz/root;fi


vzlist -o ctid,ip
echo "VMID old IP is: $(vzlist $VMID -o ip -H) is that right? If yes, hit Enter or paste it"
read OLDIP
if [ "$OLDIP" == "" ];then
OLDIP=$(vzlist $VMID -o ip -H)
fi
echo "VMID New IP: (add this one in new HyperVM now)"
read NEWIP

vzctl set $VMID --ipdel $OLDIP --save
vzctl set $VMID --ipadd $NEWIP --save
find $vzroot/$VMID/etc -type f -print0 | xargs -0 sed -i "s|$OLDIP|$NEWIP|g";
find $vzroot/$VMID/var/named -type f -print0 | xargs -0 sed -i "s|$OLDIP|$NEWIP|g";
find $vzroot/$VMID/var/named/chroot/var/named -type f -print0 | xargs -0 sed -i "s|$OLDIP|$NEWIP|g";
echo "cat $vzroot/$VMID/etc/hosts"
cat $vzroot/$VMID/etc/hosts
echo "cat $vzroot/$VMID/var/named/chroot/var/named/*"
cat $vzroot/$VMID/var/named/chroot/var/named/*
vzctl exec $VMID mkdir /var/log/httpd
vzctl exec $VMID mkdir /var/log/apache2
vzctl exec $VMID /etc/init.d/named restart
vzctl exec $VMID /etc/init.d/httpd restart
vzctl exec $VMID /etc/init.d/apache2 restart
echo "VM $VMID restore, ip change and fixing script finished. http://$NEWIP
Ask VM owner to change nameserver IPs in domain registar if host domain.
If anything dont works, errors can be old IP in /etc/hosts, /var/named/chroot/var/named or restart httpd, try /script/fixdns/fixweb

$listofvms" | mutt -s "VM restore script finished" $mail
echo "
This VM restore and IP change script finished. Ask VM owner to change nameserver IPs in domain registar if host domain.

First run these commands if above was outputted old ips in files:
find $vzroot/$VMID/etc -type f -print0 | xargs -0 sed -i 's|$OLDIP|$NEWIP|g';find $vzroot/$VMID/var/named -type f -print0 | xargs -0 sed -i 's|$OLDIP|$NEWIP|g';find $vzroot/$VMID/var/named/chroot/var/named -type f -print0 | xargs -0 sed -i 's|$OLDIP|$NEWIP|g';vzctl exec $VMID /etc/init.d/named restart;vzctl exec $VMID /etc/init.d/httpd restart;cat $vzroot/$VMID/etc/hosts;

Change IPs in WHMCS and send client email with new IP"
