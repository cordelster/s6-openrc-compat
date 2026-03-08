PACKAGE    = s6-openrc-compat
VERSION    = 0.1.0

include config.mk

# Script sources
SOURCES = src/rc-service.in src/rc-update.in src/init-openrc-compat.sh.in src/rc-status.in src/s6-dumpenv.in
# Generated scripts
SCRIPTS = $(SOURCES:.in=)

# Files for distribution
DISTFILES = Makefile config.mk README.md src/*.in templates/

# Sed replacement command
SED_CMD = sed \
	-e 's|@BINDIR@|$(BINDIR)|g' \
	-e 's|@SYSCONFDIR@|$(SYSCONFDIR)|g' \
	-e 's|@INITDIR@|$(INITDIR)|g' \
	-e 's|@RUNLEVELDIR@|$(RUNLEVELDIR)|g' \
	-e 's|@S6_SERVICE_DIR@|$(S6_SERVICE_DIR)|g' \
	-e 's|@S6_RUN_DIR@|$(S6_RUN_DIR)|g'

.PHONY: all install uninstall clean dist check test

all: $(SCRIPTS)

check: $(SCRIPTS)
	shellcheck -s sh -e SC3043,SC3009 $(SCRIPTS)

test: all
	@echo "Running installation tests..."
	rm -rf test_install
	$(MAKE) install DESTDIR=$(shell pwd)/test_install
	test -f test_install$(BINDIR)/rc-service
	test -f test_install$(BINDIR)/rc-update
	test -f test_install$(BINDIR)/init-openrc-compat.sh
	test -f test_install$(BINDIR)/rc-status
	test -f test_install$(BINDIR)/s6-dumpenv
	@if [ "$(BINDIR)" = "/usr/local/bin" ]; then \
		test -L test_install/usr/bin/rc-service; \
	fi
	rm -rf test_install
	@echo "Tests passed successfully."

src/rc-service: src/rc-service.in
	$(SED_CMD) $< > $@
	chmod +x $@

src/rc-update: src/rc-update.in
	$(SED_CMD) $< > $@
	chmod +x $@

src/init-openrc-compat.sh: src/init-openrc-compat.sh.in
	$(SED_CMD) $< > $@
	chmod +x $@

src/rc-status: src/rc-status.in
	$(SED_CMD) $< > $@
	chmod +x $@

src/s6-dumpenv: src/s6-dumpenv.in
	$(SED_CMD) $< > $@
	chmod +x $@

install: all
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 src/rc-service $(DESTDIR)$(BINDIR)/rc-service
	install -m 755 src/rc-update $(DESTDIR)$(BINDIR)/rc-update
	install -m 755 src/init-openrc-compat.sh $(DESTDIR)$(BINDIR)/init-openrc-compat.sh
	install -m 755 src/rc-status $(DESTDIR)$(BINDIR)/rc-status
	install -m 755 src/s6-dumpenv $(DESTDIR)$(BINDIR)/s6-dumpenv
	
	# Compatibility symlinks for ACF in /usr/bin if needed
	@if [ "$(BINDIR)" = "/usr/local/bin" ]; then \
		install -d $(DESTDIR)/usr/bin; \
		ln -sf $(BINDIR)/rc-service $(DESTDIR)/usr/bin/rc-service; \
		ln -sf $(BINDIR)/rc-update $(DESTDIR)/usr/bin/rc-update; \
		ln -sf $(BINDIR)/rc-status $(DESTDIR)/usr/bin/rc-status; \
	fi

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/rc-service
	rm -f $(DESTDIR)$(BINDIR)/rc-update
	rm -f $(DESTDIR)$(BINDIR)/init-openrc-compat.sh
	rm -f $(DESTDIR)$(BINDIR)/rc-status
	rm -f $(DESTDIR)$(BINDIR)/s6-dumpenv
	# Remove symlinks if they exist
	rm -f $(DESTDIR)/usr/bin/rc-service
	rm -f $(DESTDIR)/usr/bin/rc-update
	rm -f $(DESTDIR)/usr/bin/rc-status

dist: clean
	rm -rf $(PACKAGE)-$(VERSION)
	mkdir -p $(PACKAGE)-$(VERSION)
	cp -r $(DISTFILES) $(PACKAGE)-$(VERSION)/
	tar -czf $(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)-$(VERSION)
	rm -rf $(PACKAGE)-$(VERSION)

clean:
	rm -f $(SCRIPTS)
	rm -f $(PACKAGE)-$(VERSION).tar.gz
