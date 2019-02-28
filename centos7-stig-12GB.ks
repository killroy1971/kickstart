# Kickstart file to create a DISA STIG RHEL7 or CENTOS 7 machine.
# Use on barebones hardware that creates normal disk targets: /dev/sda.
# Use to create VMs where the hypervisor created normal disk targets: /dev/sda.
# This script does not create a user account.  Change your rootpw entry to match
# your personall default root password's hash.
# This kickstart creates a 12G vg01 volume group and consumes 12G of that space.
install
text
network --bootproto=dhcp --device=ens192 --hostname=rhel7base --ipv6=auto --activate
cdrom
lang en_US.UTF-8
keyboard us
zerombr
clearpart --all --initlabel
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=sda
timezone America/New_York
auth --enableshadow --passalgo=sha512
rootpw --iscrypted $5$RTMU6SuC/OfsFQZh$A0JkYSUJ9SRld.9JMUCiNIlnpt1vTLVxpTMKRPqGcB1
selinux --permissive
reboot
firewall --disabled
skipx
ignoredisk --only-use=sda
firstboot --enable
services --enabled="chronyd"
part /boot --fstype="xfs" --ondisk=sda --size=500
part pv.123 --fstype="lvmpv" --ondisk=sda --size=4096 --grow
volgroup vg01 --pesize=12288 pv.123
logvol swap  --fstype="swap" --size=500 --name=swap --vgname=vg01
logvol /  --fstype="xfs" --size=500 --name=root --vgname=vg01
logvol /usr  --fstype="xfs" --size=2048 --name=usr --vgname=vg01
logvol /opt  --fstype="xfs" --size=500 --name=opt --vgname=vg01
logvol /tmp  --fstype="xfs" --size=500 --name=tmp --vgname=vg01 --fsoptions=defaults,noexec,nosuid,nodev
logvol /var  --fstype="xfs" --size=4096 --name=var --vgname=vg01 --fsoptions=defaults,noexec,nosuid,nodev
logvol /var/log  --fstype="xfs" --size=1024 --name=var_log --vgname=vg01 --fsoptions=defaults,noexec,nosuid,nodev
logvol /var/log/audit  --fstype="xfs" --size=500 --name=var_log_audit --vgname=vg01 --fsoptions=defaults,noexec,nosuid,nodev
logvol /home  --fstype="xfs" --size=500 --name=home --vgname=vg01 --fsoptions=defaults,noexec,nosuid,nodev

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

