# this file is a part of tmake, get the latest version at https://github.com/stanix-org/tconf
# makefile include with rules to compile

ifneq ($(SRCDIRS),)
	vpath %.c $(SRCDIRS)
	vpath %.cxx $(SRCDIRS)
	vpath %.s $(SRCDIRS)
endif

$(BUILDDIR)/%.c.o :$(BUILDDIR)/%.c
	@mkdir -p "$(@D)"
	@echo "CC $<"
	$(Q)$(CC) $(CFLAGS) $(TMAKE_CFLAGS) -o "$@" -c $<

$(BUILDDIR)/%.c.o : %.c
	@mkdir -p "$(@D)"
	@echo "CC $<"
	$(Q)$(CC) $(CFLAGS) $(TMAKE_CFLAGS) -o "$@" -c $<

$(BUILDDIR)/%.c.so : %.c
	@mkdir -p "$(@D)"
	@echo "CC $<"
	$(Q)$(CC) $(CFLAGS) $(TMAKE_CFLAGS) -fpic -D__SHARED__=1 -o "$@" -c $<

$(BUILDDIR)/%.cxx.o : %.cxx
	@mkdir -p "$(@D)"
	@echo "CXX $<"
	$(Q)$(CXX) $(CXXFLAGS) $(TMAKE_CFLAGS) -o "$@" -c $<

$(BUILDDIR)/%.cxx.so : %.cxx
	@mkdir -p "$(@D)"
	@echo "CXX $<"
	$(Q)$(CXX) $(CXXFLAGS) $(TMAKE_CFLAGS) -fpic -D__SHARED__=1 -o "$@" -c $<

$(BUILDDIR)/%.s.o : %.s
	@mkdir -p "$(@D)"
	@echo "AS $<"
	$(Q)$(AS) $(ASFLAGS) -o "$@" $<

$(BUILDDIR)/%.s.so : %.s
	@mkdir -p "$(@D)"
	@echo "AS $<"
	$(Q)$(AS) $(ASFLAGS) -o "$@" $<
