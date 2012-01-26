function test-log
{
    true #echo "$1:$2: $3"
}

function test-check-file
{
    #local loc=${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]}
    local loc=$1
    local fn=$2
    [[ -f $fn ]] || ( echo "$loc: missing \"$fn\"" && exit -1 )
}

function test-check-value
{
    local loc=$1
    local lhs=$2
    local rhs=$3
    [[ "x$lhs" == "x$rhs" ]] || ( echo "$loc: \"$lhs\" != \"$rhs\"" && exit -1 )
}

function test-check-value-contains
{
    local loc=$1
    local lhs=$2
    local rhs=$3
    local sub=`echo "$lhs" | grep -e "$rhs"`
    [[ "x$sub" != "x" ]] || ( echo "$loc: \"$lhs\" !contains \"$rhs\"" && exit -1 )
}

function test-load-scripts-recursively
{
    local T=$1
    local D=$2
    local S
    for S in $D/smart.mk ; do
        #S=$D/`basename $S .mk`-$T.sh
        S=`dirname $S`/$T.sh
        #echo ${BASH_SOURCE}:${LINENO}: $S
        [[ -f $S ]] && {
            test-log ${BASH_SOURCE}:${LINENO} info "check \"`basename $S -$T.sh`\".."
            . $S
        }
    done

    GLOBIGNORE=$TOP/out
    for S in $D/* ; do
        [[ -d $S ]] && {
            test-log ${BASH_SOURCE}:${LINENO} info "in $S"
            test-load-scripts-recursively $T $S
        }
    done
    GLOBIGNORE=
}

function test-load-precondition-scripts
{
    local D=$1
    test-load-scripts-recursively pre $D
}

function test-load-check-scripts
{
    local D=$1
    test-load-scripts-recursively post $D
}

function test-case
{
    local D=$1
    local S
    for S in $D/*; do
        case $S in
            */smart.mk)
                echo "test:========================================"
                OLD_TOP=$TOP
                ( # launch in subshell
                    TOP=$* && cd $* && {
                        echo "test: Entering directory \`$*'"
                        [[ -f pre.sh ]] && {
                            . pre.sh
                        }
                        rm -rf out ; smart
                        [[ -f post.sh ]] && {
                            . post.sh
                        }
                        echo "test: Leaving directory \`$*'"
                    }
                )
                TOP=$OLD_TOP
                ;;
            *)
                #echo "\"$*\", $S"
                [[ -d $S ]] && test-case $S
                ;;
        esac
    done
}

function test-readfile
{
    local F=$1
    [[ -f $F ]] && {
        cat $F
    }
}
