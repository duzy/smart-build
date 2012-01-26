# -*- bash -*-
#test-check-file ${BASH_SOURCE}:${LINENO} out/android-sdk/debug/android-sdk-notepad/res/com/example/android/notepad/R.java
test-check-file ${BASH_SOURCE}:${LINENO} out/android-sdk/debug/android-sdk-notepadtests/classes/com/example/android/notepad/NoteEditor.class
test-check-file ${BASH_SOURCE}:${LINENO} out/android-sdk/debug/android-sdk-notepadtests/classes/com/example/android/notepad/NotePad.class
test-check-file ${BASH_SOURCE}:${LINENO} out/android-sdk/debug/android-sdk-notepadtests/classes/com/example/android/notepad/NotePadProvider.class
test-check-file ${BASH_SOURCE}:${LINENO} out/android-sdk/debug/android-sdk-notepadtests/classes/com/example/android/notepad/NotesList.class
test-check-file ${BASH_SOURCE}:${LINENO} out/android-sdk/debug/android-sdk-notepadtests/classes/com/example/android/notepad/NotesLiveFolder.class
test-check-file ${BASH_SOURCE}:${LINENO} out/android-sdk/debug/android-sdk-notepadtests/classes/com/example/android/notepad/R.class
test-check-file ${BASH_SOURCE}:${LINENO} out/android-sdk/debug/android-sdk-notepadtests/classes/com/example/android/notepad/TitleEditor.class
test-check-file ${BASH_SOURCE}:${LINENO} out/android-sdk/debug/android-sdk-notepadtests/classes.list
test-check-file ${BASH_SOURCE}:${LINENO} out/android-sdk/debug/android-sdk-notepadtests/classes.dex
test-check-file ${BASH_SOURCE}:${LINENO} out/android-sdk/debug/android-sdk-notepadtests/unsigned.apk
test-check-file ${BASH_SOURCE}:${LINENO} out/android-sdk/debug/android-sdk-notepadtests/signed.apk

out=`jarsigner -verify out/android-sdk/debug/android-sdk-notepadtests/signed.apk`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "jar verified."

p=out/android-sdk/debug/android-sdk-notepadtests/classes/com/example/android/notepad
out=`cat out/android-sdk/debug/android-sdk-notepadtests/classes.list | sort`
out2=`ls $p | sed "s|^.*\$|$p/\0|" | sort`
[[ "x$?x" == "x0x" ]] || {
    echo "${BASH_SOURCE}:${LINENO}: failed to get class list ($?)"
}
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "$out2"
