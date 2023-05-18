# drivetest64
Testing Hard drives without Badblocks

To use this on debian based systems like proxmox:

Copy the output of lsblk that interests you, paste it into a file drives.txt
Run the script.  NOTE: This will destroy all data on disks that you put in drives.txt.
If this completes successfully every file with test-sdX.log will show an EOF and a done without any errors.
Once all drives are finished, run finish.sh to remove the drives from their mappers and you may use your disks again.


Q/A:

Will this destroy data?
Yes.

I accidently ran it on a drive I didn't want to...
Well crap.  The mapper basically writes garbage to the disk.  You might be able to run photorec and recover some stuff.

This broke my X:
This software is provided as is, and while I've tested it on several machines running Proxmox your milage may vary.  Feel free to submit pull requests for any helpful changes or additions to the software.

How does this work?
This works by adding every drive in drives.txt to a mapper through cryptsetup on AES, one of the fastest plain crypt algos without a passphrase.
Once the mapper is in place a shred command is done to write all 0's to the disk through the mapper.  The mapper randomizes the data though AES to the disk.
Once shred is done, the mapper is full of 0's but the disk is full of random encrypted 0s.
Compare is used to compare /dev/zero to the mapper - and if successful the whole drive should be read till end of file, no errors.
If the drive messes up anything the reading through the mapper will return a 1, thus ending the compare run and failing the disk.
The speeds obtained are far faster than badblocks, however if bulk testing drives the AES crypto might be a limitation on older hardware.
Xeon E5-2690v4's tend to top at 1200MB/s meaning 12 disks run at 100MB/s each.  However 1 disk runs at 280MBs (WD 18TB's used as a test.)
Newer hardware performs much better, with another test systemm a ryzen topping near 3000MBs in cryptsetup benchmark.



If you like this software, consider giving me a thanks or a recommendation.  Happy testing!
