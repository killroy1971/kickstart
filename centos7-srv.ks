#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512

# Use network installation
#url --url="http://192.168.4.10/pub/os/centos7"

# Use cdrom
cdrom

# Use graphical install
text

# Run the Setup Agent on first boot
firstboot --enable


# Run the Setup Agent on first boot
firstboot --enable

ignoredisk --only-use=sda

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'

# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=$interface --onboot=on --ipv6=auto

# System services
services --enabled="chronyd"

# Root password
rootpw --iscrypted $6$inA/u9U63Z70z5/j$GCf7T/.SVElIjfnVbWqiZY.UJb3BoFEm2beyTHJey0lKDg14ITjg/1xjhRhemOgmA4WeCXLg2rx41VlmYUu5J.


# System services
services --enabled="chronyd"
# System timezone
timezone America/New_York --isUtc

# Create my user account
user --groups=wheel --name=glenn --password=$6$hSuMFfwAgBW3A7dZ$2v8Kj7PQxpfiqi7pimxg0orJAs13VYYiL848XabRNlYLvT1X5/CJh3Stu/djXFPs6nWjw6X4I5wy7knjRGMdv/ --iscrypted --gecos="Glenn H. Snead"

# System timezone
timezone America/New_York --isUtc

#Create my account
user --groups=wheel --name=glenn --password=$6$hSuMFfwAgBW3A7dZ$2v8Kj7PQxpfiqi7pimxg0orJAs13VYYiL848XabRNlYLvT1X5/CJh3Stu/djXFPs6nWjw6X4I5wy7knjRGMdv/ --iscrypted --gecos="Glenn H. Snead"

# Partition clearing information
clearpart --all --initlabel

# System bootloader configuration
bootloader --location=mbr --boot-drive=sda

# Disk partitioning information
part /boot/efi --fstype="efi" --onpart=sda --fsoptions="umask=0077,shortname=winnt" --size=200
part /boot --fstype="xfs" --onpart=sda --size=512
part pv.19 --fstype="lvmpv" --noformat --onpart=sda

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

%end

%addon com_redhat_kdump --disable --reserve-mb='auto'

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

#Remove existing SSH host keys
/bin/rm -f "/etc/ssh/*key*"

%end

%anaconda
pwpolicy root --minlen=6 --minquality=50 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=50 --notstrict --nochanges --notempty
pwpolicy luks --minlen=6 --minquality=50 --notstrict --nochanges --notempty
%end

