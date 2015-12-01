#!/bin/bash

# Copies from http://apple.stackexchange.com/q/198737/19755

# mount the stock install image
hdiutil attach "/Applications/Install OS X El Capitan.app/Contents/SharedSupport/InstallESD.dmg" -noverify -nobrowse -mountpoint /Volumes/esd

# create and mount a new image
hdiutil create -o ElCapitan.cdr -size 7316m -layout SPUD -fs HFS+J
hdiutil attach ElCapitan.cdr.dmg -noverify -nobrowse -mountpoint /Volumes/iso

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
hdiutil convert ElCapitan.cdr.dmg -format UDTO -o ElCapitan.iso
mv ElCapitan.iso.cdr ElCapitan.iso
