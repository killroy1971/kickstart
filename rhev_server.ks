#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512

# Use network installation
url --url="http://192.168.4.10/pub/os/rhel7.4"
repo --name="Server-HighAvailability" --baseurl=http://192.168.4.10/pub/os/rhel7.4/addons/HighAvailability
repo --name="Server-ResilientStorage" --baseurl=http://192.168.4.10/pub/os/rhel7.4/addons/ResilientStorage

# Use graphical install
graphical

# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=sda

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'

# System language
lang en_US.UTF-8

# Network information
network  --bootproto=static --device=enp2s0 --gateway=192.168.4.1 --ip=192.168.4.15 --nameserver=8.8.8.8,192.168.4.10 --netmask=255.255.255.0 --ipv6=auto --activate
network  --bootproto=dhcp --device=enp4s0 --onboot=off --ipv6=auto
network  --hostname=rhev.gshome.lan

# Root password
rootpw --iscrypted $6$4WlXWoWDC9Rp.HY8$ymyikwA1.KhDEgkJ052gOzhnAh/BUw8rQUvojjC/7vb28XAAdjVWgXHOGVvk0x7uC2lsEfO8BRdHPJxqWljtx0

# System services
services --enabled="chronyd"

# System timezone
timezone America/New_York --isUtc

user --groups=wheel --name=glenn --password=$6$IcueQHHP7.fvLR/e$3DG8NUDH.V9w3m9Q3gCNGlnCRvf37KJXiPDAm/tO3GRtjo37q2oUgAOFO9bIu0A5RqKFSMp5QFKU9X.spmHVk. --iscrypted --gecos="Glenn H. Snead"

# System bootloader configuration
bootloader --location=mbr --boot-drive=sda

# Partition clearing information
clearpart --none --initlabel

# Disk partitioning information
part pv.20 --fstype="lvmpv" --noformat --onpart=sda3
part /boot/efi --fstype="efi" --onpart=sda1 --fsoptions="umask=0077,shortname=winnt"
part /boot --fstype="xfs" --onpart=sda2
volgroup vg01 --noformat --useexisting
logvol /usr  --fstype="xfs" --size=51200 --name=usr --vgname=vg01
logvol /opt  --fstype="xfs" --size=10240 --name=opt --vgname=vg01
logvol /var/log  --fstype="xfs" --size=10240 --name=var_log --vgname=vg01
logvol /  --fstype="xfs" --size=1024 --useexisting --resize --name=root --vgname=vg01
logvol swap  --fstype="swap" --useexisting --name=swap --vgname=vg01
logvol /var  --fstype="xfs" --size=20480 --name=var --vgname=vg01
logvol /home  --fstype="xfs" --useexisting --name=home --vgname=vg01
logvol /tmp  --fstype="xfs" --size=10240 --name=tmp --vgname=vg01

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
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end
