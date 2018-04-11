#version=RHEL7
#Kickstart script to create a libvirt compatible CentOS7 vbox target.

#Reboot at end
reboot

# System authorization information
auth --enableshadow --passalgo=sha512

#Installation Soruce
url --url http://192.168.4.10/centos7

# Use graphical install
text

# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=vda

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'

# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=$interface --ipv6=auto --activate
network  --hostname=vagrant.vagrantup.com

# Root password
rootpw --iscrypted $6$Arp4rFaCunNUbDtq$wi6KJnwzcWfIOJRC0YI34H99.ZcwPHk3vvBNSWXTYPWvG1eNan84hlrQ0Ga1Mn1s1UJ3UoVAlwmqGkq/6cozp.

# User account
user --name=vagrant --gecos="vagrant"

# System timezone
timezone America/New_York --isUtc

# Partition clearing information
clearpart --all --initlabel 

# System bootloader configuration
# autopart --type=lvm
bootloader --location=mbr --boot-drive=vda
part /boot --fstype="xfs" --ondisk=vda --size=512
part pv.17 --fstype="lvmpv" --ondisk=vda --size=1 --grow
volgroup vg01 pv.17
logvol swap --fstype="swap" --name=swap --vgname=vg01 --size=512
logvol / --fstype="xfs" --name=root --vgname=vg01 --size=1 --grow

%packages
@core

%end

%addon com_redhat_kdump --disable --reserve-mb='auto'

%end

%post --nochroot
%end

%pre
ip addr | grep -i broadcast | awk '{ print $2 }' > /tmp/interface
sed -i 's/:/\ /g' /tmp/interface
interface=`cat /tmp/interface`
%end

%post --log=/root/ks-post.log

#Install additional packages
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
/usr/bin/yum -y installgroup compat-libraries
/usr/bin/yum -y install opencryptoki crypto-utils screen openscap openscap-utils openscap-scanner mailx vim-enhanced rsync wget git bzip2 yum-utils qemu-guest-agent nfs-utils

#Configure sudoers file
sed -i -e 's/^Defaults.*requiretty/#Defaults   requiretty/g' /etc/sudoers
sed -i -e '/## Same thing without a password/d' /etc/sudoers
sed -i -e '/#.*%wheel.*ALL=(ALL).*NOPASSWD:.*ALL/d' /etc/sudoers

sed -i -e 's/#.*%wheel.*ALL=(ALL).*ALL/%wheel ALL=(ALL) ALL' /etc/sudoers
echo "%vagrant ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vagrant
chown root:root /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant

#Set vagrant account password
echo 'vagrant:$6$er2KeeQRorDzsAJw$I0eTtueHyqQRMm1DRkhc7Jscw5cZ7rFs/ZwrlaJ54kEyD8.P9oS5xOVg3wRDhUzkyBkPpCLlnOhKd3Mce6.aY/' | chpasswd -e

#Set up vagrant ssh keys
mkdir /home/vagrant/.ssh
chown vagrant:vagrant -R /home/vagrant/.ssh
chmod 0700 /home/vagrant/.ssh
curl -k https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub > /home/vagrant/.ssh/authorized_keys
chown vagrant:vagrant -R /home/vagrant/.ssh/*
chmod 0600 /home/vagrant/.ssh/authorized_keys

#Prevent ssh from using DNS
sed -i -e 's/#UseDNS.*yes/UseDNS no/g' /etc/ssh/sshd_config

#Update all packages
yum -y update

#Remove existing SSH host keys
/bin/rm -f /etc/ssh/*key*

%end
