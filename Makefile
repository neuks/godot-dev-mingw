############################################################################### 
# General Purpose Makefile
#
# Copyright (C) 2018, Martin Tang
############################################################################### 

# Toolchain
AR=$(TARGET)ar
PP=$(TARGET)cpp
AS=$(TARGET)as
CC=$(TARGET)gcc
CX=$(TARGET)g++
DB=$(TARGET)gdb
OD=$(TARGET)objdump
OC=$(TARGET)objcopy
RC=windres
FL=flex
BS=bison
LD=$(TARGET)g++
RM=rm

# Configuration
ARFLAGS=cr
PPFLAGS=-Iinclude -Iinclude/core -Iinclude/gen
ASFLAGS=$(PPFLAGS)
CCFLAGS=$(PPFLAGS) -O3 -static-libgcc -static-libstdc++
CXFLAGS=$(CCFLAGS)
DBFLAGS=
RCFLAGS=
FLFLAGS=
BSFLAGS=
LDFLAGS=
EXFLAGS=

# Projects
include Makelist.mk
OUTPUT1=lib/libgodot.a

# Summary
LIBRARY=
OBJECTS=$(OBJECT1)
OUTPUTS=$(OUTPUT1)
DEPENDS=$(OBJECTS:.o=.dep)
CLEANUP=$(DEPENDS) $(OBJECTS) $(OUTPUTS)

# Build Commands
all: $(OUTPUTS)

Makelist.mk:
	@echo "OBJECT1= \\" > Makelist.mk
	@sh -c 'ls -r src/*/*.cpp | sed "s/.cpp/.o/" | sed "s/^/\t/" | sed "s/$$/ \\\/"' >> Makelist.mk
	@echo "" >> Makelist.mk

$(OUTPUT1) : $(OBJECT1)

run: $(OUTPUTS)
	@echo [EX] $<
	@$< $(EXFLAGS)

debug: $(OUTPUTS)
	@echo [DB] $<
	@$(DB) $(DBFLAGS) $<

clean:
	@echo [RM] $(OBJECTS)
	-@$(RM) $(OBJECTS)

# Standard Procedures
%.dep : %.S
	@$(PP) $(PPFLAGS) -MM -MT $(@:.dep=.o) -o $@ $< 2> /dev/null

%.dep : %.c
	@$(PP) $(PPFLAGS) -MM -MT $(@:.dep=.o) -o $@ $< 2> /dev/null

%.dep : %.cpp
	@$(PP) $(PPFLAGS) -MM -MT $(@:.dep=.o) -o $@ $< 2> /dev/null

%.dep : %.rc
	@$(PP) $(PPFLAGS) -MM -MT $(@:.dep=.o) -o $@ $< 2> /dev/null

%.dep : %.l
	@$(PP) $(PPFLAGS) -MM -MT $(@:.dep=.o) -o $@ $< 2> /dev/null

%.dep : %.y
	@$(PP) $(PPFLAGS) -MM -MT $(@:.dep=.o) -o $@ $< 2> /dev/null

%.o : %.S
	@echo [AS] $<
	@$(AS) $(ASFLAGS) -c -o $@ $<

%.o : %.c
	@echo [CC] $<
	@$(CC) $(CCFLAGS) -c -o $@ $<

%.o : %.cpp
	@echo [CX] $<
	@$(CX) $(CXFLAGS) -c -o $@ $<

%.o : %.rc
	@echo [RC] $<
	@$(RC) $(RCFLAGS) -o $@ $<

%.c : %.l
	@echo [FL] $<
	@$(FL) $(FLFLAGS) -o $@ $<

%.c : %.y
	@echo [BS] $<
	@$(BS) $(BSFLAGS) -d -o $@ $<

%.a :
	@echo [AR] $@
	@$(AR) $(ARFLAGS) $@ $^

%.dll :
	@echo [LD] $@
	@$(LD) $(LDFLAGS) -o $@ $^ $(LIBRARY)

%.exe :
	@echo [LD] $@
	@$(LD) $(LDFLAGS) -o $@ $^ $(LIBRARY)

%.elf:
	@echo [LD] $@
	@$(LD) $(LDFLAGS) -o $@ $^ $(LIBRARY)

%.hex : %.exe
	@echo [OC] $@
	@$(OC) -O ihex $< $@

%.hex : %.elf
	@echo [OC] $@
	@$(OC) -O ihex $< $@

#ifneq ($(MAKECMDGOALS),clean)
#	-include $(DEPENDS)
#endif
