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
\`\`\`bash
lsblk | tee -a $LOGFILE
\`\`\`
- **What**: Lists all block devices and their mount points.
- **Why**: To document the current disk layout and identify the root device.

\`\`\`bash
ROOT_DEVICE=$(df / | tail -1 | awk '{print $1}')
\`\`\`
- **What**: Determines the current root device.
- **Why**: To identify the partition where the operating system is currently installed.

#### Step 2: Verify the RAID Device
\`\`\`bash
mdadm --detail $RAID_DEVICE | tee -a $LOGFILE
\`\`\`
- **What**: Provides detailed information about the RAID device.
- **Why**: To ensure the RAID device is correctly configured and operational.

#### Step 3: Unmount the RAID Device if Mounted
\`\`\`bash
if mountpoint -q /mnt/raid; then
    umount /mnt/raid
fi
\`\`\`
- **What**: Checks if the RAID device is mounted and unmounts it if necessary.
- **Why**: To avoid formatting a mounted filesystem, which could cause data loss or corruption.

#### Step 4: Migrate the OS to the RAID Device
\`\`\`bash
mkfs.ext4 $RAID_DEVICE
mkdir -p /mnt/raid
mount $RAID_DEVICE /mnt/raid
\`\`\`
- **What**: Formats the RAID device with the ext4 filesystem and mounts it.
- **Why**: Prepares the RAID device for data migration.

\`\`\`bash
rsync -aAXv / /mnt/raid --exclude={"/mnt/raid","/proc","/tmp","/dev","/sys","/run","/mnt"}
\`\`\`
- **What**: Copies the entire filesystem to the RAID device, excluding certain directories.
- **Why**: Migrates the operating system files to the RAID device.

#### Step 5: Update the Boot Loader Configuration
\`\`\`bash
UUID=$(blkid -s UUID -o value $RAID_DEVICE)
sed -i "s|$(blkid -s UUID -o value $ROOT_DEVICE)|$UUID|g" /mnt/raid/etc/fstab
sed -i "s|$(blkid -s UUID -o value $ROOT_DEVICE)|$UUID|g" /mnt/raid/boot/grub/grub.cfg
sed -i "s|$(blkid -s UUID -o value $ROOT_DEVICE)|$UUID|g" /mnt/raid/etc/default/grub
\`\`\`
- **What**: Updates UUID references in configuration files to point to the new RAID device.
- **Why**: Ensures the system references the correct device for the root filesystem and boot loader.

\`\`\`bash
mount --bind /dev /mnt/raid/dev
mount --bind /proc /mnt/raid/proc
mount --bind /sys /mnt/raid/sys
mount --bind /tmp /mnt/raid/tmp
\`\`\`
- **What**: Bind mounts necessary filesystems into the chroot environment.
- **Why**: Allows the chroot environment to function properly, mimicking the real root environment.

\`\`\`bash
mount $EFI_PARTITION /mnt/raid/boot/efi
\`\`\`
- **What**: Mounts the EFI partition in the chroot environment.
- **Why**: Ensures the EFI directory is available for the \`grub-install\` command.

\`\`\`bash
chroot /mnt/raid grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=debian --recheck
chroot /mnt/raid update-grub
\`\`\`
- **What**: Installs and updates GRUB in the chroot environment.
- **Why**: Configures the boot loader to boot from the RAID device.

#### Step 6: Document the Process
\`\`\`bash
log "\n# Migration Completed\n"
log "The operating system has been successfully migrated to $RAID_DEVICE."
log "Please verify the changes and reboot your system."
\`\`\`
- **What**: Logs the completion of the migration process.
- **Why**: Provides a summary and documentation of the migration steps.

### How to Run the Script
1. Save the script to a file, for example, \`migrate_to_raid.sh\`.
2. Make the script executable:
   \`\`\`sh
   chmod +x migrate_to_raid.sh
   \`\`\`
3. Run the script:
   \`\`\`sh
   sudo ./migrate_to_raid.sh
   \`\`\`

### Additional Notes
- **Backup Your Data**: Ensure you have a full backup before running the script to prevent data loss.
- **Test in a Safe Environment**: Test the script in a non-production environment to verify its functionality.
- **Permissions**: The script requires root permissions to perform the migration and update the boot loader.

By following these steps, you can migrate your Debian 12 operating system to a RAID 1 device, enhancing data redundancy and reliability.
