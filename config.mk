# Installation paths
PREFIX      ?= /usr/local
BINDIR      ?= $(PREFIX)/bin
SYSCONFDIR  ?= /etc
INITDIR     ?= $(SYSCONFDIR)/init.d
RUNLEVELDIR ?= $(SYSCONFDIR)/runlevels

# s6-overlay specific paths
S6_SERVICE_DIR ?= /etc/services.d
S6_RUN_DIR     ?= /run/service

# Ownership and permissions
INSTALL_OWNER ?= root
INSTALL_GROUP ?= root
