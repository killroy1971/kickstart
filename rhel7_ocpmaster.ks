#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use network installation
url --url="http://192.168.4.10/os/rhel7"
repo --name="Server-HighAvailability" --baseurl=http://192.168.4.10/os/rhel7/addons/HighAvailability
repo --name="Server-ResilientStorage" --baseurl=http://192.168.4.10/os/rhel7/addons/ResilientStorage
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
network  --bootproto=dhcp --device=eth0 --ipv6=auto --activate
network  --hostname=opcmasterbase.gshome.lan

# Root password
rootpw --iscrypted $6$mrnfsiubvMDMK8CV$CyouEe9J.wdAErICvJxDsWx1xWgTM0IPUf5/Gd1f6JVoiePVs0hMG9IJ7xjdyALoe50sLzbQB6am6vJVpSYoZ0
# System services
services --enabled="chronyd"
# System timezone
timezone America/New_York --isUtc
user --groups=wheel --name=glenn --password=$6$7kZGDpNzm6C50Qz0$uZUkbcqxtzJMCRMP1Lx8hTljQ.3rQwfpIT1trEkOlIG7HWT57YBgLzUTc61RMm1b71Dc5IMyI7K2IEM1rkGEr1 --iscrypted --gecos="Glenn H. Snead"
# System bootloader configuration
bootloader --location=mbr --boot-drive=sda
autopart --type=lvm
# Partition clearing information
clearpart --none --initlabel

%packages
@^minimal
@core
chrony

%end

%addon com_redhat_kdump --disable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=50 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=50 --notstrict --nochanges --notempty
pwpolicy luks --minlen=6 --minquality=50 --notstrict --nochanges --notempty
%end
