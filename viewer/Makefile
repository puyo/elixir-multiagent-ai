###############
# Compiler options

CXX = g++-8
LD = g++-8

#CXXFLAGS = -Wall -O2
#CXXFLAGS += -fpic
CXXFLAGS += `pkg-config --cflags msgpack nanomsg sdl libpng`

LDFLAGS += `pkg-config --libs sdl libpng msgpack nanomsg`

###############
# Targets

SRCS = $(wildcard *.cpp)
OBJS = $(SRCS:.cpp=.o)
HDRS = $(wildcard *.hpp)

TARGET = viewer

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) $^ -o $@

# C++

clean:
	$(RM) -fv *.o *~ $(TARGET)
