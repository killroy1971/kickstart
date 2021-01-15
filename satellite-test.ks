#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
cdrom
# Use graphical install
graphical
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=vda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=static --device=eth0 --gateway=192.168.4.1 --ip=192.168.4.30 --nameserver=192.168.4.22 --netmask=255.255.255.0 --noipv6 --activate
network  --hostname=satellite-test.gshome.lan

repo --name="Server-HighAvailability" --baseurl=file:///run/install/repo/addons/HighAvailability
repo --name="Server-ResilientStorage" --baseurl=file:///run/install/repo/addons/ResilientStorage
# Root password
rootpw --iscrypted $6$2pG.KQT/gnEi.M0A$XpedUMc3WYVj8kAVppaAaeTOoW1opDy5MArp.gSuAo7oqbGoJHOIzrxi0DrXNYmLsiFKlo/awwxkBHl3eAaFc.
# System services
services --enabled="chronyd"
# System timezone
timezone America/New_York --isUtc
user --groups=wheel --name=glenn --password=$6$PJkmV/pc8.B7uHU9$lPpu8ex6QqhISuNIc7Ze1W.wyHVXmnt5L8PmaZlaf435ei8R.jJr9kq0Wx3AdwGbVZsGXVU.o5.WkaA6MDDDL. --iscrypted --gecos="Glenn H. Snead"
# System bootloader configuration
bootloader --location=mbr --boot-drive=vda
# Partition clearing information
clearpart --all --initlabel --drives=vda
# Disk partitioning information
part /boot --fstype="xfs" --ondisk=vda --size=1907
part pv.572 --fstype="lvmpv" --ondisk=vda --size=100492
volgroup vg01 --pesize=4096 pv.572
logvol /var/tmp  --fstype="xfs" --size=4768 --name=var_tmp --vgname=vg01
logvol /tmp  --fstype="xfs" --size=4768 --name=tmp --vgname=vg01
logvol /  --fstype="xfs" --size=953 --name=root --vgname=vg01
logvol /usr  --fstype="xfs" --size=9536 --name=usr --vgname=vg01
logvol swap  --fstype="swap" --size=15258 --name=swap --vgname=vg01
logvol /var  --fstype="xfs" --size=9536 --name=var --vgname=vg01
logvol /opt  --fstype="xfs" --size=9536 --name=opt --vgname=vg01
logvol /var/log  --fstype="xfs" --size=9536 --name=var_log --vgname=vg01
logvol /var/log/audit  --fstype="xfs" --size=4768 --name=var_log_audit --vgname=vg01
logvol /home  --fstype="xfs" --size=4768 --name=home --vgname=vg01

%packages
@^minimal
@core
chrony

%end

%addon com_redhat_kdump --disable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end
