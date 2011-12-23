OBJS = $(patsubst %.c,obj/%.o,$(shell ls src))
OFLAGS =
CFLAGS = -Iinc -c
CC = gcc
OUT = mkpart

all: $(OBJS)
	$(CC) -o $(OUT) $(OBJS) $(OFLAGS)
  
obj/%.o: src/%.c
	$(CC) $(CFLAGS) -o $@ $^
