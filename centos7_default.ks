#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
cdrom
# Use graphical install
text
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=sda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=enp0s3 --noipv6 --activate
network  --bootproto=dhcp --device=enp0s8 --noipv6
network  --bootproto=dhcp --device=enp0s9 --noipv6
network  --hostname=test.gshome.lan

# Root password
rootpw --iscrypted $6$1E1duxUqWacRX96e$ZbmhQVUtKyqlPlVC7NT25xP/eStZN.IfUYGhidjSzPIbx.F6MKOZf2xEZzp9sDMLpibDEdGQOqvT1KwZDiXIu.
#Create my account
user --groups=wheel --name=glenn --password=$6$hSuMFfwAgBW3A7dZ$2v8Kj7PQxpfiqi7pimxg0orJAs13VYYiL848XabRNlYLvT1X5/CJh3Stu/djXFPs6nWjw6X4I5wy7knjRGMdv/ --iscrypted --gecos="Glenn H. Snead"
# System timezone
timezone America/New_York --isUtc
# System bootloader configuration
bootloader --location=mbr --boot-drive=sda
autopart --type=lvm
# Partition clearing information
clearpart --none --initlabel

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
