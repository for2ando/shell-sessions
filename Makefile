## Makefile for shell-sessions
OS := $(shell { uname -o 2>/dev/null || uname -s; } | tr A-Z a-z)
KERNELVER := $(shell { uname -v 2>/dev/null; } | tr A-Z a-z)
XPAGER := $(shell which pageless || echo $${PAGER:-less})
INSTALL_OPTION_p := $(shell touch t1; if install -p t1 t2 >/dev/null 2>&1; then echo p; fi; rm t[12])
INSTALL_OPTION_C := $(shell touch t1; if install -C t1 t2 >/dev/null 2>&1; then echo C; fi; rm t[12])
INSTALL_OPTION_S := $(shell touch t1; if install -S t1 t2 >/dev/null 2>&1; then echo S; fi; rm t[12])
INSTALL_OPTION_v := $(shell touch t1; if install -v t1 t2 >/dev/null 2>&1; then echo v; fi; rm t[12])
uppercase = $(subst a,A,$(subst b,B,$(subst c,C,$(subst d,D,$(subst e,E,$(subst f,F,$(subst g,G,$(subst h,H,$(subst i,I,$(subst j,J,$(subst k,K,$(subst l,L,$(subst m,M,$(subst n,N,$(subst o,O,$(subst p,P,$(subst q,Q,$(subst r,R,$(subst s,S,$(subst t,T,$(subst u,U,$(subst v,V,$(subst w,W,$(subst x,X,$(subst y,Y,$(subst z,Z,$(1)))))))))))))))))))))))))))
MKDIR = install -d
ifneq (, $(filter ish%,$(KERNELVER)))
  INSTALL = function installv() { install -p $$1 $$2 && echo install -p $$1 $$2;} && installv
else
ifneq (, $(filter darwin% %bsd,$(OS)))
  INSTALL = install -pCSv
else
  INSTALL = install -$(INSTALL_OPTION_p)$(INSTALL_OPTION_S)$(INSTALL_OPTION_V)$(INSTALL_OPTION_v)
endif
endif
DIFF = diff -u
LIBFILES = session.sh
LIBDIR = $(HOME)/lib
INITFILES = session.login session.logout
INITDIR = $(HOME)/lib/init.d
DOTFILES = .attach_session .detach_session .session-machine_startup.sh
DOTDIR = $(HOME)
ifneq (, $(filter cygwin% mingw%,$(OS)))
  STARTUPFILES = session-startup.lnk
  STARTUPDIR := $(shell cygpath -u "$$ProgramData")/Microsoft/Windows/Start Menu/Programs/Startup
endif
BASHLOGINDIR = $(HOME)/.bash_profile.d
BASHLOGOUTDIR = $(HOME)/.bash_logout.d
ifneq (, $(filter cygwin% mingw%,$(OS)))
  IMPORTFILES1 = elevate.cmd elevate.vbs
  IMPORTDIR1 = ../elevate
  IMPORTGIT1 = git@github.com:for2ando/elevate.git
  IMPORTFILES2 = makeshortcut.bat
  IMPORTDIR2 = ../makeshortcut
  IMPORTGIT2 = https://gist.github.com/eaefad628fd3c38b72704ef857102cb1.git
IMPORTTAG = 1 2
else
IMPORTTAG =
endif
MAKECMDS = help all clean cleanimport install diff import prepare

.PHONY: $(MAKECMDS)

help:
	@$(MAKE) --no-print-directory _$@ | $(XPAGER)

_help:
	@echo usage:
	@$(foreach i,$(MAKECMDS),echo "  make $i";)
	@echo "See Makefile about functions of each commands."

all: session-startup.lnk

clean:
	rm -f session-startup.lnk

cleanimport:
	rm -f $(foreach i,$(IMPORTTAG), $(IMPORTFILES$(i)))

session-startup.lnk:
	cmd /c makeshortcut.bat '$@' '$(shell cygpath -w $$(which bash))' -c '~/.session-machine_startup.sh'

install:: install-lib install-init install-dot install-bashlogin install-bashlogout
ifneq (, $(filter cygwin% mingw%,$(OS)))
install:: install-startup
endif

install-lib install-init install-dot::
	$(eval dest := $(call uppercase,$(patsubst install-%,%,$@)))
	$(eval dir := $$($(dest)DIR))
	$(eval files := $$($(dest)FILES))
	@$(MKDIR) $(dir) && $(INSTALL) $(files) $(dir)

install-startup::
	$(eval dest := $(call uppercase,$(patsubst install-%,%,$@)))
	$(eval dir := $$($(dest)DIR))
	$(eval files := $$($(dest)FILES))
	@test -d "$(dir)" && ./elevate.cmd $(INSTALL) $(files) "$(dir)" && echo $(INSTALL) $(files) "$(dir)"

install-bashlogin:: 
	@$(MKDIR) $(BASHLOGINDIR) && { \
	  echo -n 'symlink: '; \
	  ln -sfv $(INITDIR)/session.login $(BASHLOGINDIR)/10session.login; \
	}

install-bashlogout::
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

define IMPORTRULES

import:: $$(IMPORTFILES$(1))
prepare:: $$(IMPORTFILES$(1))

$$(IMPORTFILES$(1)): $$(IMPORTDIR$(1))
	cp -p $$(addprefix $$^/,$$@) .

$$(IMPORTDIR$(1)):
	cd $$(dir $$@) && git clone $$(IMPORTGIT$(1)) $$(notdir $$@)

endef

ifneq (, $(IMPORTTAG))
$(foreach i,$(IMPORTTAG),$(eval $(call IMPORTRULES,$(i))))
endif
