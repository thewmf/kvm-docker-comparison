CFLAGS = -m64 -g -Wall -O3 -fopenmp
LDFLAGS = -L. -lutils

all:	bin/gups.exe

bin/gups.exe:	libutils.a gups.o
	gcc $(CFLAGS) -o bin/gups.exe gups.o $(LDFLAGS)

utils.o:	utils.c utils.h
	gcc $(CFLAGS) -c utils.c

libutils.a:	utils.o 
	ar rv libutils.a utils.o
	ranlib libutils.a

gups.o:	gups.c RandomAccess.h utils.h
	gcc $(CFLAGS) -c gups.c
