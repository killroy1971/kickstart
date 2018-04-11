#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use cdrom installation
cdrom
# Use text install
text
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=sda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=static --ip=192.168.4.20 --netmask=255.255.255.0 --gateway=192.168.4.1 --nameserver=192.168.4.10,208.67.222.222 --device=eth0 --ipv6=ignore --activate
network  --hostname=bastion.gshome.lan

# Root password
rootpw --iscrypted $6$mrnfsiubvMDMK8CV$CyouEe9J.wdAErICvJxDsWx1xWgTM0IPUf5/Gd1f6JVoiePVs0hMG9IJ7xjdyALoe50sLzbQB6am6vJVpSYoZ0

# System services
services --enabled="chronyd"

# System timezone
timezone America/New_York --isUtc

#Create my user account
user --groups=wheel --name=glenn --password=$6$7kZGDpNzm6C50Qz0$uZUkbcqxtzJMCRMP1Lx8hTljQ.3rQwfpIT1trEkOlIG7HWT57YBgLzUTc61RMm1b71Dc5IMyI7K2IEM1rkGEr1 --iscrypted --gecos="Glenn H. Snead"

# System bootloader configuration
clearpart --all --initlabel
bootloader --location=mbr --boot-drive=sda
#autopart --type=lvm
# Partition clearing information
part /boot --fstype="xfs" --ondisk=sda --size=500
part pv.123 --fstype="lvmpv" --ondisk=sda --size=4096 --grow
volgroup vg01 pv.123 
logvol swap  --fstype="swap" --size=2048 --name=swap --vgname=vg01
logvol /var  --fstype="xfs" --size=10000 --name=var --vgname=vg01
logvol /var/log/audit  --fstype="xfs" --size=5000 --name=log_audit --vgname=vg01
logvol /var/log  --fstype="xfs" --size=5000 --name=log --vgname=vg01
logvol /  --fstype="xfs" --size=1024 --name=root --vgname=vg01
logvol /tmp  --fstype="xfs" --size=2048 --name=tmp --vgname=vg01 --fsoptions=defaults,noexec
logvol /home  --fstype="xfs" --size=5000 --name=home --vgname=vg01
logvol /usr  --fstype="xfs" --size=5000 --name=usr --vgname=vg01
logvol /opt  --fstype="xfs" --size=5000 --name=opt --vgname=vg01

%packages
@^minimal
@core
aide
chrony
curl
mailx
wget
libselinux-python
vim
bash-completion
zsh

%end

%addon com_redhat_kdump --disable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=50 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=50 --notstrict --nochanges --notempty
pwpolicy luks --minlen=6 --minquality=50 --notstrict --nochanges --notempty
%end
