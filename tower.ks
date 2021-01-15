#version=RHEL8
# Use text install
graphical

%packages
@^server-product-environment
initial-setup
kexec-tools

%end

# Keyboard layouts
keyboard --xlayouts='us'
# System language
lang en_US.UTF-8

# Accept EULA
eula --agreed

# Network information
network  --bootproto=static --device=$interface --gateway=192.168.4.1 --ip=192.168.4.28 --nameserver=192.168.4.22 --netmask=255.255.255.0 --noipv6 --activate
network  --hostname=tower.gshome.lan

# Use HTTP installation media
url --url=http://192.168.4.24/pub/os/rhel8

# Run the Setup Agent on first boot
firstboot --enable

ignoredisk --only-use=vda
# Partition clearing information
clearpart --none --initlabel
# Disk partitioning information
part /boot --fstype="xfs" --ondisk=vda --size=1907 --fsoptions="defaults,noexec,nosuid,nodev"
part pv.491 --fstype="lvmpv" --ondisk=vda --size=4096 --grow
volgroup vg01 --pesize=4096 pv.491
logvol /var/log --fstype="xfs" --size=9536 --name=var_log --vgname=vg01 --fsoptions="defaults,noexec,nosuid,nodev"
logvol /opt --fstype="xfs" --size=9536 --name=opt --vgname=vg01 --fsoptions="defaults,nodev"
logvol /var/log/audit --fstype="xfs" --size=4768 --name=var_log_audit --vgname=vg01 --fsoptions="defaults,noexec,nosuid,nodev"
logvol /tmp --fstype="xfs" --size=4768 --name=tmp --vgname=vg01 --fsoptions="defaults,nosuid,nodev"
logvol swap --fstype="swap" --size=4096 --name=swap --vgname=vg01
logvol /var --fstype="xfs" --size=9536 --name=var --vgname=vg01 --fsoptions="defaults,noexec,nosuid,nodev"
logvol /home --fstype="xfs" --size=4768 --name=home --vgname=vg01 --fsoptions="defaults,noexec,nosuid,nodev"
logvol /var/tmp --fstype="xfs" --size=4768 --name=var_tmp --vgname=vg01 --fsoptions="defaults,nosuid,nodev"
logvol /usr --fstype="xfs" --size=9536 --name=usr --vgname=vg01 --fsoptions="defaults,nodev"
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

