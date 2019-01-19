T= luamidi
V= 0.1
CONFIG= ./config

include $(CONFIG)

SRC= $(T).cpp
OBJS= $(T).o rtmidi/build/librtmidi.so

# lib: src/$(LIBNAME)

%.o : src/%.cpp
	$(CC) $(OCFLAGS) $(DEFS) -c $(<) -o $@

src/$(LIBNAME) : $(OBJS)
	export MACOSX_DEPLOYMENT_TARGET="10.3"; $(CC) $(CFLAGS) $(DEFS) $(LIB_OPTION) -o src/$(LIBNAME) $(OBJS) $(LIBRARY)

install: src/$(LIBNAME)
	mkdir -p $(LUA_LIBDIR)
	cp src/$(LIBNAME) $(LUA_LIBDIR)
	cd $(LUA_LIBDIR); ln -f -s $(LIBNAME) $T.so

clean:
	rm -f src/$(LIBNAME) $(OBJS)
	rm -rf rtmidi/build

rtmidi/rtmidi.c:
	git submodule update --init

rtmidi/build/librtmidi.so: rtmidi/rtmidi.c
	mkdir -p rtmidi/build
	cd rtmidi/build; cmake .. && make
