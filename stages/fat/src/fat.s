BITS 16
ORG 0x7c00

; jump to the FAT boot code
start_jmp:
  jmp start_bootloader
  
times 3 - $ + start_jmp db 0x90

;; FAT BPB ;;
oem_name: times 8 db 0
bytes_per_sector: dw 0
sectors_per_cluster: db 0
reserved_sectors: dw 0
num_fat_tables: db 0
num_fat_entries: dw 0
num_sectors: dw 0
media_descriptor: db 0
sectors_per_fat: dw 0

;; DOS 3.31 BPB ;;
sectors_per_track: dw 0
heads_per_disk: dw 0
hidden_sectors: dd 0
total_logical_sectors: dd 0

;; FAT32 EBPB ;;
logical_sectors_per_fat: dd 0
mirroring_flags: dw 0
fat_version: dw 0
root_directory_cluster: dd 0
fsis_logical_sector: dw 0
fat32_boot_logical_sector: dw 0
reserved: times 12 db 0
pdn: db 0
various: db 0
esignature: db 0
volume_id: dd 0
volume_label: times 11 db 0
fs_type: times 8 db 0

;; entry point ;;
start_bootloader:
  ; align the segment registers
  xor bx, bx
  mov ds, bx
  jmp 0:aligned
  
aligned:
  ; initialise the stack
  mov sp, 0x7bff
  mov bp, sp
  
  ; ensure a reasonable bytes_per_sector value
  mov bx, [bytes_per_sector]
  cmp bx, 512
  jne error
  
  ; save the drive number to memory
  mov [drive], dl
  
  ; load the mbr into memory
  mov ax, 0x0201
  mov cx, 0x0001
  xor dh, dh
  xor bx, bx
  mov es, bx
  mov bx, 0x7e00
  int 0x13
  jc error

find_partition:
  mov cx, 0
  mov si, 0x7fbe
  
find_partition_loop:
  mov bl, [si]
  cmp bl, 0x80
  je partition_found
  inc cx
  add si, 0x10
  cmp cx, 4
  je error
  jmp find_partition_loop

partition_found:
  mov ax, [si+8]
  mov cx, [si+10]
  or cx, cx
  jnz error
  
  add ax, [reserved_sectors] ; reserved sectors, includes boot sector and FSIS
  jc error
  
  mov [partition_offset], ax
  
calculate_size:
  mov ax, [sectors_per_fat]
  xor bx, bx
  mov bl, [num_fat_tables]
  mul bx
  
  or dx, dx
  jnz error
  
  or ah, ah
  jnz error
  
  mov [read_sectors], al
  
load_fat:
  mov ax, [partition_offset]
  call lba2chs
  
  ; set up CHS
  mov ch, al
  mov cl, bl
  mov dh, dl

  mov ah, 0x02
  mov al, [read_sectors]
  inc al
  or al, al
  jz error
  
  mov dl, [drive]
  xor bx, bx
  mov es, bx
  mov bx, 0x8000
  int 0x13
  
  xor ax, ax
  mov al, [read_sectors]
  mov bx, 512
  mul bx
  or dx, dx
  jnz error
  add ax, 0x8000
  jc error
  mov si, ax
  mov cx, 4
  call printhex
  jmp $

; functions

; in: ax = LBA
; out: bx = sector, dx = head, ax = cylinder
lba2chs:
  xor dx, dx
  div word [sectors_per_track]
  inc dx
  mov bx, dx
  xor dx, dx
  div word [heads_per_disk]
  ret

printsz:
  mov al, [si]
  or al, al
  jz print_end
  mov ah, 0x0e
  int 0x10
  inc si
  jmp printsz
  
print_end:
  ret
  
printhex:
  mov al, [si]
  and al, 0xf0
  shr al, 4
  add al, '0'
  cmp al, '9'
  jle nothex
  add al, 'A' - '0' - 10

nothex:
  mov ah, 0x0e
  int 0x10
  
  mov al, [si]
  and al, 0x0f
  add al, '0'
  cmp al, '9'
  jle nothexb
  add al, 'A' - '0' - 10
  
nothexb:
  mov ah, 0x0e
  int 0x10
  inc si
  loop printhex
  mov ax, 0x0e0a
  int 0x10
  mov ax, 0x0e0d
  int 0x10
  ret

error:
  mov si, error_msg
  call printsz
  jmp $
  
drive: db 0
read_sectors: db 0
partition_offset: dw 0
error_msg: db "Error", 0
kernel_name: db "OSKERNEL.BIN", 0
