# Copyright 2012 Jiří Janoušek <janousek.jiri@gmail.com>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met: 
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer. 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution. 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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

