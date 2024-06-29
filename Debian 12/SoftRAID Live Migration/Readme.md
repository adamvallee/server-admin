# SoftRAID Live Migration
Version 1.0.1 BETA
*Do not use this script, it will likely destroy your system*
This is an incomplete BASH script, it doesn't have a complete error checking system, and when you reboot, you are left with a mix of hope and blind faith. 


I needed to modify a server's disk configuration from 4 /dev/sd* to 2 RAIDs (/dev/md1 and /dev/md2) while the server was live, because I didn't have any physical access to the server, there was no option to use IPMI or a KVM.

The script is really specific to the system that I was running it on, however it may be helpful for someone who needs to create their own script to do a similar task. I am saving it for future reference.
