#!/bin/bash
TOP=.
OUT_BIN=out/gcc/debug/bin
OUT_LIB=out/gcc/debug/lib
OUT_INTERS=out/gcc/debug/intermediates

function test-log
{
    echo "${BASH_SOURCE}:$1:$2: $3"
}

function test-check-file
{
    #local loc=${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]}
    local loc=$1
    local fn=$2
    [[ -f $fn ]] || ( echo "$loc: missing \"$fn\"" && exit -1 )
}

function test-load-scripts-recursively
{
    local S
    local T=$1
    local D=$2
    for S in $D/*.mk ; do
        S=`basename $S .mk`-$T.sh
        [[ -f $S ]] && {
            test-log ${LINENO} info "check \"`basename $S -$T.sh`\".."
            . $S
        }
    done

    for S in $D/* ; do
        [[ -d $S ]] && [[ "x$S" != "x./out" ]] && {
            test-log ${LINENO} info "in $S"
            test-load-check-scripts $S
        }
    done
}

function test-load-precondition-scripts
{
    local D=$1
    test-load-scripts-recursively pre $D
}

function test-load-check-scripts
{
    local D=$1
    test-load-scripts-recursively check $D
}

test-load-precondition-scripts .

rm -rf out && make -f main.mk

test-load-check-scripts $TOP
