TOOLSDIR = tools
DRIVE = /dev/sdb
PART = /dev/sdb1
FATFILE = obj/fat
MBRFILE = obj/mbr

##################
# all : compile os

all: checkperms tools build-stages
	bin/setmbr $(MBRFILE) $(DRIVE)
	bin/setfat $(FATFILE) $(PART)

#######################
# run : run in emulator
run: checkperms
	qemu -hda $(DRIVE) -m 32 -cpu 486

######################
# format : format disk

format:
	parted $(DRIVE) "mktable msdos"
	parted $(DRIVE) "mkpart primary fat32 1 -1"
	parted $(DRIVE) "mkfs y 1 fat32"
	parted $(DRIVE) "toggle 1 boot"

checkperms:

#################################################
# tools : build the tools needed to compile

tools: setmbr setfat
	
setmbr:
	@make -sC $(TOOLSDIR)/$@
	cp $(TOOLSDIR)/$@/out/$@ bin/$@
	
setfat:
	@make -sC $(TOOLSDIR)/$@
	cp $(TOOLSDIR)/$@/out/$@ bin/$@
	
######################################
# build-stages : build the boot stages

build-stages: stage-mbr stage-fat

stage-mbr:
	@make -sC stages/mbr
	cp stages/mbr/out/mbr $(MBRFILE)

stage-fat:
	@make -sC stages/fat
	cp stages/fat/out/fat $(FATFILE)
	
