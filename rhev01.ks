#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
repo --name="Server-HighAvailability" --baseurl=file:///run/install/repo/addons/HighAvailability
repo --name="Server-ResilientStorage" --baseurl=file:///run/install/repo/addons/ResilientStorage
# Use CDROM installation media
cdrom
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
network  --bootproto=static --device=enp2s0 --gateway=192.168.4.1 --ip=192.168.4.12 --nameserver=208.67.222.222,192.168.4.1 --netmask=255.255.255.0 --noipv6 --activate
network  --bootproto=static --device=enp4s0 --gateway=192.168.5.1 --ip=192.168.5.12 --netmask=255.255.255.0 --noipv6 --activate
network  --hostname=rhev01.ghsome.lan

# Root password
rootpw --iscrypted $6$mgeABPlECVM1ba9n$9nLzbuynsCNYJ4CnnYDe.2VNQxNYqcyI0Va6cdejvEiMGdk82yyadJNLWnQiQJ0gw7PIsmTHiKO2eb/qK1Sn4.
# System services
services --enabled="chronyd"
# System timezone
timezone America/New_York --isUtc
user --groups=wheel --name=glenn --password=$6$kRCLFIPzVRT.F7gC$r9FixlZTFs2PYjUtWxWVsouoIrF3VNznXW6qkI1mislWYK2awcT7hDuhT/BBWzx/3m3r4EYdRV6DuUzb5IO47/ --iscrypted --gecos="Glenn H. Snead"
# System bootloader configuration
bootloader --location=mbr --boot-drive=sda
# Partition clearing information
clearpart --drives=sda --initlabel
# Disk partitioning information
part /boot/efi --fstype="efi" --onpart=sda1 --fsoptions="umask=0077,shortname=winnt"
part /boot --fstype="xfs" --onpart=sda2
part pv.25 --fstype="lvmpv" --noformat --onpart=sda3
volgroup vg01 --noformat --useexisting
logvol /var/log  --fstype="xfs" --useexisting --name=var_log --vgname=vg01
logvol /  --fstype="xfs" --useexisting --name=root --vgname=vg01
logvol /opt  --fstype="xfs" --useexisting --name=opt --vgname=vg01
logvol /var  --fstype="xfs" --useexisting --name=var --vgname=vg01
logvol /home  --fstype="xfs" --noformat --useexisting --name=home --vgname=vg01
logvol /tmp  --fstype="xfs" --useexisting --name=tmp --vgname=vg01
logvol /usr  --fstype="xfs" --useexisting --name=usr --vgname=vg01
logvol /var/log/audit  --fstype="xfs" --useexisting --name=var_log_audit --vgname=vg01
logvol swap  --fstype="swap" --useexisting --name=swap --vgname=vg01

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
