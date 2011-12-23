#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

#define MBR_SIZE 436

int main(int argc, char* argv[]) {
  if(argc != 3) {
    fprintf(stderr, "Usage: %s <mbr-file> <disk-image>\n\n", argv[0]);
    exit(EXIT_FAILURE);
  }
  
  FILE* fh = fopen(argv[1], "r");
  FILE* dh = fopen(argv[2], "a");
  
  if(fh == NULL) {
    fprintf(stderr, "Failed to open MBR file: %s\n\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
  
  if(dh == NULL) {
    fprintf(stderr, "Failed to open disk image: %s\n\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
  
  fseek(fh, 0, SEEK_END);
  int filesize = ftell(fh);
  
  if(MBR_SIZE < filesize) {
    fprintf(stderr, "MBR file too large!\n\n");
    exit(EXIT_FAILURE);
  }
  
  fseek(fh, 0, SEEK_SET);
  fseek(dh, 0, SEEK_SET);
  
  char buf[filesize];
  fread(buf, 1, filesize, fh);
  fwrite(buf, 1, filesize, dh);
  
  printf("MBR written\n\n");
  return 0;
}
