#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use network installation
url --url="http://192.168.4.10/centos7"
# Use graphical install
graphical
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=sda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=static --device=enp0s31f6 --gateway=192.168.4.1 --ip=192.168.4.15 --nameserver=8.8.8.8,192.168.4.9 --netmask=255.255.255.0 --noipv6 --activate
network  --bootproto=dhcp --device=enp1s0 --onboot=off --ipv6=auto
network  --hostname=ovirt.gshome.lan

# Root password
rootpw --iscrypted $6$inA/u9U63Z70z5/j$GCf7T/.SVElIjfnVbWqiZY.UJb3BoFEm2beyTHJey0lKDg14ITjg/1xjhRhemOgmA4WeCXLg2rx41VlmYUu5J.
# System services
services --enabled="chronyd"
# System timezone
timezone America/New_York --isUtc
user --groups=wheel --name=glenn --password=$6$hSuMFfwAgBW3A7dZ$2v8Kj7PQxpfiqi7pimxg0orJAs13VYYiL848XabRNlYLvT1X5/CJh3Stu/djXFPs6nWjw6X4I5wy7knjRGMdv/ --iscrypted --gecos="Glenn H. Snead"
# System bootloader configuration
bootloader --location=mbr --boot-drive=sda
# Partition clearing information
clearpart --none --initlabel
# Disk partitioning information
part /boot --fstype="xfs" --onpart=sda2
part pv.19 --fstype="lvmpv" --noformat --onpart=sda3
part /boot/efi --fstype="efi" --onpart=sda1 --fsoptions="umask=0077,shortname=winnt"
volgroup vg01 --noformat --useexisting
logvol /home  --fstype="xfs" --noformat --useexisting --name=home --vgname=vg01
logvol /  --fstype="xfs" --useexisting --name=root --vgname=vg01
logvol swap  --fstype="swap" --useexisting --name=swap --vgname=vg01

%packages
@^minimal
@core
chrony

%end

%addon com_redhat_kdump --disable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=50 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=50 --notstrict --nochanges --notempty
pwpolicy luks --minlen=6 --minquality=50 --notstrict --nochanges --notempty
%end
