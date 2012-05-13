%define MBR_POS 0x01be
%define MBR_SIZE 15
%define MBR_COUNT 4

%define RELOC_POS 0x0060
%define POS 0x07c0

BITS 16
ORG 0

start:
  ; set segment registers
  mov bx, POS
  mov ds, bx
  jmp POS:aligned
  
aligned:
  ; check that we're loading from a hdd
  test dl, 0x80
  jz error
  
  ; copy self to 0x0600 for chain-loading
  xor di, di
  xor si, si
  mov bx, POS
  mov es, bx
  mov bx, RELOC_POS
  mov fs, bx
  xor bx, bx
  mov cx, 256
  
move_loop:
  mov word ax, [es:si + bx]
  mov word [fs:di + bx], ax
  add bx, 2
  loop move_loop, cx
  
  ; jump to copy of self at 0x0600
  jmp RELOC_POS:loader_moved
  
loader_moved:
  mov bx, RELOC_POS
  mov ds, bx
  ; locate bootable partition
  mov cx, MBR_COUNT
  mov di, MBR_POS
  
partition_loop:
  cmp byte [di], 0x80
  je boot
  add di, MBR_SIZE
  loop partition_loop, cx
  jmp error
  
boot:
  ; reset drive
  xor ah, ah
  int 0x13
  
  ; assert that extended BIOS is available
  mov ah, 0x41
  mov bx, 0x55AA
  int 0x13
  jc error
  
  ; load the FAT bootloader into memory
  mov bx, [di + 8]
  mov [dap_lba], bx
  mov bx, [di + 10]
  mov [dap_lba + 2], bx
  
  mov ah, 0x42
  mov si, dap
  int 0x13
  
  ; ensure we actually read something
  jc error
  
  or ah, ah
  jnz error
  
  mov ax, 0x0100
  int 0x13
  jc error
  or al, al
  jnz error
  
  
exec_fat:
  xor bx, bx
  mov ds, bx
  
  mov ax, 0x0e42
  int 0x10
  jmp 0:0x7c00
  
error:
  mov ax, 0x0e45
  int 0x10
  jmp $
  
dap:
dap_size:
  db 16

dap_resv:
  db 0
  
dap_sectors:
  dw 1
  
dap_dest:
  dw 0
  dw POS
  
dap_lba:
  dd 0
  dd 0
  
times 440 - $ + start db 0
