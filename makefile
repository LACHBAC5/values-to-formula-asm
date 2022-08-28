# make all stdasm=.../stdasm

all: main.out

main.out: main.o
	ld -o $@ -L$(stdasm) main.o -lcnvrt -lpow -lprint

%.o: %.s
	as -o $@ -gstabs $<
