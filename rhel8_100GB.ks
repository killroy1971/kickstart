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
network  --bootproto=static --device=enp1s0 --gateway=192.168.4.1 --ip=192.168.4.24 --nameserver=192.168.4.22 --netmask=255.255.255.0 --noipv6 --activate
network  --hostname=service.gshome.lan

# Use CDROM installation media
cdrom

# Run the Setup Agent on first boot
firstboot --enable

ignoredisk --only-use=vda
# Partition clearing information
clearpart --none --initlabel
# Disk partitioning information
part /boot --fstype="xfs" --ondisk=vda --size=1907
part pv.491 --fstype="lvmpv" --ondisk=vda --size=100492
volgroup vg01 --pesize=4096 pv.491
logvol /var/log --fstype="xfs" --size=9536 --name=var_log --vgname=vg01
logvol /opt --fstype="xfs" --size=4768 --name=opt --vgname=vg01
logvol /var/log/audit --fstype="xfs" --size=4768 --name=var_log_audit --vgname=vg01
logvol /tmp --fstype="xfs" --size=4768 --name=tmp --vgname=vg01
logvol swap --fstype="swap" --size=3814 --name=swap --vgname=vg01
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
