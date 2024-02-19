T= luamidi
V= 0.1a

ifeq '$(findstring ;,$(PATH))' ';'
    detected_OS := Windows
else
    detected_OS := $(shell uname 2>/dev/null || echo Unknown)
    detected_OS := $(patsubst CYGWIN%,Cygwin,$(detected_OS))
    detected_OS := $(patsubst MSYS%,MSYS,$(detected_OS))
    detected_OS := $(patsubst MINGW%,MSYS,$(detected_OS))
endif

# default to the existing config.
CONFIG=./config

ifeq ($(detected_OS),Darwin)        # Mac OS X
    CONFIG=./config.darwin
endif

include $(CONFIG)

SRC= $(T).cpp
OBJS= $(T).o 

# lib: src/$(LIBNAME)

%.o : src/%.cpp
	$(CC) $(OCFLAGS) $(DEFS) -c $(<) -o $@

src/$(LIBNAME) : $(OBJS)
	$(CC) $(CFLAGS) $(DEFS) $(LIB_OPTION) -o src/$(LIBNAME) $(OBJS) $(LIBRARY)

install: src/$(LIBNAME)
	mkdir -p $(LUA_LIBDIR)
	cp src/$(LIBNAME) $(LUA_LIBDIR)
	cd $(LUA_LIBDIR); ln -f -s $(LIBNAME) $T.so

clean:
	rm -f src/$(LIBNAME) $(OBJS)
