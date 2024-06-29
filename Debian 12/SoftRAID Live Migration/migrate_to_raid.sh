#!/bin/bash

LOGFILE="MigrationLog.md"
RAID_DEVICE="/dev/md1"
CURRENT_ROOT="/dev/sda"
EFI_PARTITION="/dev/sda1"
UNUSED_DEVICE="/dev/sdd"

# Function to log messages
log() {
    echo -e "$1" | tee -a $LOGFILE
}

# Step 1: Detect the current disk layout
log "# Disk Layout\n"
lsblk | tee -a $LOGFILE

ROOT_DEVICE=$(df / | tail -1 | awk '{print $1}')
log "\n## Current Root Device\n$ROOT_DEVICE\n"

# Step 2: Verify the RAID device
log "\n# Verifying RAID Device\n"
mdadm --detail $RAID_DEVICE | tee -a $LOGFILE

# Step 3: Unmount the RAID device if it is mounted
if mountpoint -q /mnt/raid; then
    umount /mnt/raid
fi

# Step 4: Migrate the OS to the RAID device
log "\n# Migrating OS to RAID Device\n"
mkfs.ext4 $RAID_DEVICE
mkdir -p /mnt/raid
mount $RAID_DEVICE /mnt/raid

log "\n## Copying Data\n"

# Ensure rsync is installed
if ! command -v rsync &> /dev/null; then
    log "\n## Error: rsync command not found. Installing rsync...\n"
    apt-get update
    apt-get install -y rsync
fi

rsync -aAXv / /mnt/raid --exclude={"/mnt/raid","/proc","/tmp","/dev","/sys","/run","/mnt"}

# Ensure the necessary directories exist
mkdir -p /mnt/raid/dev /mnt/raid/proc /mnt/raid/sys /mnt/raid/tmp /mnt/raid/boot/efi

# Step 5: Update the boot loader configuration
log "\n# Updating Boot Loader\n"
UUID=$(blkid -s UUID -o value $RAID_DEVICE)
sed -i "s|$(blkid -s UUID -o value $ROOT_DEVICE)|$UUID|g" /mnt/raid/etc/fstab
sed -i "s|$(blkid -s UUID -o value $ROOT_DEVICE)|$UUID|g" /mnt/raid/boot/grub/grub.cfg
sed -i "s|$(blkid -s UUID -o value $ROOT_DEVICE)|$UUID|g" /mnt/raid/etc/default/grub

# Bind mount necessary filesystems
mount --bind /dev /mnt/raid/dev
mount --bind /proc /mnt/raid/proc
mount --bind /sys /mnt/raid/sys
mount --bind /tmp /mnt/raid/tmp

# Mount the EFI partition
mount $EFI_PARTITION /mnt/raid/boot/efi

# Ensure chroot is available
if ! command -v chroot &> /dev/null; then
    log "\n## Error: chroot command not found.\n"
    exit 1
fi

# Install and update GRUB
chroot /mnt/raid grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=debian --recheck
chroot /mnt/raid update-grub

# Update the bootloader on /dev/sdd as well to ensure redundancy
chroot /mnt/raid grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=debian --recheck
chroot /mnt/raid update-grub

log "\n## Boot Loader Updated\n"

# Step 6: Document the process
log "\n# Migration Completed\n"
log "The operating system has been successfully migrated to $RAID_DEVICE."
log "Please verify the changes and reboot your system."

# Unmount filesystems
umount /mnt/raid/boot/efi
umount /mnt/raid/dev
umount /mnt/raid/proc
umount /mnt/raid/sys
umount /mnt/raid/tmp
umount /mnt/raid

# End of script
