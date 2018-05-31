# Use this kickstart file to create a 20 GB Centos 7 oVirt template.
install
text
network --bootproto=dhcp --hostname=rhel7base --ipv6=auto --activate
cdrom
lang en_US.UTF-8
keyboard us
zerombr
clearpart --all --initlabel
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=vda
timezone America/New_York
auth --enableshadow --passalgo=sha512
rootpw --iscrypted $6$Arp4rFaCunNUbDtq$wi6KJnwzcWfIOJRC0YI34H99.ZcwPHk3vvBNSWXTYPWvG1eNan84hlrQ0Ga1Mn1s1UJ3UoVAlwmqGkq/6cozp.
user --groups=wheel --name=glenn --password=$6$W09Bf9vw4tieKyW4$a2CFH/0gHxJ49VKuU9AnyaO7AWMX.eOxSWlbUTFHDtCeAecrLcn4LAV3h8SuzgPZiTF5EmPaeZihSQxs/1AuT0 --iscrypted --gecos="Glenn H. Snead"
selinux --enforcing
reboot
firewall --enabled
skipx
firstboot --enable
services --enabled="chronyd"
clearpart --all --initlabel
bootloader --location=mbr --boot-drive=vda
part /boot --fstype="xfs" --ondisk=vda --size=500
part pv.17 --fstype="lvmpv" --ondisk=vda --size=4096 --grow
volgroup vg01 --pesize=20480 pv.17
logvol swap  --fstype="swap" --size=2000 --name=swap --vgname=vg01
logvol /var/log/audit  --fstype="xfs" --size=1024 --name=var_log_audit --vgname=vg01
logvol /var/log  --fstype="xfs" --size=1024 --name=var_log --vgname=vg01
logvol /home  --fstype="xfs" --size=1024 --name=home --vgname=vg01
logvol /var  --fstype="xfs" --size=4000 --name=var --vgname=vg01
logvol /  --fstype="xfs" --size=1024 --name=root --vgname=vg01
logvol /usr  --fstype="xfs" --size=4000 --name=usr --vgname=vg01
logvol /opt  --fstype="xfs" --size=2000 --name=opt --vgname=vg01
logvol /tmp  --fstype="xfs" --size=4000 --name=tmp --vgname=vg01 --fsoptions=defaults,noexec

%packages
@base
@compat-libraries
@core
aide
curl
chrony
screen
tmux
openscap
openscap-utils
openscap-scanner
ntp
libselinux-python
libsemanage-python
firewalld
vim
git
curl
mailx
audispd-plugins
python
wget
parted
opencryptoki
vim
bash-completion
zsh
%end

%addon com_redhat_kdump --disable --reserve-mb='auto'

%end

%post
systemctl enable ovirt-guest-agent.service 
yum clean all
%end
