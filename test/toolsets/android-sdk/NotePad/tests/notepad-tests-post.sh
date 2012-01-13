# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/android-sdk/debug/android-sdk-notepad/res/com/example/android/notepad/R.java
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/android-sdk/debug/android-sdk-notepad/classes/com/example/android/notepad/NoteEditor.class
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/android-sdk/debug/android-sdk-notepad/classes/com/example/android/notepad/NotePad.class
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/android-sdk/debug/android-sdk-notepad/classes/com/example/android/notepad/NotePadProvider.class
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/android-sdk/debug/android-sdk-notepad/classes/com/example/android/notepad/NotesList.class
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/android-sdk/debug/android-sdk-notepad/classes/com/example/android/notepad/NotesLiveFolder.class
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/android-sdk/debug/android-sdk-notepad/classes/com/example/android/notepad/R.class
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/android-sdk/debug/android-sdk-notepad/classes/com/example/android/notepad/TitleEditor.class
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/android-sdk/debug/android-sdk-notepad/classes.list
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/android-sdk/debug/android-sdk-notepad/classes.dex
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/android-sdk/debug/android-sdk-notepad/unsigned.apk
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/android-sdk/debug/android-sdk-notepad/signed.apk

out=`jarsigner -verify $TOP/out/android-sdk/debug/android-sdk-notepad/signed.apk`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "jar verified."
