#  This file was taken from sslscan (https://github.com/rbsec/sslscan) 
#  All Credits goes to them for the OpenSSL static build stuff :) 
#
#
#
# set gcc as default if CC is not set
ifndef CC
  CC=gcc
endif

GIT_VERSION = $(shell git describe --tags --always --dirty=-wip)

# Ugly hack to get version if git isn't installed
ifeq ($(GIT_VERSION),)
  GIT_VERSION = $(shell grep -E -o -m 1 "[0-9]+\.[0-9]+\.[0-9]+" Changelog)
endif

# Detect OS
OS := $(shell uname)

SRCS      = bin/scan.cr
PREFIX    = /usr
BINDIR    = $(PREFIX)/bin

WARNINGS  = -Wall -Wformat=2
DEFINES   = -DVERSION=\"$(GIT_VERSION)\"

# for dynamic linking
LIBS      = -lssl -lcrypto
ifneq ($(OS), FreeBSD)
	LIBS += -ldl
endif

# for static linking
ifeq ($(STATIC_BUILD), TRUE)
PWD          = $(shell pwd)/static_libs
LDFLAGS      += -L${PWD}/
CFLAGS       += -I${PWD}/include/ -I${PWD}/ -I${PWD}/pcre/
LIBS         = -lssl -lcrypto -lz -lpcre -levent
endif

ifneq ($(OS), FreeBSD)
	LIBS += -ldl
endif
GIT_VERSION  := $(GIT_VERSION)-static

.PHONY: all sslscanner clean install uninstall static

all: sslscanner
	@echo
	@echo "==========="
	@echo "| WARNING |"
	@echo "==========="
	@echo
	@echo "Building against system OpenSSL. Legacy protocol checks may not be possible."
	@echo "It is recommended that you statically build sslscanner with  \`make static\`."
	@echo

sslscanner: $(SRCS)
ifeq ($(STATIC_BUILD), TRUE)
	crystal build ${SRCS} --release --link-flags "-static ${LDFLAGS} ${CFLAGS} ${CPPFLAGS} ${DEFINES} ${LIBS} -I/usr/lib/"
else
	crystal build ${SRCS} --release 
endif

install:
	@if [ ! -f sslscanner ] ; then \
		echo "\n=========\n| ERROR |\n========="; \
		echo "Before installing you need to build sslscanner with either \`make\` or \`make static\`\n"; \
		exit 1; \
	fi
ifeq ($(OS), Darwin)
	install -d $(DESTDIR)$(BINDIR)/;
	install sslscanner $(DESTDIR)$(BINDIR)/sslscanner;
else
	install -D sslscanner $(DESTDIR)$(BINDIR)/sslscanner;
endif

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/sslscanner

static:
	$(MAKE) sslscanner STATIC_BUILD=TRUE

clean:
	rm -f scan
