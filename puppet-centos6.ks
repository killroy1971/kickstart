#Installs a generic CentOS 6 Puppet Client server
#You'll have to modify the "post" items for your environment.
#Installs git, puppet, factor, wget and sets the puppet client to boot with the OS.

install
text
cdrom
lang en_US.UTF-8
keyboard us
timezone --utc America/Chicago

#Network
network --onboot yes --device eth0 --bootproto dhcp --noipv6 --hostname vagrant-centos-6.vagrantup.com

#Services
firewall --disabled
authconfig --enableshadow --passalgo=sha512
selinux --disabled

#Clear existing partitions
zerombr
clearpart --all

# Disk Partitioning
part /boot --fstype=ext4 --size=200
part pv.1 --grow --size=1
volgroup vg01 --pesize=4096 pv.1
logvol / --fstype=ext4 --name=lv001 --vgname=vg01 --size=6000
logvol /var --fstype=ext4 --name=lv002 --vgname=vg01 --grow --size=1
logvol swap --name=lv003 --vgname=vg01 --size=2048
bootloader --location=mbr --append="crashkernel=auto rhgb quiet"
# END of Disk Partitioning

# Reboot when complete
reboot

# Package Selection
%packages --nobase
@core
wget
sudo
perl
git


%pre

%post --log=/root/install-post.log
(
PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PATH

sed -i -e 's/#%wheel.*ALL=(ALL).*ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm

yum -y install puppet factor 

echo "<ip_addr> puppt.<domain-name>  puppet" >> /etc/hosts
checkconfig puppet on

