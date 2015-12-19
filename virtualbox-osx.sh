#!/bin/bash

# instructions adapted from http://www.perkin.org.uk/posts/create-virtualbox-vm-from-the-command-line.html

# set the profile name
VM='OSX-El-Capitan'

# set the location where the VM will be created
VM_DIR="${HOME}/VirtualBox VMs/$VM"

# create the VM directory
mkdir "$VM_DIR"

# create the install ISO
ISO_PATH=$(./osx-install-iso.sh "$VM" "$VM_DIR" | tail -n1)

# create a new virtual disk
VBoxManage createhd --filename "$VM_DIR/$VM.vdi" --variant fixed --size 32768

# attach the virtual disk
RAW_DISK=$(./vdi-attach.sh "$VM_DIR/$VM.vdi" | tail -n1)

# format the virtual disk
diskutil eraseDisk JHFS+ "$VM" "$RAW_DISK"

# detach the virtual disk
hdiutil detach "$RAW_DISK"

# create an OSX 10.00 El Capitan x64 profile
VBoxManage createvm --register --name "$VM" --ostype MacOS_64

# create a new virtual SATA controller,  attach the virtual disk and installation iso
VBoxManage storagectl "$VM" --name "SATA Controller" --add sata --controller IntelAHCI
VBoxManage storageattach "$VM" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VM_DIR/$VM.vdi"
VBoxManage storageattach "$VM" --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium ./ElCapitan.iso

# modify some system settings
VBoxManage modifyvm "$VM" --chipset piix3
VBoxManage modifyvm "$VM" --firmware efi
VBoxManage modifyvm "$VM" --memory 4096 --vram 128
VBoxManage modifyvm "$VM" --mouse usbtablet --keyboard usb

# fix "Stuck on boot: "Missing Bluetooth Controller Transport"
VBoxManage modifyvm "$VM" --cpuidset 00000001 000306a9 00020800 80000201 178bfbff

# start the VM
VBoxManage startvm "$VM" --type gui