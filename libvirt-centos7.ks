#version=RHEL7
#Kickstart script for use with libvirt/KVM systems.

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
network  --hostname=centos7-kvm.gshome.lan

# Root password
rootpw --iscrypted $6$HAVEpMUe.LJdMf38$OGc82aGA/rOUNP0RSFiBAu4tuC.rX5jSsvQVD74jbWeAyBuenh3FHy1RBKChCZAaThsaV0i4OljVMWiny7/.Z0

# User account
user --groups=wheel --name=glenn --password=$6$W09Bf9vw4tieKyW4$a2CFH/0gHxJ49VKuU9AnyaO7AWMX.eOxSWlbUTFHDtCeAecrLcn4LAV3h8SuzgPZiTF5EmPaeZihSQxs/1AuT0 --iscrypted --gecos="Glenn H. Snead"

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
/usr/bin/yum -y install opencryptoki crypto-utils screen openscap openscap-utils openscap-scanner mailx vim-enhanced rsync wget git bzip2 yum-utils qemu-guest-agent

#Configure sudoers file
sed -i -e 's/^Defaults.*requiretty/#Defaults   requiretty/g' /etc/sudoers
sed -i -e '/## Same thing without a password/d' /etc/sudoers
sed -i -e '/#.*%wheel.*ALL=(ALL).*NOPASSWD:.*ALL/d' /etc/sudoers

#Update all installed packages -- better to do this now rather than later
yum -y update

#Remove existing SSH host keys
/bin/rm -f /etc/ssh/*key*

%end
