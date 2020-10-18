## Makefile for shell-sessions

CMDS = help install
.PHONY: $(CMDS)
INSTALL = install -pCSv
LIBFILES = session.sh
LIBDIR = $(HOME)/lib
INITFILES = session.login session.logout
INITDIR = $(HOME)/lib/init.d
DOTFILES = .attach_session .detach_session
DOTDIR = $(HOME)

help:
	@echo "usage:"
	@$(foreach i,$(CMDS),echo "  make $i";)

install:
	install -d $(LIBDIR) && $(INSTALL) $(LIBFILES) $(LIBDIR)
	install -d $(DOTDIR) && $(INSTALL) $(DOTFILES) $(DOTDIR)
	install -d $(INITDIR) && $(INSTALL) $(INITFILES) $(INITDIR)
	ln -sf $(INITDIR)/session.login $(HOME)/.bash_profile.d/10session.login
	ln -sf $(INITDIR)/session.logout $(HOME)/.bash_logout.d/90session.logout
