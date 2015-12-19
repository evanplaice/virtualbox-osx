#!/bin/bash

# Copies from http://apple.stackexchange.com/q/198737/19755

# set the ISO name from args[0]
ISO_NAME=$1

# set the ISO path from args[1]
ISO_PATH=$2

# mount the stock install image
hdiutil attach "/Applications/Install OS X El Capitan.app/Contents/SharedSupport/InstallESD.dmg" -noverify -nobrowse -mountpoint /Volumes/esd

# create and mount a new image
hdiutil create -o "$ISO_PATH/$ISO_NAME.cdr" -size 7316m -layout SPUD -fs HFS+J
hdiutil attach "$ISO_PATH/$ISO_NAME.cdr.dmg" -noverify -nobrowse -mountpoint /Volumes/iso

# copy the system files over to the new image
#  asr will create a new mountpoint @ /Volumes/OS X Base System
asr restore -source /Volumes/esd/BaseSystem.dmg -target /Volumes/iso -noprompt -noverify -erase

# remove a faulty symlink pointing to the installation packages
rm /Volumes/OS\ X\ Base\ System/System/Installation/Packages

# copy the acutal installation packages from the stock image
cp -rp /Volumes/esd/Packages /Volumes/OS\ X\ Base\ System/System/Installation
cp -rp /Volumes/esd/BaseSystem.chunklist /Volumes/OS\ X\ Base\ System/
cp -rp /Volumes/esd/BaseSystem.dmg /Volumes/OS\ X\ Base\ System/

# unmount everything
hdiutil detach /Volumes/esd
hdiutil detach /Volumes/OS\ X\ Base\ System

# convert the new image.dmg to image.iso
hdiutil convert "$ISO_PATH/$ISO_NAME.cdr.dmg" -format UDTO -o "$ISO_PATH/$ISO_NAME.iso.cdr"
mv "$ISO_PATH/$ISO_NAME.iso.cdr" "$ISO_PATH/$ISO_NAME.iso"

# clean up image.cdr.dmg
rm "$ISO_PATH/$ISO_NAME.cdr.dmg"

# return the name of the iso on successful completion
echo "$ISO_PATH/$ISO_NAME.iso"