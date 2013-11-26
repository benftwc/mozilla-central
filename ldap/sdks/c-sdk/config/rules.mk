#! gmake
# 
# ***** BEGIN LICENSE BLOCK *****
# Version: MPL 1.1/GPL 2.0/LGPL 2.1
# 
# The contents of this file are subject to the Mozilla Public License Version 
# 1.1 (the "License"); you may not use this file except in compliance with 
# the License. You may obtain a copy of the License at 
# http://www.mozilla.org/MPL/
# 
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
# for the specific language governing rights and limitations under the
# License.
# 
# The Original Code is the Netscape Portable Runtime (NSPR).
# 
# The Initial Developer of the Original Code is
# Netscape Communications Corporation.
# Portions created by the Initial Developer are Copyright (C) 1998-2000
# the Initial Developer. All Rights Reserved.
# 
# Contributor(s):
# 
# Alternatively, the contents of this file may be used under the terms of
# either of the GNU General Public License Version 2 or later (the "GPL"),
# or the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
# in which case the provisions of the GPL or the LGPL are applicable instead
# of those above. If you wish to allow use of your version of this file only
# under the terms of either the GPL or the LGPL, and not to allow others to
# use your version of this file under the terms of the MPL, indicate your
# decision by deleting the provisions above and replace them with the notice
# and other provisions required by the GPL or the LGPL. If you do not delete
# the provisions above, a recipient may use your version of this file under
# the terms of any one of the MPL, the GPL or the LGPL.
# 
# ***** END LICENSE BLOCK ***** 

################################################################################
# We have a 4 pass build process:
#
# Pass 1. export - Create generated headers and stubs. Publish public headers to
#		dist/<arch>/include.
#
# Pass 2. libs - Create libraries. Publish libraries to dist/<arch>/lib.
#
# Pass 3. all - Create programs. 
#
# Pass 4. install - Publish programs to dist/<arch>/bin.
#
# Parameters to this makefile (set these before including):
#
# a)
#	TARGETS	-- the target to create 
#			(defaults to $LIBRARY $PROGRAM)
# b)
#	DIRS	-- subdirectories for make to recurse on
#			(the 'all' rule builds $TARGETS $DIRS)
# c)
#	CSRCS   -- .c files to compile
#			(used to define $OBJS)
# d)
#	PROGRAM	-- the target program name to create from $OBJS
#			($OBJDIR automatically prepended to it)
# e)
#	LIBRARY	-- the target library name to create from $OBJS
#			($OBJDIR automatically prepended to it)
#
################################################################################

ifndef topsrcdir
topsrcdir=$(MOD_DEPTH)
endif

ifndef srcdir
srcdir=.
endif

ifndef NSPR_CONFIG_MK
include $(topsrcdir)/config/config.mk
endif

ifdef USE_AUTOCONF
ifdef CROSS_COMPILE
ifdef INTERNAL_TOOLS
CC=$(HOST_CC)
CCC=$(HOST_CXX)
CFLAGS=$(HOST_CFLAGS)
CXXFLAGS=$(HOST_CXXFLAGS)
endif
endif
endif

#
# This makefile contains rules for building the following kinds of
# libraries:
# - LIBRARY: a static (archival) library
# - SHARED_LIBRARY: a shared (dynamic link) library
# - IMPORT_LIBRARY: an import library, used only on Windows and OS/2
#
# The names of these libraries can be generated by simply specifying
# LIBRARY_NAME and LIBRARY_VERSION.
#

ifdef LIBRARY_NAME
ifeq (,$(filter-out WINNT OS2,$(OS_ARCH)))

#
# Win95, Win16, and OS/2 require library names conforming to the 8.3 rule.
# other platforms do not.
#
ifeq (,$(filter-out WIN95 WIN16 OS2,$(OS_TARGET)))
LIBRARY		= $(OBJDIR)/$(LIBRARY_NAME)$(LIBRARY_VERSION)_s.$(LIB_SUFFIX)
SHARED_LIBRARY	= $(OBJDIR)/$(LIBRARY_NAME)$(LIBRARY_VERSION).$(DLL_SUFFIX)
IMPORT_LIBRARY	= $(OBJDIR)/$(LIBRARY_NAME)$(LIBRARY_VERSION).$(LIB_SUFFIX)
else
LIBRARY		= $(OBJDIR)/lib$(LIBRARY_NAME)$(LIBRARY_VERSION)_s.$(LIB_SUFFIX)
SHARED_LIBRARY	= $(OBJDIR)/lib$(LIBRARY_NAME)$(LIBRARY_VERSION).$(DLL_SUFFIX)
IMPORT_LIBRARY	= $(OBJDIR)/lib$(LIBRARY_NAME)$(LIBRARY_VERSION).$(LIB_SUFFIX)
endif

ifeq ($(OS_ARCH),OS2)
DEF_FILE		   := $(SHARED_LIBRARY:.dll=.def)
endif

else

LIBRARY		= $(OBJDIR)/lib$(LIBRARY_NAME)$(LIBRARY_VERSION).$(LIB_SUFFIX)
ifeq ($(OS_ARCH)$(OS_RELEASE), AIX4.1)
SHARED_LIBRARY	= $(OBJDIR)/lib$(LIBRARY_NAME)$(LIBRARY_VERSION)_shr.a
else
ifdef MKSHLIB
SHARED_LIBRARY	= $(OBJDIR)/lib$(LIBRARY_NAME)$(LIBRARY_VERSION).$(DLL_SUFFIX)
endif
endif

endif
endif

ifndef TARGETS
ifeq (,$(filter-out WINNT OS2,$(OS_ARCH)))
TARGETS		= $(LIBRARY) $(SHARED_LIBRARY) $(IMPORT_LIBRARY)
else
TARGETS		= $(LIBRARY) $(SHARED_LIBRARY)
endif
endif

#
# OBJS is the list of object files.  It can be constructed by
# specifying CSRCS (list of C source files) and ASFILES (list
# of assembly language source files).
#

ifndef OBJS
OBJS		= $(addprefix $(OBJDIR)/,$(CSRCS:.c=.$(OBJ_SUFFIX))) \
		  $(addprefix $(OBJDIR)/,$(ASFILES:.$(ASM_SUFFIX)=.$(OBJ_SUFFIX)))
endif

ifeq ($(OS_TARGET), WIN16)
	comma := ,
	empty :=
	space := $(empty) $(empty)
	W16OBJS = $(subst $(space),$(comma)$(space),$(strip $(OBJS)))
	W16TEMP =$(OS_LIBS) $(EXTRA_LIBS)
    ifeq ($(strip $(W16TEMP)),)
		W16LIBS =
    else
		W16LIBS = library $(subst $(space),$(comma)$(space),$(strip $(W16TEMP)))
    endif
	W16DEF = $(notdir $(basename $(SHARED_LIBRARY))).DEF
endif

ifeq ($(OS_ARCH), WINNT)
ifneq ($(OS_TARGET), WIN16)
OBJS += $(RES)
endif
endif

ALL_TRASH		= $(TARGETS) $(OBJS) $(filter-out . .., $(OBJDIR)) LOGS TAGS $(GARBAGE) \
			  $(NOSUCHFILE) $(DEF_FILE)\
			  so_locations

ifdef DIRS
LOOP_OVER_DIRS		=					\
	@for d in $(DIRS); do					\
		if test -d $$d; then				\
			set -e;					\
			echo "cd $$d; $(MAKE) $(MFLAGS) $@";	\
			$(MAKE) $(MFLAGS) -C $$d $@;			\
			set +e;					\
		else						\
			echo "Skipping non-directory $$d...";	\
		fi;						\
	done
endif

################################################################################

all:: export

export::
	+$(LOOP_OVER_DIRS)

libs:: export

install:: export

clean::
	rm -rf $(OBJS) so_locations $(NOSUCHFILE) $(GARBAGE)
	+$(LOOP_OVER_DIRS)

clobber::
	rm -rf $(OBJS) $(TARGETS) $(filter-out . ..,$(OBJDIR)) $(GARBAGE) so_locations $(NOSUCHFILE)
	+$(LOOP_OVER_DIRS)

realclean clobber_all distclean::
	rm -rf $(wildcard *.OBJ *.OBJD) dist $(ALL_TRASH)
	+$(LOOP_OVER_DIRS)

real_install:: $(RELEASE_BINS) $(RELEASE_HEADERS) $(RELEASE_LIBS)
ifdef RELEASE_BINS
	$(NSINSTALL) -t -m 0755 $(RELEASE_BINS) $(DESTDIR)$(bindir)
endif
ifdef RELEASE_HEADERS
	$(NSINSTALL) -t -m 0644 $(RELEASE_HEADERS) $(DESTDIR)$(includedir)
endif
ifdef RELEASE_LIBS
	$(NSINSTALL) -t -m 0755 $(RELEASE_LIBS) $(DESTDIR)$(libdir)
endif
	+$(LOOP_OVER_DIRS)

release:: export
ifdef RELEASE_BINS
	@echo "Copying executable programs and scripts to release directory"
	@if test -z "$(BUILD_NUMBER)"; then \
		echo "BUILD_NUMBER must be defined"; \
		false; \
	else \
		true; \
	fi
	@if test ! -d $(RELEASE_BIN_DIR); then \
		rm -rf $(RELEASE_BIN_DIR); \
		$(NSINSTALL) -D $(RELEASE_BIN_DIR);\
	else \
		true; \
	fi
	cp $(RELEASE_BINS) $(RELEASE_BIN_DIR)
endif
ifdef RELEASE_LIBS
	@echo "Copying libraries to release directory"
	@if test -z "$(BUILD_NUMBER)"; then \
		echo "BUILD_NUMBER must be defined"; \
		false; \
	else \
		true; \
	fi
	@if test ! -d $(RELEASE_LIB_DIR); then \
		rm -rf $(RELEASE_LIB_DIR); \
		$(NSINSTALL) -D $(RELEASE_LIB_DIR);\
	else \
		true; \
	fi
	cp $(RELEASE_LIBS) $(RELEASE_LIB_DIR)
endif
ifdef RELEASE_HEADERS
	@echo "Copying header files to release directory"
	@if test -z "$(BUILD_NUMBER)"; then \
		echo "BUILD_NUMBER must be defined"; \
		false; \
	else \
		true; \
	fi
	@if test ! -d $(RELEASE_HEADERS_DEST); then \
		rm -rf $(RELEASE_HEADERS_DEST); \
		$(NSINSTALL) -D $(RELEASE_HEADERS_DEST);\
	else \
		true; \
	fi
	cp $(RELEASE_HEADERS) $(RELEASE_HEADERS_DEST)
endif
	+$(LOOP_OVER_DIRS)

alltags:
	rm -f TAGS tags
	find . -name dist -prune -o \( -name '*.[hc]' -o -name '*.cp' -o -name '*.cpp' \) -print | xargs etags -a
	find . -name dist -prune -o \( -name '*.[hc]' -o -name '*.cp' -o -name '*.cpp' \) -print | xargs ctags -a

$(NFSPWD):
	cd $(@D); $(MAKE) $(MFLAGS) $(@F)

$(PROGRAM): $(OBJS)
	@$(MAKE_OBJDIR)
ifeq ($(OS_ARCH)_$(NS_USE_GCC),WINNT_)
	$(CC) $(OBJS) -Fe$@ -link $(LDFLAGS) $(OS_LIBS) $(EXTRA_LIBS)
else
	$(CC) -o $@ $(CFLAGS) $(OBJS) $(LDFLAGS)
endif

$(LIBRARY): $(OBJS)
	@$(MAKE_OBJDIR)
	rm -f $@
ifdef USE_AUTOCONF
	$(AR) $(AR_FLAGS) $(OBJS) $(AR_EXTRA_ARGS)
else
	$(AR) $(OBJS) $(AR_EXTRA_ARGS)
endif # USE_AUTOCONF
	$(RANLIB) $@

ifeq ($(OS_TARGET), WIN16)
$(IMPORT_LIBRARY): $(SHARED_LIBRARY)
	wlib $(OS_LIB_FLAGS) $@ +$(SHARED_LIBRARY)
endif

ifeq ($(OS_TARGET), OS2)
$(DEF_FILE): $(LIBRARY)
	rm -f $@
	echo LIBRARY $(notdir $(basename $(SHARED_LIBRARY))) INITINSTANCE TERMINSTANCE > $@
	echo PROTMODE >> $@
	echo CODE    LOADONCALL MOVEABLE DISCARDABLE >> $@
	echo DATA    PRELOAD MOVEABLE MULTIPLE NONSHARED >> $@
	echo EXPORTS >> $@
	$(FILTER) $(LIBRARY) >> $@

$(IMPORT_LIBRARY): $(DEF_FILE)
	rm -f $@
	$(IMPLIB) $@ $(DEF_FILE)
endif
    
$(SHARED_LIBRARY): $(OBJS) $(DEF_FILE)
	@$(MAKE_OBJDIR)
	rm -f $@
ifdef USE_AUTOCONF
	$(MKSHLIB) $(OBJS) $(EXTRA_LIBS) $(OS_LIBS) $(DEF_FILE)
else
ifeq ($(OS_ARCH)$(OS_RELEASE), AIX4.1)
	echo "#!" > $(OBJDIR)/lib$(LIBRARY_NAME)_syms
	nm -B -C -g $(OBJS) \
		| awk '/ [T,D] / {print $$3}' \
		| sed -e 's/^\.//' \
		| sort -u >> $(OBJDIR)/lib$(LIBRARY_NAME)_syms
	$(LD) $(XCFLAGS) -o $@ $(OBJS) -bE:$(OBJDIR)/lib$(LIBRARY_NAME)_syms \
		-bM:SRE -bnoentry $(OS_LIBS) $(EXTRA_LIBS)
else	# AIX 4.1
ifeq ($(OS_ARCH), WINNT)
ifeq ($(OS_TARGET), WIN16)
	echo system windows dll initinstance >w16link
	echo option map >>w16link
	echo option oneautodata >>w16link
	echo option heapsize=32K >>w16link
	echo option $(OS_DLL_OPTION) >>w16link
	echo debug $(DEBUGTYPE) all >>w16link
	echo name $@ >>w16link
	echo file >>w16link
	echo $(W16OBJS) >>w16link
	echo $(W16IMPORTS) >>w16link
	echo $(W16LIBS) >>w16link
	echo $(W16_EXPORTS) >>w16link
	echo libfile libentry >>w16link
	$(LINK) @w16link.
	rm w16link
else	# WIN16
	$(LINK_DLL) -MAP $(DLLBASE) $(OS_LIBS) $(EXTRA_LIBS) $(OBJS)
endif # WINNT
else
	$(MKSHLIB) -o $@ $(OBJS) $(EXTRA_LIBS) $(OS_LIBS) $(DEF_FILE)
endif	# WINNT
endif	# AIX 4.1
endif   # USE_AUTOCONF


ifeq (,$(filter-out WINNT OS2,$(OS_ARCH)))
$(RES): $(RESNAME)
	@$(MAKE_OBJDIR)
ifeq ($(OS_TARGET),OS2)
	$(RC) -DOS2 -r $(RESNAME) $(RES)
else
# The resource compiler does not understand the -U option.
ifdef NS_USE_GCC
	$(RC) $(filter-out -U%,$(DEFINES)) $(INCLUDES:-I%=--include-dir %) -o $@ $<
else
	$(RC) $(filter-out -U%,$(DEFINES)) $(INCLUDES) -Fo$(RES) $(RESNAME)
endif
endif
	@echo $(RES) finished
endif

$(OBJDIR)/%.$(OBJ_SUFFIX): %.cpp
	@$(MAKE_OBJDIR)
ifeq ($(OS_ARCH)_$(NS_USE_GCC), WINNT_)
	$(CCC) -Fo$@ -c $(CCCFLAGS) $<
else
	$(CCC) -o $@ -c $(CCCFLAGS) $<
endif

WCCFLAGS1 = $(subst /,\\,$(CFLAGS))
WCCFLAGS2 = $(subst -I,-i=,$(WCCFLAGS1))
WCCFLAGS3 = $(subst -D,-d,$(WCCFLAGS2))
$(OBJDIR)/%.$(OBJ_SUFFIX): %.c
	@$(MAKE_OBJDIR)
ifeq ($(OS_ARCH)_$(NS_USE_GCC), WINNT_)
ifeq ($(OS_TARGET), WIN16)
#	$(MOD_DEPTH)/config/w16opt $(WCCFLAGS3)
	echo $(WCCFLAGS3) >w16wccf
	$(CC) -zq -fo$(OBJDIR)\\$*.$(OBJ_SUFFIX)  @w16wccf $*.c
	rm w16wccf
else
	$(CC) -Fo$@ -c $(CFLAGS) $<
endif
else
	$(CC) -o $@ -c $(CFLAGS) $<
endif


$(OBJDIR)/%.$(OBJ_SUFFIX): %.s
	@$(MAKE_OBJDIR)
	$(AS) -o $@ $(ASFLAGS) -c $<

%.i: %.c
	$(CC) -C -E $(CFLAGS) $< > $*.i

%: %.pl
	rm -f $@; cp $< $@; chmod +x $@

#
# HACK ALERT
#
# The only purpose of this rule is to pass Mozilla's Tinderbox depend
# builds (http://tinderbox.mozilla.org/showbuilds.cgi).  Mozilla's
# Tinderbox builds NSPR continuously as part of the Mozilla client.
# Because NSPR's make depend is not implemented, whenever we change
# an NSPR header file, the depend build does not recompile the NSPR
# files that depend on the header.
#
# This rule makes all the objects depend on a dummy header file.
# Touch this dummy header file to force the depend build to recompile
# everything.
#
# This rule should be removed when make depend is implemented.
#

DUMMY_DEPEND_H = $(topsrcdir)/config/prdepend.h

$(filter $(OBJDIR)/%.$(OBJ_SUFFIX),$(OBJS)): $(OBJDIR)/%.$(OBJ_SUFFIX): $(DUMMY_DEPEND_H)

# END OF HACK

################################################################################
# Special gmake rules.
################################################################################

#
# Re-define the list of default suffixes, so gmake won't have to churn through
# hundreds of built-in suffix rules for stuff we don't need.
#
.SUFFIXES:
.SUFFIXES: .a .$(OBJ_SUFFIX) .c .cpp .s .h .i .pl

#
# Fake targets.  Always run these rules, even if a file/directory with that
# name already exists.
#
.PHONY: all alltags clean export install libs realclean release

#
# List the target pattern of an implicit rule as a dependency of the
# special target .PRECIOUS to preserve intermediate files made by
# implicit rules whose target patterns match that file's name.
# (See GNU Make documentation, Edition 0.51, May 1996, Sec. 10.4,
# p. 107.)
#
.PRECIOUS: $(OBJDIR)/%.$(OBJ_SUFFIX)
