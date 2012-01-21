#!/bin/bash

function refact
{
    local D=$1
    for S in $D/* ; do
        local d=`dirname $S`
        case $S in
            */smart.mk|./main.mk)
                #echo "ignore: $S"
                ;;
            *.mk)
                local n=`basename $S .mk`
                mkdir -p $d/$n && {
                    git mv -f $S $d/$n/smart.mk
                } || {
                    echo ${BASH_SOURCE}:${LINENO} "error"
                    return -1
                }
                ;;
            *.pre)
                #local n=`basename $S .pre`
                #echo "stem: $*"
                ;;
            *-pre.sh)
                local n=`basename $S -pre.sh`
                mkdir -p $d/$n && {
                    git mv -f $S $d/$n/pre.sh
                } || {
                    echo ${BASH_SOURCE}:${LINENO} "error"
                    return -1
                }
                ;;
            *-post.sh)
                local n=`basename $S -post.sh`
                mkdir -p $d/$n && {
                    git mv -f $S $d/$n/post.sh
                } || {
                    echo ${BASH_SOURCE}:${LINENO} "error"
                    return -1
                }
                ;;
            *) [[ -d $S ]] && {
                    refact $S
                }
                ;;
        esac
    done
}

refact .
