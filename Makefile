## Makefile for shell-sessions
OS := $(shell { uname -o 2>/dev/null || uname -s; } | tr A-Z a-z)
MKDIR = install -d
ifneq (, $(filter darwin% %bsd,$(OS)))
  INSTALL = install -pCSv
else
  INSTALL = install -Cv
endif
LIBFILES = session.sh
LIBDIR = $(HOME)/lib
INITFILES = session.login session.logout
INITDIR = $(HOME)/lib/init.d
DOTFILES = .attach_session .detach_session
DOTDIR = $(HOME)
BASHLOGINDIR = $(HOME)/.bash_profile.d
BASHLOGOUTDIR = $(HOME)/.bash_logout.d
MAKECMDS = help install
.PHONY: $(MAKECMDS)

help:
	@echo "usage:"
	@$(foreach i,$(MAKECMDS),echo "  make $i";)
	@echo "See Makefile about functions of each commands."

install:
	@$(MKDIR) $(LIBDIR) && $(INSTALL) $(LIBFILES) $(LIBDIR)
	@$(MKDIR) $(DOTDIR) && $(INSTALL) $(DOTFILES) $(DOTDIR)
	@$(MKDIR) $(INITDIR) && $(INSTALL) $(INITFILES) $(INITDIR)
	@$(MKDIR) $(BASHLOGINDIR) && { \
	  echo -n 'symlink: '; \
	  ln -sfv $(INITDIR)/session.login $(BASHLOGINDIR)/10session.login; \
	}
	@$(MKDIR) $(BASHLOGOUTDIR) && { \
	  echo -n 'symlink: '; \
	  ln -sfv $(INITDIR)/session.logout $(BASHLOGOUTDIR)/90session.logout; \
	}
