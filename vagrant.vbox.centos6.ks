#Kickstart script to create a CentOS6 vagrant box target
install

#System authorization settings
authconfig --enableshadow --passalgo=sha512

#Installation Source
url --url=http://192.168.4.10/centos6

#Text based install
text

#Set default parameters
lang en_US.UTF-8
keyboard us
timezone --utc America/New_York

#Configure Network and set hostname
network --onboot yes --device eth0 --bootproto dhcp --noipv6 --hostname vagrant-centos-6.vagrantup.com

#User Accounts
rootpw  --iscrypted $6$Arp4rFaCunNUbDtq$wi6KJnwzcWfIOJRC0YI34H99.ZcwPHk3vvBNSWXTYPWvG1eNan84hlrQ0Ga1Mn1s1UJ3UoVAlwmqGkq/6cozp.
user --name=vagrant --gecos="vagrant"

#Services - disable iptables and selinux
firewall --disabled
selinux --disabled

#Clear existing partitions
zerombr
clearpart --all

#Partition Information
bootloader --location=mbr --append="crashkernel=auto rhgb quiet"
part /boot --fstype=ext4 --size=512
part pv.01 --grow --size=1
volgroup vg01 pv.01
logvol swap --name=lv_swap --vgname=vg01 --size=512
logvol / --fstype=ext4 --name=lv_root --vgname=vg01 --grow --size=1

#Reboot after completion
reboot

%packages --nobase
@core

%end

%post --nochroot

%end

%post --log=/root/ks-post.log
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
/usr/bin/yum -y groupinstall compat-libraries
/usr/bin/yum -y install opencryptoki crypto-utils screen openscap openscap-utils openscap-scanner mailx vim-enhanced rsync wget git bzip2 yum-utils dkms kexec-tools nfs-utils

#Set up sudoers for vagrant and remove the NOPASSWD wheel entry
#A security tradeoff I know, but ncessary for vagrant boxes.
sed -i -e '/## Same thing without a password/d' /etc/sudoers
sed -i -e '/#.*%wheel.*ALL=(ALL).*NOPASSWD:.*ALL/d' /etc/sudoers
sed -i -e 's/#.*%wheel.*ALL=(ALL).*ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers
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

#Update all installed packages -- not doing so tends to break VirtualBox Guest Additions Install
/usr/bin/yum -y update

#Remove existing SSH Host keys
/bin/rm -f /etc/ssh/*key*

#Remove existing udev network rules
/bin/rm -f /etc/udev/rules.d/70-persistent-net.rules

%end
