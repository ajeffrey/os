#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

#define BOOTSTRAP_SIZE    510
#define BOOTINFO_SIZE     90
#define SECTOR_SIZE       512
#define JMP_SIZE          3

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
    fprintf(stderr, "Failed to open FAT bootstrap file: %s\n\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
  
  if(diskh == NULL) {
    fprintf(stderr, "Failed to open disk image: %s\n\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
  
  // check size of the FAT bootstrap is acceptable
  fseek(bootstraph, 0, SEEK_END);
  int filesize = ftell(bootstraph);
  
  if(BOOTSTRAP_SIZE < filesize) {
    fprintf(stderr, "FAT bootstrap file too large!\n\n");
    exit(EXIT_FAILURE);
  }
  
  fseek(bootstraph, 0, SEEK_SET);
  fseek(diskh, 0, SEEK_SET);
  
  // write the JMP instruction
  char jmp[JMP_SIZE];
  fread(jmp, JMP_SIZE, 1, bootstraph);
  fwrite(jmp, JMP_SIZE, 1, diskh);
  
  // memoize the size of the bootstrap code
  int bootstrap_size = filesize - BOOTINFO_SIZE;
  
  // seek to the correct place to write the bootstrap code
  fseek(bootstraph, BOOTINFO_SIZE, SEEK_SET);
  fseek(diskh, BOOTINFO_SIZE, SEEK_SET);
  
  char buf[bootstrap_size];
  
  if(fread(buf, 1, bootstrap_size, bootstraph) < bootstrap_size) {
    fprintf(stderr, "Failed to read bootstrap file\n\n");
    exit(EXIT_FAILURE);
  }
  
  if(fwrite(buf, 1, bootstrap_size, diskh) < bootstrap_size) {
    fprintf(stderr, "Failed to write bootstrap\n\n");
    exit(EXIT_FAILURE);
  }
  
  printf("bootstrap written\n\n");
  return EXIT_SUCCESS;
}
