# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-flags-in-file-inters/toolsets/gcc/features/main.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-flags-in-file-inters/toolsets/gcc/features/main.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/temp/feature-flags-in-file-inters/flags.intermediates.link.0

out=`test-readfile out/gcc/debug/temp/feature-flags-in-file-inters/flags.intermediates.link.0`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "out/gcc/debug/intermediates/feature-flags-in-file-inters/toolsets/gcc/features/main.c.o"
