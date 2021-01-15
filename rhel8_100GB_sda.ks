#version=RHEL8
# Use graphical install
graphical

repo --name="AppStream" --baseurl=file:///run/install/sources/mount-0000-cdrom/AppStream

%packages
@^server-product-environment
kexec-tools

%end

# Keyboard layouts
keyboard --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=static --device=$interface --gateway=$GATEWAY --ip=$IPADDR --nameserver=$DNSSVR --netmask=255.255.255.0 --noipv6 --activate
network  --hostname=$SYSNAME

# Use CDROM installation media
cdrom

# Run the Setup Agent on first boot
firstboot --enable

ignoredisk --only-use=sda
# Partition clearing information
clearpart --none --initlabel
# Disk partitioning information
part /boot --fstype="xfs" --ondisk=sda --size=1907
part pv.491 --fstype="lvmpv" --ondisk=sda --size=4096 --grow
volgroup vg01 --pesize=4096 pv.491
logvol /var/log --fstype="xfs" --size=9536 --name=var_log --vgname=vg01
logvol /opt --fstype="xfs" --size=9536 --name=opt --vgname=vg01
logvol /var/log/audit --fstype="xfs" --size=4768 --name=var_log_audit --vgname=vg01
logvol /tmp --fstype="xfs" --size=4768 --name=tmp --vgname=vg01
logvol swap --fstype="swap" --size=4096 --name=swap --vgname=vg01
logvol /var --fstype="xfs" --size=9536 --name=var --vgname=vg01
logvol /home --fstype="xfs" --size=4768 --name=home --vgname=vg01
logvol /var/tmp --fstype="xfs" --size=4768 --name=var_tmp --vgname=vg01
logvol /usr --fstype="xfs" --size=9536 --name=usr --vgname=vg01
logvol / --fstype="xfs" --size=953 --name=root --vgname=vg01

# System timezone
timezone America/New_York --isUtc

# Root password
rootpw --iscrypted $6$5pBIP0JGTGL6URIm$Xh7Z3f10qg30DWYw8HnxoolHXuU5zpaVWA4b4mUI200TfeaJ1i8C8N.an04gJbHn2JylyEkwwlIq7G0rXChWJ.
user --groups=wheel --name=glenn --password=$6$V1pD4EcaIKcYDCKe$mmdwpl271ZhHuB7EG8wcCyd9f8GrPSowfui2fqoheb9AAWpOno8NfhadkaR9PEMLYrBMNZNlt8rEDz8qlgEdq. --iscrypted --gecos="Glenn H. Snead"

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

%pre
ip addr | grep -i broadcast | awk '{ print $2 }' > /tmp/interface
sed -i 's/:/\ /g' /tmp/interface
interface=`cat /tmp/interface`
#change to new vt and set stdout/stdin
exec < /dev/tty6 > /dev/tty6
chvt 6
#Prompt for hostname
read -p "Enter desired hostname:" SYSNAME /dev/tty6 2>&1
#Prompt for network address
read -p "Enter the system's ip address:" IPADDR /dev/tty6 2>&1
#Prompt for the network gateway
read -p "Enter the system's default gateway:" GATEWAY /dev/tty6 2>&1
#Prompt for the DNS server(s)
read -p "Enter the system's DNS servers in <ipaddr>,<ipaddr> format:" DNSSVR /dev/tty6 2>&1
%end

%post --log=/root/post-ks.log
#Clean up /etc/sudoers - remove the NOPASSWD wheel group entry, allow password-based wheel group privilege escalation
sed -i -e '/## Same thing without a password/d' /etc/sudoers
sed -i -e '/#.*%wheel.*ALL=(ALL).*NOPASSWD:.*ALL/d' /etc/sudoers
sed -i -e '/#.*%wheel.*ALL(ALL).*ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

echo "Adding public key to glenn user account..."
mkdir -p /home/glenn/.ssh
chmod 0600 /home/glenn/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4NrngJDRJBXh56QNztLs+xZ5rZ+mU9P+qcSj+iAZLna3qbFWhd+YeMphgUrek+ooo7614aaapgM4Ihu5lw/LV18eStV8Ota/mjbsJ5w9/rNIaZeHKASm4lR5KNARTvSpY+5dOhS/ADdunvEjJ7jrO34VV5iCXjRZt8CdramN1m5cggDBOjATaMmuPcu38Ek7ehZ+cMzTv7SFddP0fDmM4CtIpqGRJmTrAf7gFPrGEuHqQQiXIFrKquPvshvo+1LrTHygwSKBlQSpKND+3Esqpmv2tEDw6jJtivqHEXwpaJxBNvOtMMl4kXIlwlRrXZAp6Au5/jXFmh5rVYHwRpT5l5fBOARnFxTtq6e7KdaGQSIMPhHCoUEN89tjOK/Hj4Y23PmnwSGGahLU6jl9JIGvDAiKiGXiaivGA0WLVfsU+GxlhcM+z3rCOTg2GiBn5v6fna+EHry7V2wH4KcW9qs5WRPBT4DGjyYltrBces20kLmwirbzxa10h9oDKEiwFuQ6nEOz0JTasZkdKzZf6f5/IA/muX0DwiDRRULq4HzMZHYMUqGyj423kVwdC/a44h+nUFMvAzBTGN9uHY1m5ZbbODkKxAx/Zxl9vq1ukZCjiLFTlg50/8IGKxpz9PCDUJV8cdQ5sEqL3v5sTl+qGKBrx2TiFU3WrPhnZqEdxbSIMnw== glenn@ansible" > /home/glenn/.ssh/authorized_keys
chown -R glenn:glenn /home/glenn/.ssh
chmod 0600 /home/glenn/.ssh/authorized_keys

%end

