OBJS = $(patsubst %.c,obj/%.o,$(shell ls src))
OFLAGS =
CFLAGS = -Iinc -c
CC = gcc
OUT = setfat

all: $(OBJS)
	$(CC) -o out/$(OUT) $(OBJS) $(OFLAGS)
  
obj/%.o: src/%.c
	$(CC) $(CFLAGS) -o $@ $^
