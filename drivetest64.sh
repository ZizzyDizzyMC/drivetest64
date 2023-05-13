#!/bin/bash
# Install common tools
echo "You are running ZizzyDizzyMC's Drive Testing Script"
echo "You will need a drives.txt that contains drive letters like sda sdb etc, one on each line."
echo "The contexts from lsblk will suffice, be sure to only put the drives you want to obliterate into drives.txt"
apt install cryptsetup-bin iotop -y

# Setup crypts on all disks form drives.txt.

echo "Setting up crypt volumes, these appear in /dev/mapper under crypt-drivename such as crypt-sda"
for i in $(cat drives.txt | awk '{print $1}'); do yes "" | cryptsetup open --type plain --cipher aes-xts-plain64 /dev/$i crypt-$i; done

# Build the script for shedding and comparing drives.  This lets us have a screen that runs both commands for one log file per disk.

echo 'Building a script that gets ran next. Do not remove shred-compare.sh until the drive testing is done.'
echo '#!/bin/bash' >> shred-compare.sh
echo 'shred -v -n 0 -z /dev/mapper/crypt-${1} && cmp -b /dev/zero /dev/mapper/crypt-${1}' >> shred-compare.sh
echo 'echo "done"' >> shred-compare.sh
chmod +x shred-compare.sh

# Post the finish script using base64 decode then gunzip straight into a file.
# I never learned how to just build a bash file that contained apostrophes in commands.

echo "H4sIAAAAAAAAA2WOQU7DMBBF9z7FJ41Uumgj1iBWbDiGa0+wReyxZuyUCLh7GzW7bt//enq7p+Ec
83C2GszIgoiY0T87W+ElzqSn+lPxB3v5xv63SMwV/cv//vAKz3CylKpUW4GbWOkOjn1c10yGXGB0
HzRRjfkLGoT80XEqVuikoTOSHqCZFIOneUi2FJLN8TnC5gU8YuEmWxvWhxUEElr5zcVt8qCsbSNC
iWdCDZTQdI14aH7LNtF7Z661g6XECwEAAA==" | base64 -d | gunzip > finish.sh
chmod +x finish.sh


# Run the shred-compare script

echo "Log files with format test-drivename.log will appear with data inside for verbose shred output and any errors of the compare program."

for i in $(cat drives.txt | awk '{print $1}'); do screen -L -Logfile test-$i.log -d -m -S test-$i bash shred-compare.sh $i; done

echo "When drive testing is done, as in screen -ls shows no running test sessions, please run the finish.sh script. This may take several hours to days depending on factors such as disk speed, size and connection type."




