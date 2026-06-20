LIB := libz.a

SRCS := \
	adler32.c \
	compress.c \
	crc32.c \
	deflate.c \
	gzclose.c \
	gzlib.c \
	gzread.c \
	gzwrite.c \
	infback.c \
	inffast.c \
	inflate.c \
	inftrees.c \
	trees.c \
	uncompr.c \
	zutil.c

OBJS := $(SRCS:.c=.o)

CC ?= cc
AR ?= ar
RANLIB ?= ranlib

CPPFLAGS +=
CFLAGS += -O2 -fPIC -Wall

.PHONY: all clean

all: $(LIB)

$(LIB): $(OBJS)
	$(AR) rcs $@ $(OBJS)
	$(RANLIB) $@

%.o: %.c zlib.h zconf.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJS) $(LIB)
