#version=RHEL7
# Kickstart file to create a RHEL7 vagrant box target
# System authorization information
auth --enableshadow --passalgo=sha512

# Installation Source
url --url http://192.168.4.14/pub/os/rhel7.4/

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
network  --bootproto=dhcp --device=$interface --ipv6=auto --activate
network  --hostname=vagrant.vagrantup.com

# Root password
rootpw --iscrypted $6$Arp4rFaCunNUbDtq$wi6KJnwzcWfIOJRC0YI34H99.ZcwPHk3vvBNSWXTYPWvG1eNan84hlrQ0Ga1Mn1s1UJ3UoVAlwmqGkq/6cozp.

# System timezone
timezone America/New_York --isUtc
user --name=vagrant --gecos="vagrant" 

# Partition clearing information
clearpart --all --initlabel 

# System bootloader configuration
# autopart --type=lvm
bootloader --location=mbr --boot-drive=sda
part /boot --fstype="xfs" --ondisk=sda --size=512
part pv.17 --fstype="lvmpv" --ondisk=sda --size=1 --grow
volgroup vg01 pv.17  
logvol swap --fstype="swap" --name=swap --vgname=vg01 --size=512
logvol / --fstype="xfs" --name=root --vgname=vg01 --size=1024 --grow

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
#Register with RHN
/usr/sbin/subscription-manager register --username=rhn-gps-gsnead --password=t%3KtjRJ@r2%FAm!3sXP1*
/usr/sbin/subscription-manager attach --pool=8a85f98c60c2c2b40160c324e5d21d70

#Install additional packages
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
/usr/bin/yum -y installgroup compat-libraries
/usr/bin/yum -y install opencryptoki crypto-utils screen openscap openscap-utils openscap-scanner mailx vim-enhanced rsync wget git bzip2 yum-utils dkms kexec-tools nfs-utils 
/usr/bin/yum -y install libsemanage-python libselinux-python bash-completion tmux kernel-devel

#Set up sudoers for vagrant and remove the NOPASSWD wheel entry
#A security tradeoff I know, but ncessary for vagrant boxes.
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

#Update all installed packages -- not doing so tends to break VirtualBox Guest Additions Install
yum -y update

# Unregister from RHN
yum clean all
/usr/sbin/subscription-manager unregister

#Remove existing ssh host keys
/bin/rm -f /etc/ssh/*key*

#Remove existing udev rules
rm -Rf /etc/udev/rules.d/70-*

# Update primary network interface configuration file
ip addr | grep -i broadcast | awk '{ print $2 }' > /tmp/interface
sed -i 's/:/\ /g' /tmp/interface
interface=`cat /tmp/interface`
sed -i -e 's/^HWADDR.*//g' /etc/sysconfig/network-scripts/ifcfg-${interface}
sed -i -e 's/^UUID.*//g' /etc/sysconfig/network-scripts/ifcfg-${interface}

%end
