# SoftRAID Live Migration
Version 1.0.1 BETA
*Do not use this script, it will likely destroy your system*
This is an incomplete BASH script, it doesn't have a complete error checking system, and when you reboot, you are left with a mix of hope and blind faith. 


I needed to modify a server's disk configuration from 4 /dev/sd* to 2 RAIDs (/dev/md1 and /dev/md2) while the server was live, because I didn't have any physical access to the server, there was no option to use IPMI or a KVM.

The script is really specific to the system that I was running it on, however it may be helpful for someone who needs to create their own script to do a similar task. I am saving it for future reference.


## Using this Script:

Get the script: [migrate_to_raid.sh](https://raw.githubusercontent.com/adamvallee/server-admin/main/Debian%2012/SoftRAID%20Live%20Migration/migrate_to_raid.sh)

### Save the script to a file
For example, copy and paste the code into "migrate_to_raid.sh" using nano.

    nano migrate_to_raid.sh

Or you can download the script to your current working directory:

    wget https://raw.githubusercontent.com/adamvallee/server-admin/main/Debian%2012/SoftRAID%20Live%20Migration/migrate_to_raid.sh

### Make the script executable:
    chmod +x migrate_to_raid.sh

### Run the script:
    sudo ./migrate_to_raid.sh

Please review and test the script carefully in your environment before using it on a production system.

# README.md

## Migration to RAID Device Script

This script is designed to migrate the operating system from a single disk to a RAID 1 device on Debian 12. It performs several key tasks: detecting the current disk layout, migrating the OS, updating the boot loader, and documenting the process. Below is a detailed explanation of each step, including the who, what, when, why, and how of the script.

### Who
This script is intended for system administrators or users with root access who need to migrate their Debian 12 operating system from a single disk setup to a RAID 1 configuration.

### What
The script accomplishes the following:
1. Detects the current disk layout and verifies the RAID device.
2. Unmounts the RAID device if already mounted and formats it.
3. Migrates the operating system to the RAID device.
4. Updates the boot loader configuration to ensure the system can boot from the RAID device.
5. Documents each step in a Markdown log file.

### When
Run this script when you need to migrate an existing Debian 12 installation to a RAID 1 device for redundancy and improved data reliability.

### Why
Migrating to a RAID 1 setup provides data redundancy. If one disk fails, the system can continue to operate using the other disk, minimizing downtime and data loss.

### How
Below is a detailed explanation of each step in the script:

#### Step 1: Detect the Current Disk Layout
```bash
lsblk | tee -a $LOGFILE
