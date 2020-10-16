## Makefile for shell-sessions

CMDS = help install
.PHONY: $(CMDS)
INSTALL = install -pCSv
LIBFILES = session.sh
LIBDIR = $(HOME)/lib
LOGINFILES = session.login
LOGINDIR = $(HOME)/.bash_profile.d
LOGOUTFILES = session.logout
LOGOUTDIR = $(HOME)/.bash_logout.d
DOTFILES = .attach_session .detach_session
DOTDIR = $(HOME)

help:
	@echo "usage:"
	@$(foreach i,$(CMDS),echo "  make $i";)

install:
	install -d $(LIBDIR) && $(INSTALL) $(LIBFILES) $(LIBDIR)
	install -d $(LOGINDIR) && $(INSTALL) $(LOGINFILES) $(LOGINDIR)
	install -d $(LOGOUTDIR) && $(INSTALL) $(LOGOUTFILES) $(LOGOUTDIR)
	install -d $(DOTDIR) && $(INSTALL) $(DOTFILES) $(DOTDIR)
