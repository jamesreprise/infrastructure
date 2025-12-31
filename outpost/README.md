## Making a qcow2 from an ISO
1. `wget https://channels.nixos.org/nixos-25.11/latest-nixos-minimal-x86_64-linux.iso`
2. `qemu-img convert -O qcow2 -f raw latest-nixos-minimal-x86_64-linux.iso latest-nixos-minimal-x86_64-linux.qcow2`
3. `qemu-img convert -O raw latest-nixos-minimal-x86_64-linux.qcow2 latest-nixos-minimal-x86_64-linux.raw`
4. `qemu-img resize latest-nixos-minimal-x86_64-linux.raw 11G`
5. `qemu-img convert -O qcow2 -o compat=0.10 latest-nixos-minimal-x86_64-linux.raw latest-nixos-minimal-x86_64-linux-resized.qcow2`

As I understand it step 2 is unnecessary, but repeating it verbatim as it worked for me.

## Installing & Configuring NixOS
https://nixos.wiki/wiki/NixOS_Installation_Guide

On certain providers I found it necessary to:
* attach a secondary block device
* install nixos onto this secondary block device
* reboot onto the secondary block device
* wipe the primary block device
* install nixos on the primary block device
* detatch & delete the secondary block device

to get around problems where installing on the initial disk which played host to the iso was not possible.
