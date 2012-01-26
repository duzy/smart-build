#!/bin/bash
TOP=.
OUT_INC=out/include
OUT_DOC=out/documents
OUT_BIN=out/gcc/debug/bin
OUT_LIB=out/gcc/debug/lib
OUT_TEMP=out/gcc/debug/temp
OUT_INTERS=out/gcc/debug/intermediates


EXE=
case `uname` in
    Linux)
        EXE=
        ;;
    Win32)
        EXE=.exe
        ;;
    *)
        echo "Unsupported platform!" && exit -1
        ;;
esac

. $TOP/test.sh

rm -vf out/modules.order

which smart || {
    echo "The \"smart\" command is not found in PATH"
} && {
    true #test-load-precondition-scripts $TOP
} && {
    #rm -rf out
    #(smart && smart doc) || {
    #smart && test-load-check-scripts $TOP
    test-case $TOP
} || {
    echo ${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]} "FAILED"
}
