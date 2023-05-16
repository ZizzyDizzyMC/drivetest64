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
echo '#!/bin/bash' > shred-compare.sh
echo 'shred -v -n 0 -z /dev/mapper/crypt-${1} && cmp -b /dev/zero /dev/mapper/crypt-${1}' > shred-compare.sh
echo 'echo "done"' > shred-compare.sh
chmod +x shred-compare.sh

# Define the content of the generated script
script_content="#!/bin/bash
for i in \$(cat drives.txt | awk '{print \$1}'); do
    cryptsetup close crypt-\$i
done
echo \"Deleting shred-compare.sh\"
rm shred-compare.sh
ls /dev/mapper
echo \"If any of your drives appear here you should ensure you remove them using cryptsetup close <name>\""

# Generate the script
echo "$script_content" > finish.sh
chmod +x finish.sh
echo "finish script generated successfully."


# Run the shred-compare script

echo "Log files with format test-drivename.log will appear with data inside for verbose shred output and any errors of the compare program."

for i in $(cat drives.txt | awk '{print $1}'); do screen -L -Logfile test-$i.log -d -m -S test-$i bash shred-compare.sh $i; done

echo "When drive testing is done, as in screen -ls shows no running test sessions, please run the finish.sh script. This may take several hours to days depending on factors such as disk speed, size and connection type."




