#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use cdrom installation
cdrom
# Use text install
text
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=vda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8
# Shutdown when complete
halt

# Network information - static
network  --bootproto=static --ip=192.168.4.37 --netmask=255.255.255.0 --gateway=192.168.4.1 --nameserver=192.168.4.22 --device=$interface --ipv6=ignore --activate
network  --hostname="sat-test.gshome.lan"

# Root password
rootpw --iscrypted $6$mrnfsiubvMDMK8CV$CyouEe9J.wdAErICvJxDsWx1xWgTM0IPUf5/Gd1f6JVoiePVs0hMG9IJ7xjdyALoe50sLzbQB6am6vJVpSYoZ0

# System services
services --enabled="chronyd"

# System timezone
timezone America/New_York --isUtc

#Create my user account
user --groups=wheel --name=glenn-adm --password=$6$7kZGDpNzm6C50Qz0$uZUkbcqxtzJMCRMP1Lx8hTljQ.3rQwfpIT1trEkOlIG7HWT57YBgLzUTc61RMm1b71Dc5IMyI7K2IEM1rkGEr1 --iscrypted --gecos="Glenn H. Snead"

# System bootloader configuration - 100 GB primary partition, erase existing partitions
clearpart --all --initlabel
bootloader --location=mbr --boot-drive=vda
#autopart --type=lvm
# Partition clearing information
part /boot --fstype="xfs" --ondisk=vda --size=1024
part pv.123 --fstype="lvmpv" --ondisk=vda --size=4096 --grow
volgroup vg01 pv.123 
logvol swap  --fstype="swap" --size=2048 --name=swap --vgname=vg01
logvol /var  --fstype="xfs" --size=10000 --name=var --vgname=vg01
logvol /var/log/audit  --fstype="xfs" --size=10000 --name=var_log_audit --vgname=vg01
logvol /var/log  --fstype="xfs" --size=5000 --name=var_log --vgname=vg01
logvol /var/tmp  --fstype="xfs" --size=5000 --name=var_tmp --vgname=vg01
logvol /  --fstype="xfs" --size=1024 --name=root --vgname=vg01
logvol /tmp  --fstype="xfs" --size=5000 --name=tmp --vgname=vg01 --fsoptions=defaults,noexec
logvol /home  --fstype="xfs" --size=5000 --name=home --vgname=vg01
logvol /usr  --fstype="xfs" --size=10000 --name=usr --vgname=vg01
logvol /opt  --fstype="xfs" --size=10000 --name=opt --vgname=vg01

# System bootloader configuration - auto file system layout
bootloader --location=mbr --boot-drive=vda
autopart --type=lvm

%packages
@^minimal
@core
aide
bash-completion
chrony
curl
libselinux-python
libsemanage-python
mailx
openscap
openscap-utils
openscap-scanner
tmux
vim
wget
zsh

%end

%addon com_redhat_kdump --disable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=50 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=50 --notstrict --nochanges --notempty
pwpolicy luks --minlen=6 --minquality=50 --notstrict --nochanges --notempty
%end

%pre
ip addr | grep -i broadcast | awk '{ print $2 }' > /tmp/interface
sed -i 's/:/\ /g' /tmp/interface
interface=`cat /tmp/interface`
%end

%post --log=/root/post-ks.log
#Set up sudoers - remove the NOPASSWD wheel group entry, allow password-based wheel group privilege escalation
sed -i -e '/## Same thing without a password/d' /etc/sudoers
sed -i -e '/#.*%wheel.*ALL=(ALL).*NOPASSWD:.*ALL/d' /etc/sudoers
sed -i -e 's/#.*%wheel.*ALL=(ALL).*ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

echo "Adding public key to glenn account..."
mkdir -p /home/glenn/.ssh
chmod 0600 /glenn/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4NrngJDRJBXh56QNztLs+xZ5rZ+mU9P+qcSj+iAZLna3qbFWhd+YeMphgUrek+ooo7614aaapgM4Ihu5lw/LV18eStV8Ota/mjbsJ5w9/rNIaZeHKASm4lR5KNARTvSpY+5dOhS/ADdunvEjJ7jrO34VV5iCXjRZt8CdramN1m5cggDBOjATaMmuPcu38Ek7ehZ+cMzTv7SFddP0fDmM4CtIpqGRJmTrAf7gFPrGEuHqQQiXIFrKquPvshvo+1LrTHygwSKBlQSpKND+3Esqpmv2tEDw6jJtivqHEXwpaJxBNvOtMMl4kXIlwlRrXZAp6Au5/jXFmh5rVYHwRpT5l5fBOARnFxTtq6e7KdaGQSIMPhHCoUEN89tjOK/Hj4Y23PmnwSGGahLU6jl9JIGvDAiKiGXiaivGA0WLVfsU+GxlhcM+z3rCOTg2GiBn5v6fna+EHry7V2wH4KcW9qs5WRPBT4DGjyYltrBces20kLmwirbzxa10h9oDKEiwFuQ6nEOz0JTasZkdKzZf6f5/IA/muX0DwiDRRULq4HzMZHYMUqGyj423kVwdC/a44h+nUFMvAzBTGN9uHY1m5ZbbODkKxAx/Zxl9vq1ukZCjiLFTlg50/8IGKxpz9PCDUJV8cdQ5sEqL3v5sTl+qGKBrx2TiFU3WrPhnZqEdxbSIMnw== glenn@ansible" >> /home/glenn/.ssh/authorized_keys
chown -R glenn:glenn /home/glenn/.ssh
chmod 0600 /home/glenn/.ssh/authorized_keys

%end
