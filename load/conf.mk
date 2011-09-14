# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#	

## This file is expected to be included in build/main.mk, and before any
## other files to be included.

CXX = g++
CC = gcc
CP = cp
PERL = perl
GPERF = gperf
ASM = as
FLEX = flex
#YACC = yacc
YACC = bison
AWK = gawk
MKDIR = mkdir

# ifeq ($(strip $(sm.out)),)
#   $(info smart: ************************************************************)
#   $(info smart:  The top level output directory is empty, maybe you changed)
#   $(info smart:  the value of variable 'sm.out' by mistaken.)
#   $(info smart: ************************************************************)
#   $(error "Top level output directory unassigned.")
# endif

# Detect custome config file and apply it.
ifneq ($(wildcard $(sm.top)/custom-config),)
  $(info smart: applying custom config...)
  $(eval -include $(sm.top)/custom-config)
endif

