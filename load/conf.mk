# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#	

## This file is expected to be included in build/main.mk, and before any
## other files to be included.

# CXX = g++
# CC = gcc
# CP = cp
# PERL = perl
# GPERF = gperf
# ASM = as
# FLEX = flex
# #YACC = yacc
# YACC = bison
# AWK = gawk
# MKDIR = mkdir
CXX = $(error CXX deprecated)
CC = $(error CC deprecated)
CP = $(error CP deprecated)
PERL = $(error PERL deprecated)
GPERF = $(error GPERF deprecated)
ASM = $(error ASM deprecated)
FLEX = $(error FLEX deprecated)
YACC = $(error YACC deprecated)
AWK = $(error AWK deprecated)
MKDIR = $(error MKDIR deprecated)

# Detect custome config file and apply it.
ifneq ($(wildcard $(sm.top)/custom-config),)
  $(warning smart: "custom-config" should be renamred as "smart.config")
endif
ifneq ($(wildcard $(sm.top)/smart.config),)
  $(info smart: apply smart.config..)
  $(eval -include $(sm.top)/smart.config)
endif
