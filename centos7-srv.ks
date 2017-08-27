#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use network installation
url --url="http://192.168.4.10/pub/os/centos7"
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
network  --bootproto=dhcp --device=enp1s0 --onboot=on --ipv6=auto

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
clearpart --all --initlabel
# Disk partitioning information
part /boot/efi --fstype="efi" --onpart=sda1 --fsoptions="umask=0077,shortname=winnt"
part /boot --fstype="xfs" --onpart=sda2
part pv.19 --fstype="lvmpv" --noformat --onpart=sda3
volgroup vg01 pv.19
logvol /home --fstype="xfs" --name=home --vgname=vg01 --size=5000
logvol swap  --fstype="swap" --name=swap --vgname=vg01 --size=2048
logvol / --fstype="xfs" --name=root --vgname=vg01 --size=1024 --grow

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
