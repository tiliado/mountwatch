# Copyright 2013 Jiří Janoušek <janousek.jiri@gmail.com>

APPNAME=Mount Watch
APPPATH=mountwatch
APPVERSION=0.0.1
VALAC=valac
SRC=src
OUT=build
PREFIX=/usr/local
VALA_SRC=src/main.vala src/app.vala
CFLAGS:=-O2
LDFLAGS:=-Wl,--no-undefined -Wl,--as-needed
VALAFLAGS:=$(foreach w,$(CPPFLAGS) $(CFLAGS) $(LDFLAGS),-X $(w))

all: $(OUT)/$(APPPATH)

$(OUT)/$(APPPATH): $(VALA_SRC)
	$(VALAC) $(VALAFLAGS) -v -d $(OUT) --save-temps --pkg gio-2.0 -o $(APPPATH) $(VALA_SRC) \
	-X '-DAPPNAME="$(APPNAME)"' -X '-DAPPPATH="$(APPPATH)"' -X '-DAPPVERSION="$(APPVERSION)"'

clean:
	rm -rf $(OUT)

debug: $(OUT)/$(APPPATH)
	$(OUT)/$(APPPATH)

rebuild: clean all

install: $(OUT)/$(APPPATH)
	cp -v $(OUT)/$(APPPATH) $(PREFIX)/bin/$(APPPATH)

uninstall:
	rm -v $(PREFIX)/bin/$(APPPATH)

dist: clean
	tar -cvzf ../$(APPPATH)-$(APPVERSION).tar.gz -X dist-exclude ./

