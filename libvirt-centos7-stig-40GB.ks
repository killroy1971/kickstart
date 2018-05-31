# Kickstart file to create a DISA STIG RHEL7 or CENTOS 7 machine.
# Use on barebones hardware that creates normal disk targets: /dev/vda.
# Use to create VMs where the hypervisor created normal disk targets: /dev/vda.
# This script does not create a user account.  Change your rootpw entry to match
# your personall default root password's hash.
# This kickstart creates a 12G vg01 volume group and consumes 40G of that space.

# System authorization information
auth --enableshadow --passalgo=sha512

install
cdrom
# Use network isntallation url
url --url="http://192.168.4.10/centos7"

#Use text mode install
text

#Set language and keyboard version
lang en_US.UTF-8
keyboard us
timezone America/New_York

#Root password
rootpw --iscrypted $6$Arp4rFaCunNUbDtq$wi6KJnwzcWfIOJRC0YI34H99.ZcwPHk3vvBNSWXTYPWvG1eNan84hlrQ0Ga1Mn1s1UJ3UoVAlwmqGkq/6cozp.

#centos user account
user --name=centos --gecos="centos"

#System settings
services --enabled="chronyd"

#Don't configure X Window System
skipx

# Enable firstboot
firstboot --enable

# Reboot after installation
reboot

#Network information
network --bootproto=dhcp --ipv6=auto --activate

# System bootloader configuration
zerombr
clearpart --all --initlabel
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=vda
ignoredisk --only-use=vda

# Disk partitioning information
part /boot --fstype="xfs" --ondisk=vda --size=256
part pv.235 --fstype="lvmpv" --ondisk=vda --size=4096 --grow
volgroup vg01 --pesize=39000 pv.235 
logvol swap  --fstype="swap" --size=1024 --name=swap --vgname=vg01
logvol /var  --fstype="xfs" --size=10000 --name=var --vgname=vg01
logvol /tmp  --fstype="xfs" --size=4096 --name=tmp --vgname=vg01
logvol /  --fstype="xfs" --size=500 --name=root --vgname=vg01
logvol /home  --fstype="xfs" --size=256 --name=home --vgname=vg01
logvol /var/log  --fstype="xfs" --size=1024 --name=var_log --vgname=vg01
logvol /opt  --fstype="xfs" --size=2096 --name=opt --vgname=vg01
logvol /var/log/audit  --fstype="xfs" --size=1024 --name=var_log_audit --vgname=vg01
logvol /usr  --fstype="xfs" --size=4096 --name=usr --vgname=vg01

%packages
@base
@core
@compat-libraries
crypto-utils
screen
tmux
openscap
openscap-utils
openscap-scanner
aide
opencryptoki
chrony
curl
mailx
wget
libselinux-python
libsemanage-python
vim
bash-completion
zsh

%end

%addon com_redhat_kdump --disable --reserve-mb='auto'

%end

%post --logfile /root/ks-post.log

# Install additional packages
# Add EPEL repository
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
/usr/bin/yum -y installgroup compat-libraries
/usr/bin/yum -y install opencryptoki crypto-utils screen openscap openscap-utils openscap-scanner mailx vim-enhanced rsync wget git bzip2 yum-utils qemu-guest-agent nfs-utils tmux aide curl python libselinux-python

#Configure sudoers file
sed -i -e 's/^Defaults.*requiretty/#Defaults   requiretty/g' /etc/sudoers
sed -i -e '/## Same thing without a password/d' /etc/sudoers
sed -i -e '/#.*%wheel.*ALL=(ALL).*NOPASSWD:.*ALL/d' /etc/sudoers

sed -i -e 's/#.*%wheel.*ALL=(ALL).*ALL/%wheel ALL=(ALL) ALL' /etc/sudoers
echo "%centos ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/centos
chown root:root /etc/sudoers.d/centos
chmod 0440 /etc/sudoers.d/centos

#Update all packages
yum -y update

#Remove existing SSH host keys
/bin/rm -f /etc/ssh/*key*

%end

%anaconda
pwpolicy root --minlen=6 --minquality=50 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=50 --notstrict --nochanges --notempty
pwpolicy luks --minlen=6 --minquality=50 --notstrict --nochanges --notempty
%end

