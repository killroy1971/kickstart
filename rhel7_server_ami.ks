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
# Shutdown when complete
halt

# Network information
network  --bootproto=dhcp --device=${interface} --noipv6 --activate

# Root password
#rootpw --iscrypted $6$mrnfsiubvMDMK8CV$CyouEe9J.wdAErICvJxDsWx1xWgTM0IPUf5/Gd1f6JVoiePVs0hMG9IJ7xjdyALoe50sLzbQB6am6vJVpSYoZ0

# Create ec2-user account
user --groups=wheel,ad,systemd-journal --name=ec2-user --gecos="Cloud User"

# System services
services --enabled="chronyd"

# System timezone
timezone America/New_York --isUtc

# System bootloader configuration
clearpart --all --initlabel
bootloader --location=mbr --boot-drive=sda
#autopart --type=lvm
# Partition clearing information
part /boot --fstype="xfs" --ondisk=sda --size=500 --fsoptions=defaults,noexec,nosuid,nodev
part pv.123 --fstype="lvmpv" --ondisk=sda --size=4096 --grow
volgroup vg01 pv.123 
logvol swap  --fstype="swap" --size=2048 --name=swap --vgname=vg01
logvol /  --fstype="xfs" --size=1024 --name=root --vgname=vg01
logvol /usr  --fstype="xfs" --size=5000 --name=usr --vgname=vg01 --fsoptions=defaults,nodev
logvol /opt  --fstype="xfs" --size=5000 --name=opt --vgname=vg01 --fsoptions=defaults,nodev
logvol /home  --fstype="xfs" --size=5000 --name=home --vgname=vg01 --fsoptions=defaults,nosuid,nodev
logvol /tmp  --fstype="xfs" --size=2048 --name=tmp --vgname=vg01 --fsoptions=defaults,nosuid,nodev
logvol /var  --fstype="xfs" --size=10000 --name=var --vgname=vg01 --fsoptions=defaults,noexec,nosuid,nodev
logvol /var/log/audit  --fstype="xfs" --size=5000 --name=var_log_audit --vgname=vg01 --fsoptions=defaults,noexec,nosuid,nodev
logvol /var/log  --fstype="xfs" --size=5000 --name=var_log --vgname=vg01 --fsoptions=defaults,noexec,nosuid,nodev

%packages
@^minimal
@core
aide
chrony
curl
mailx
wget
libselinux-python
libsemanage-python
python-gobject
NetworkManager-glib
NetworkManager
screen
tmux
vim
bash-completion
zsh
yum-utils
openscap
openscap-utils
openscap-scanner
bind-utils

%end

%addon com_redhat_kdump --disable --reserve-mb='auto'

%end

%pre 
ip addr | grep -i broadcast | awk '{ print $2 }' > /tmp/interface
sed -i 's/:/\ /g' /tmp/interface
interface=`cat /tmp/interface`
%end

%post --log=/root/ks-post.log

echo "Set up ec2-user elevated privileges..."
cat "ec2-user        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

%end

%anaconda
pwpolicy root --minlen=6 --minquality=50 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=50 --notstrict --nochanges --notempty
pwpolicy luks --minlen=6 --minquality=50 --notstrict --nochanges --notempty
%end
