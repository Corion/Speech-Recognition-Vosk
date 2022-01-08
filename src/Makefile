CFLAGS=-I../build/vosk-api/src
LDFLAGS=-L../build/vosk-api/src -lvosk -ldl -lpthread -Wl,-rpath=../build/vosk-api/src

all: stream_vosk

stream_vosk: stream_vosk.o
	g++ $^ -o $@ $(LDFLAGS)

%.o: %.c
	g++ $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o *.a stream_vosk
