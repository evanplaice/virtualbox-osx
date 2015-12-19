# VirtualBox OSX Image - Creation Tool

Creating Virtual Machines can be a painful process, especially for those who don't have a strong background in system administration.

While there is a lot of good information to be found online, virtually every tutorial/guide requires a non-trivial amount of manual tweaking to get a working system up and running.

This project completely automates the process of creating an OSX virtual machine that will run on Apple hardware.

### Usage

1. Verify that 'Install OS X El Capitan.app' is in the `/Applications` directory
2. Run `./virtualbox-osx.sh`

### How it works

1. An install ISO is created from the `.app` file
2. A VirtualBox VDisk file is created
3. The VDisk is attached (ie not mounted) as a fake physical disk
4. The VDisk is formatted as a JHFS+ volume
5. The VDisk is detached
5. A new VirtualBox VM is created with the VDisk attached and a few 'sane' defaults

*Note: The VM will boot into the OSX installer. After installation is complete, don't forget to detach the install disc (ie `ElCapitan.iso`).*

### Default Settings

- VDisk - 32GB (fixed)
- Architecture - x64
- Chipset - PIIX3
- BootType - EFI
- RAM - 4GB
- VRAM - 128MB

*Note: This setup has been verified on an iMac (Late2009). The settings are currently hardcoded in `virtualbox-osx.sh` if you need/want to make changes.* 
 
### Files

- virtualbox-osx.sh

  Creates an OSX virtualbox profile + vdisk image

- osx-install-iso.sh

  Creates an install disk iso from the stock `Install OS X El Capitan.app`

- vdi-attach.sh

  Attaches a VirtualBox VDI (Virtual Disk Image) as if it were a physical disk using fairy dust and magic

### Nerd Stuff

**Pain to the A... Holla**

While the `install.app` contains everything needed to create an `installer.iso`, making it work requires a number of hacks.

1. Create a `install.cdr` file formatted as JHFS+ and allocate enough space for the install files
2. Attach the `install.cdr`
3. Load `install.cdr` with 'System Restore' so it'll boot with a minimal OSX environment
4. Remove a symlink that would points to a 'System Restore' specific packages directory
5. Copy the install packages from `install.app`
6. Detach `install.cdr`
7. Convert `install.cdr` to `install.iso`

*Note: Why Apple doesn't provide a utility to automate this process is beyond me. Maybe the 'unwashed masses' aren't ready for the awesome power of a fresh OSX install. Somebody call a 'Genuis'.*

**[Puppies Farting Rainbows and a Bodybuilding Unicorn](http://i.imgur.com/BmGsO.jpg)**

Fairy dust and magic can be both wonderful and terrifying. Seeing a comment that says `// here be magic` is usually a really bad sign. Since you're here I'll attempt to explain the details of mounting a VDI as a fake disk sans excessive 'hand waving'.

Mounting disk images is nothing new. At the OS level, it simply maps a new volume and uses the contents of the image as if it were raw disk data.

Virtual Disks don't work with standard mounting tools because they contain additional metadat at the head of the raw binary data. To make things more comples, the metadata length is not fixed.

The `vdi-attach.sh` script solves that issue by decoding the header length field using nothin but standard POSIX CLI tools.

To attach the disk, it calls `hdid` (ie the precursor to hdiutil) including an offset (calculated previously) where it can start reading the raw disk data.

*Note: While `hdiutil` is an obvious improvement from `hdid`, it would be really cool if they would add this functionality back in. `hdid` is officially deprecated so there's no telling how long until it's removed altogether.*