SUFFIXES = .c .mod .def .o .obj .lo .a .m .mxm

SHELL=/bin/bash

prefix= @prefix@
datarootdir= @datarootdir@
srcdir= @srcdir@
mandir= @mandir@
exec_prefix=@exec_prefix@
bindir= @bindir@
INSTALL_PROGRAM = install
GCCVERSION=15.0.0

DISTFILES = Makefile.in configure.ac configure \
            README.md version.c COPYING INSTALL \
            shell bare-metal-m2 gnu-linux

all: build documentation

build: buildavr buildarm

if ARMPI
buildarm: force
	bash $(srcdir)/shell/build-cross-arm.sh $(srcdir) $(prefix)
else
buildarm: force
endif

if AVR328P
buildavr: force
	bash $(srcdir)/shell/build-cross-avr.sh $(srcdir) $(prefix)
else
buildavr: force
endif

help: force
	@echo "this package knows about:"
	@echo "make help"
	@echo "make build # builds and installs the cross tool chain"
	@echo "make documentation  # produces some slides about the tool chain process"
	@echo "make all # build and install tool chain and build documentation"

install: force
	@echo "this package is currently hard coded to install into $(HOME)/opt-gcc-15"

documentation: bare-metal-m2.pdf bare-metal-m2-html

bare-metal-m2-html: $(srcdir)/bare-metal-m2/doc/bare-metal-m2.ms
	groff -Thtml -mwww -mgp -M$(srcdir)/tmac $(srcdir)/bare-metal-m2/doc/bare-metal-m2.ms > bare-metal-m2.html

bare-metal-m2.ps: $(srcdir)/bare-metal-m2/doc/bare-metal-m2.ms
	groff -P-l -rlandscape=1 -mwww -mgp -M$(srcdir)/tmac $(srcdir)/bare-metal-m2/doc/bare-metal-m2.ms > bare-metal-m2.ps

bare-metal-m2.pdf: bare-metal-m2.ps
	gs -dBATCH -dNOPAUSE -sOutputFile=$@ -sDEVICE=pdfwrite \
           -dAutoRotatePages=/None \
           -c "<< /PageSize [612 792] /Orientation 3 >> setpagedevice" \
           90 rotate 0 -612 translate -f $<

check: checkarm checkavr

if ARMPI
checkarm: force
else
checkarm: force
endif

if AVR328P
checkavr: minavr.hex flashled328.hex

minavr.hex: force
	$(prefix)/bin/avr-gm2 -fscaffold-static -I$(prefix)/lib/gcc/avr/$(GCCVERSION)/m2/m2min/ -c -mmcu=atmega328p -g -Os -fno-exceptions $(srcdir)/bare-metal-m2/minavr.mod
	$(prefix)/bin/avr-gcc -c -mmcu=atmega328p -g -Os $(srcdir)/bare-metal-m2/main.c -DM2MODULE_INIT=_M2_minavr_init -DM2MODULE_FINI=_M2_minavr_fini
	$(prefix)/bin/avr-ld -o minavr.elf main.o minavr.o
	$(prefix)/bin/avr-objcopy -R .eeprom -O ihex minavr.elf minavr.hex

flashled328.hex: force
	$(prefix)/bin/avr-gm2 -fscaffold-static -I$(prefix)/lib/gcc/avr/$(GCCVERSION)/m2/m2min/ -c -mmcu=atmega328p -g -Os -fno-exceptions $(srcdir)/bare-metal-m2/flashled328.mod
	$(prefix)/bin/avr-gcc -c -mmcu=atmega328p -g -Os $(srcdir)/bare-metal-m2/main.c -DM2MODULE_INIT=_M2_flashled328_init -DM2MODULE_FINI=_M2_flashled328_fini
	$(prefix)/bin/avr-ld -o flashled328.elf main.o flashled328.o
	$(prefix)/bin/avr-objcopy -R .eeprom -O ihex flashled328.elf flashled328.hex
else
checkavr: force
endif



release: force
	pwd
	echo m2-cross-`sed -e '/version_string/!d' \
          -e 's/[^0-9.]*\([0-9.]*\).*/\1/' -e q $(srcdir)/version.c` > .fname
	-rm -rf `cat .fname`
	mkdir `cat .fname`
	dst=`cat .fname`; for f in $(DISTFILES); do \
           cp -rp $(srcdir)/$$f $$dst/$$f ; \
        done
	tar --gzip -chf `cat .fname`.tar.gz `cat .fname`
	-rm -rf `cat .fname` .fname

clean: force
	$(RM) -rf build-cross-chain

force:
