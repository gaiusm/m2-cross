SUFFIXES = .c .mod .def .o .obj .lo .a .m .mxm

SHELL=/bin/bash

prefix= @prefix@
datarootdir= @datarootdir@
srcdir= @srcdir@
mandir= @mandir@
exec_prefix=@exec_prefix@
bindir= @bindir@
INSTALL_PROGRAM = install
GCCVERSION=12.0.0

DISTFILES = Makefile.in configure.ac configure \
            README.md version.c COPYING INSTALL \
            shell bare-metal-m2 gnu-linux

all: build documentation

build: force
	@echo "this package is currently hard coded to install into $(HOME)/opt-gcc-15"
	@echo "press any key to destroy $(HOME)/opt-gcc-15 or ^C to abort"
	read ans
	bash $(srcdir)/shell/build-cross-gcc.sh $(srcdir)

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
