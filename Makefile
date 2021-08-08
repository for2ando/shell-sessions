## Makefile for shell-sessions
OS := $(shell { uname -o 2>/dev/null || uname -s; } | tr A-Z a-z)
XPAGER := $(shell which pageless || echo $${PAGER:-less})
uppercase = $(subst a,A,$(subst b,B,$(subst c,C,$(subst d,D,$(subst e,E,$(subst f,F,$(subst g,G,$(subst h,H,$(subst i,I,$(subst j,J,$(subst k,K,$(subst l,L,$(subst m,M,$(subst n,N,$(subst o,O,$(subst p,P,$(subst q,Q,$(subst r,R,$(subst s,S,$(subst t,T,$(subst u,U,$(subst v,V,$(subst w,W,$(subst x,X,$(subst y,Y,$(subst z,Z,$(1)))))))))))))))))))))))))))
MKDIR = install -d
ifneq (, $(filter darwin% %bsd,$(OS)))
  INSTALL = install -pCSv
else
  INSTALL = install -Cv
endif
DIFF = diff -u
LIBFILES = session.sh
LIBDIR = $(HOME)/lib
INITFILES = session.login session.logout
INITDIR = $(HOME)/lib/init.d
DOTFILES = .attach_session .detach_session
DOTDIR = $(HOME)
BASHLOGINDIR = $(HOME)/.bash_profile.d
BASHLOGOUTDIR = $(HOME)/.bash_logout.d
MAKECMDS = help install diff
.PHONY: $(MAKECMDS)

help:
	@$(MAKE) --no-print-directory _$@ | $(XPAGER)

_help:
	@echo usage:
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

diff diff-lib diff-init diff-dot diff-bashlogin diff-bashlogout:
	@$(MAKE) --no-print-directory _$@ | $(XPAGER)

_diff: _diff-lib _diff-init _diff-dot _diff-bashlogin _diff-bashlogout

_diff-lib _diff-init _diff-dot _diff-bashlogin _diff-bashlogout:
	$(eval dest := $(call uppercase,$(patsubst _diff-%,%,$@)))
	$(eval dir := $$($(dest)DIR))
	$(eval files := $$($(dest)FILES))
	@$(foreach f,$(files), \
	  echo -------$(DIFF) $(dir)/$f $f; \
	  $(DIFF) $(dir)/$f $f || true; \
	)

