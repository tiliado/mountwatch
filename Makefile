# Copyright 2013 Jiří Janoušek <janousek.jiri@gmail.com>

APPNAME=removabled
APPVERSION=0.0.1
VALAC=valac
SRC=src
OUT=build
PREFIX=/usr/local
VALA_SRC=src/main.vala src/app.vala
CFLAGS:=-O2
LDFLAGS:=-Wl,--no-undefined -Wl,--as-needed
VALAFLAGS:=$(foreach w,$(CPPFLAGS) $(CFLAGS) $(LDFLAGS),-X $(w))

all: $(OUT)/$(APPNAME)

$(OUT)/$(APPNAME): $(VALA_SRC)
	$(VALAC) $(VALAFLAGS) -v -d $(OUT) --save-temps --pkg gio-2.0 -o $(APPNAME) $(VALA_SRC) \
	-X '-DAPPNAME="$(APPNAME)"' -X '-DAPPVERSION="$(APPVERSION)"'

clean:
	rm -rf $(OUT)

debug: $(OUT)/$(APPNAME)
	$(OUT)/$(APPNAME)

rebuild: clean all

install: $(OUT)/$(APPNAME)
	cp -v $(OUT)/$(APPNAME) $(PREFIX)/bin/$(APPNAME)

uninstall:
	rm -v $(PREFIX)/bin/$(APPNAME)

dist: clean
	tar -cvzf ../$(APPNAME)-$(APPVERSION).tar.gz -X dist-exclude ./

