## Makefile for shell-sessions

CMDS = help install
.PHONY: $(CMDS)
MKDIR = install -d
INSTALL = install -pCSv
LIBFILES = session.sh
LIBDIR = $(HOME)/lib
INITFILES = session.login session.logout
INITDIR = $(HOME)/lib/init.d
DOTFILES = .attach_session .detach_session
DOTDIR = $(HOME)
BASHLOGINDIR = $(HOME)/.bash_profile.d
BASHLOGOUTDIR = $(HOME)/.bash_logout.d

help:
	@echo "usage:"
	@$(foreach i,$(CMDS),echo "  make $i";)

install:
	@$(MKDIR) $(LIBDIR) && $(INSTALL) $(LIBFILES) $(LIBDIR)
	@$(MKDIR) $(DOTDIR) && $(INSTALL) $(DOTFILES) $(DOTDIR)
	@$(MKDIR) $(INITDIR) && $(INSTALL) $(INITFILES) $(INITDIR)
	@$(MKDIR) $(BASHLOGINDIR) && \
	  ln -sfv $(INITDIR)/session.login $(BASHLOGINDIR)/10session.login
	@$(MKDIR) $(BASHLOGOUTDIR) && \
	  ln -sfv $(INITDIR)/session.logout $(BASHLOGOUTDIR)/90session.logout
