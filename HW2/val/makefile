CC := g++

val: val.o
	$(CC) $^ -o $@
val.o: val.cpp
	$(CC) -c $^

.PHONY: clean

clean:
	rm val.o val
