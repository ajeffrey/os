TOOLSDIR = tools
DRIVE = disk.img
DRIVESIZE = 2048
SECTORSIZE = 512
MBRFILE = obj/mbr

all: checkperms build-tools mkdrive build-stages
	bin/setmbr $(MBRFILE) $(DRIVE)

run: checkperms
	qemu -fda disk.img -m 32

checkperms:

build-tools: mkpart setmbr
  
mkpart:
	make -C $(TOOLSDIR)/$@
	cp $(TOOLSDIR)/$@/$@ bin/$@
	
setmbr:
	make -C $(TOOLSDIR)/$@
	cp $(TOOLSDIR)/$@/$@ bin/$@
	
mkdrive:
	rm -f $(DRIVE)
	dd if=/dev/zero of=$(DRIVE) bs=$(SECTORSIZE) count=$(DRIVESIZE)
	mkfs.vfat $(DRIVE)
	parted $(DRIVE) mkpart primary fat32 0 $(shell expr $(DRIVESIZE) \* $(SECTORSIZE))b
	
build-stages: stage-bootloader

stage-bootloader:
	make -C stages/bootloader
	cp stages/bootloader/mbr $(MBRFILE)
	
