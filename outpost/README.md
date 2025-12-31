## Making a qcow2 from an ISO
1. `wget https://channels.nixos.org/nixos-25.11/latest-nixos-minimal-x86_64-linux.iso`
2. `qemu-img convert -O qcow2 -f raw latest-nixos-minimal-x86_64-linux.iso latest-nixos-minimal-x86_64-linux.qcow2`
3. `qemu-img convert -O raw latest-nixos-minimal-x86_64-linux.qcow2 latest-nixos-minimal-x86_64-linux.raw`
4. `qemu-img resize latest-nixos-minimal-x86_64-linux.raw 11G`
5. `qemu-img convert -O qcow2 -o compat=0.10 latest-nixos-minimal-x86_64-linux.raw latest-nixos-minimal-x86_64-linux-resized.qcow2`

As I understand it step 2 is unnecessary, but repeating it verbatim as it worked for me.
