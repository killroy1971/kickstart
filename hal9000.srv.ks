#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
cdrom
# Use graphical install
graphical
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=sdb
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=enp0s31f6 --ipv6=auto --no-activate
network  --bootproto=static --device=enp1s0 --gateway=192.168.4.1 --ip=192.168.4.10 --nameserver=8.8.8.8 --netmask=255.255.255.0 --ipv6=auto --activate
network  --hostname=hal9000.gshome.lan
# Root password
rootpw --iscrypted $6$wIRmvj5rhAaIrrpB$.DgbzvLKGqBDOUYqI4YoFgXjEbyul8g.hQo3wcnPA6QlVKqDTpImFQ0vX/ua/9pZlqrehkKM9ZWlzvn9bdHjR/
# System services
services --enabled="chronyd"
# System timezone
timezone America/New_York --isUtc
user --groups=wheel --name=glenn --password=$6$OYdqIWh3IbCoBt05$I8YvjCea6ii8VsCpJMvyBxDw9Qx7QcvaExXK5NWHGB8D0qaNn0EtHNrY6dN5GnIT.nJ5CCjsiAwK0BjgXl6wl/ --iscrypted --gecos="Glenn H. Snead"
# System bootloader configuration
bootloader --location=mbr --boot-drive=sdb
# Partition clearing information
clearpart --none --initlabel
# Disk partitioning information
part /boot/efi --fstype="efi" --ondisk=sdb --size=256 --fsoptions="umask=0077,shortname=winnt"
part /boot --fstype="ext4" --ondisk=sdb --size=500
part pv.569 --fstype="lvmpv" --ondisk=sdb --size=243441
volgroup vg01 --pesize=4096 pv.569
logvol swap  --fstype="swap" --size=2048 --name=swap --vgname=vg01
logvol /tmp  --fstype="xfs" --size=10240 --name=tmp --vgname=vg01
logvol /home  --fstype="xfs" --size=10240 --name=home --vgname=vg01
logvol /usr  --fstype="xfs" --size=20480 --name=usr --vgname=vg01
logvol /  --fstype="xfs" --size=1024 --name=root --vgname=vg01
logvol /var/log  --fstype="xfs" --size=10240 --name=var_log --vgname=vg01
logvol /var  --fstype="xfs" --size=10240 --name=var --vgname=vg01
logvol /opt  --fstype="xfs" --size=20480 --name=opt --vgname=vg01

%packages
@^server-product-environment
@ansible-node
chrony

%end

%addon com_redhat_kdump --disable --reserve-mb='128'

%end

%anaconda
pwpolicy root --minlen=0 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy user --minlen=0 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=0 --minquality=1 --notstrict --nochanges --emptyok
%end
