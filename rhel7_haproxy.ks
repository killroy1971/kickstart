#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use cdrom installation
cdrom
# Use text install
text
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=sda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8
# Shutdown when complete
halt

# Network information
network  --bootproto=static --ip=192.168.4.18 --netmask=255.255.255.0 --gateway=192.168.4.1 --nameserver=192.168.4.1,208.67.222.222 --device=eth0 --ipv6=ignore --activate
network  --hostname=haproxy.gshome.lan

# Root password
rootpw --iscrypted $6$mrnfsiubvMDMK8CV$CyouEe9J.wdAErICvJxDsWx1xWgTM0IPUf5/Gd1f6JVoiePVs0hMG9IJ7xjdyALoe50sLzbQB6am6vJVpSYoZ0

# System services
services --enabled="chronyd"

# System timezone
timezone America/New_York --isUtc

#Create my user account
user --groups=wheel --name=glenn --password=$6$7kZGDpNzm6C50Qz0$uZUkbcqxtzJMCRMP1Lx8hTljQ.3rQwfpIT1trEkOlIG7HWT57YBgLzUTc61RMm1b71Dc5IMyI7K2IEM1rkGEr1 --iscrypted --gecos="Glenn H. Snead"

# System bootloader configuration
clearpart --all --initlabel
bootloader --location=mbr --boot-drive=sda
#autopart --type=lvm
# Partition clearing information
part /boot --fstype="xfs" --ondisk=sda --size=500
part pv.123 --fstype="lvmpv" --ondisk=sda --size=4096 --grow
volgroup vg01 pv.123 
logvol swap  --fstype="swap" --size=2048 --name=swap --vgname=vg01
logvol /var  --fstype="xfs" --size=10000 --name=var --vgname=vg01
logvol /var/log/audit  --fstype="xfs" --size=5000 --name=var_log_audit --vgname=vg01
logvol /var/log  --fstype="xfs" --size=5000 --name=var_log --vgname=vg01
logvol /  --fstype="xfs" --size=1024 --name=root --vgname=vg01
logvol /tmp  --fstype="xfs" --size=2048 --name=tmp --vgname=vg01 --fsoptions=defaults,noexec
logvol /home  --fstype="xfs" --size=5000 --name=home --vgname=vg01
logvol /usr  --fstype="xfs" --size=5000 --name=usr --vgname=vg01
logvol /opt  --fstype="xfs" --size=5000 --name=opt --vgname=vg01

%packages
@^minimal
@core
aide
chrony
curl
mailx
wget
libselinux-python
libsemanage-python
vim
bash-completion
zsh
openscap
openscap-utils
openscap-scanner

%end

%addon com_redhat_kdump --disable --reserve-mb='auto'

%end

%post --log=/root/ks-post.log
echo "Adding public key to root account..."
mkdir -p /root/.ssh
chmod 0600 /root/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4NrngJDRJBXh56QNztLs+xZ5rZ+mU9P+qcSj+iAZLna3qbFWhd+YeMphgUrek+ooo7614aaapgM4Ihu5lw/LV18eStV8Ota/mjbsJ5w9/rNIaZeHKASm4lR5KNARTvSpY+5dOhS/ADdunvEjJ7jrO34VV5iCXjRZt8CdramN1m5cggDBOjATaMmuPcu38Ek7ehZ+cMzTv7SFddP0fDmM4CtIpqGRJmTrAf7gFPrGEuHqQQiXIFrKquPvshvo+1LrTHygwSKBlQSpKND+3Esqpmv2tEDw6jJtivqHEXwpaJxBNvOtMMl4kXIlwlRrXZAp6Au5/jXFmh5rVYHwRpT5l5fBOARnFxTtq6e7KdaGQSIMPhHCoUEN89tjOK/Hj4Y23PmnwSGGahLU6jl9JIGvDAiKiGXiaivGA0WLVfsU+GxlhcM+z3rCOTg2GiBn5v6fna+EHry7V2wH4KcW9qs5WRPBT4DGjyYltrBces20kLmwirbzxa10h9oDKEiwFuQ6nEOz0JTasZkdKzZf6f5/IA/muX0DwiDRRULq4HzMZHYMUqGyj423kVwdC/a44h+nUFMvAzBTGN9uHY1m5ZbbODkKxAx/Zxl9vq1ukZCjiLFTlg50/8IGKxpz9PCDUJV8cdQ5sEqL3v5sTl+qGKBrx2TiFU3WrPhnZqEdxbSIMnw== glenn@ansible" >> /root/.ssh/authorized_keys
chown -R root:root /root/.ssh
chmod 0600 /root/.ssh/authorized_keys

echo "Adding public key to glenn account..."
mkdir -p /glenn/.ssh
chmod 0600 /glenn/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4NrngJDRJBXh56QNztLs+xZ5rZ+mU9P+qcSj+iAZLna3qbFWhd+YeMphgUrek+ooo7614aaapgM4Ihu5lw/LV18eStV8Ota/mjbsJ5w9/rNIaZeHKASm4lR5KNARTvSpY+5dOhS/ADdunvEjJ7jrO34VV5iCXjRZt8CdramN1m5cggDBOjATaMmuPcu38Ek7ehZ+cMzTv7SFddP0fDmM4CtIpqGRJmTrAf7gFPrGEuHqQQiXIFrKquPvshvo+1LrTHygwSKBlQSpKND+3Esqpmv2tEDw6jJtivqHEXwpaJxBNvOtMMl4kXIlwlRrXZAp6Au5/jXFmh5rVYHwRpT5l5fBOARnFxTtq6e7KdaGQSIMPhHCoUEN89tjOK/Hj4Y23PmnwSGGahLU6jl9JIGvDAiKiGXiaivGA0WLVfsU+GxlhcM+z3rCOTg2GiBn5v6fna+EHry7V2wH4KcW9qs5WRPBT4DGjyYltrBces20kLmwirbzxa10h9oDKEiwFuQ6nEOz0JTasZkdKzZf6f5/IA/muX0DwiDRRULq4HzMZHYMUqGyj423kVwdC/a44h+nUFMvAzBTGN9uHY1m5ZbbODkKxAx/Zxl9vq1ukZCjiLFTlg50/8IGKxpz9PCDUJV8cdQ5sEqL3v5sTl+qGKBrx2TiFU3WrPhnZqEdxbSIMnw== glenn@ansible" >> /glenn/.ssh/authorized_keys
chown -R glenn:glenn /glenn/.ssh
chmod 0600 /glenn/.ssh/authorized_keys

%end

%anaconda
pwpolicy root --minlen=6 --minquality=50 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=50 --notstrict --nochanges --notempty
pwpolicy luks --minlen=6 --minquality=50 --notstrict --nochanges --notempty
%end
