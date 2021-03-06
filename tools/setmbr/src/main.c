#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

#define MBR_SIZE 510
#define BOOTLOADER_SIZE 440

int main(int argc, char* argv[]) {
  // verify usage and arguments
  if(argc != 3) {
    fprintf(stderr, "Usage: %s <bootstrap-file> <disk-image>\n\n", argv[0]);
    exit(EXIT_FAILURE);
  }
  
  FILE* bootstraph = fopen(argv[1], "r");
  FILE* diskh = fopen(argv[2], "rb+");
  
  // open handles to the disk image and the FAT bootstrap
  if(bootstraph == NULL) {
    fprintf(stderr, "Failed to open MBR bootstrap file: %s\n\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
  
  if(diskh == NULL) {
    fprintf(stderr, "Failed to open disk image: %s\n\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
  
  // check size of the FAT bootstrap is acceptable
  fseek(bootstraph, 0, SEEK_END);
  int filesize = ftell(bootstraph);
  
  if(MBR_SIZE < filesize) {
    fprintf(stderr, "MBR bootstrap file too large!\n\n");
    exit(EXIT_FAILURE);
  }
  
  fseek(bootstraph, 0, SEEK_SET);
  fseek(diskh, 0, SEEK_SET);
  
  char buf[BOOTLOADER_SIZE];
  
  if(fread(buf, 1, BOOTLOADER_SIZE, bootstraph) < BOOTLOADER_SIZE) {
    fprintf(stderr, "Failed to read bootstrap file\n\n");
    exit(EXIT_FAILURE);
  }
  
  if(fwrite(buf, 1, BOOTLOADER_SIZE, diskh) < BOOTLOADER_SIZE) {
    fprintf(stderr, "Failed to write bootstrap\n\n");
    exit(EXIT_FAILURE);
  }
  
  printf("bootstrap written\n\n");
  return EXIT_SUCCESS;
}
