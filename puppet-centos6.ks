install
url --url http://monolith/netboot/centos6/
lang en_US.UTF-8
keyboard us
timezone --utc America/New_York
network --noipv6 --onboot=yes --bootproto dhcp
authconfig --enableshadow --enablemd5
rootpw --iscrypted $6$wXOkwHHkI0aiJJro$mSzq4.uCS4iOhxHvkK5nK6zQ0ll2CCYSErE.vV1WKGFPU8e04L2C/KkV6pk4vJVGaNJgGHrmPy/J2n/DyQgBC1
firewall --enabled --port 22:tcp
selinux --permissive
bootloader --location=mbr --driveorder=sda --append="crashkernel=auth rhgb"

# Disk Partitioning
zerombr
clearpart --all --initlabel --drives=sda
part /boot --fstype=ext4 --size=200
part pv.1 --grow --size=1
volgroup vg01 --pesize=4096 pv.1

logvol / --fstype=ext4 --name=lv001 --vgname=vg01 --size=6000
logvol /var --fstype=ext4 --name=lv002 --vgname=vg01 --grow --size=1
logvol swap --name=lv003 --vgname=vg01 --size=2048
# END of Disk Partitioning

# Make sure we reboot into the new system when we are finished
reboot

# Repositories
repo --name=CentOS-Base --baseurl=http://monolith/repo/centos6/
repo --name=EPEL --baseurl=http://monolith/repo/epel-repo/
repo --name=PuppetLabs-Products --baseurl=http://monolith/repo/puppetlabs-products/
repo --name=PuppetLabs-Products --baseurl=http://monolith/repo/puppetlabs-deps/

# Package Selection
%packages --nobase --excludedocs
@core
-*firmware
-iscsi*
-fcoe*
-b43-openfwwf
kernel-firmware
-efibootmgr
wget
sudo
perl
git
puppet
facter


%pre

%post --log=/root/install-post.log
(
PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PATH

# PLACE YOUR POST DIRECTIVES HERE
) 2>&1 >/root/install-post-sh.log

