#
#
#
#
$(call test-check-undefined,sm.this.sources)
$(call test-check-module-empty, sm.module.android-sdk-notepad)
$(call sm-new-module, android-sdk-notepad, android-sdk: apk PLATFORM=android-10)
$(call test-check-value-of,sm.this.sources,src/com/example/android/notepad/NoteEditor.java src/com/example/android/notepad/NotePad.java src/com/example/android/notepad/NotePadProvider.java src/com/example/android/notepad/NotesList.java src/com/example/android/notepad/NotesLiveFolder.java src/com/example/android/notepad/TitleEditor.java)

$(warning info: sources: $(sm.this.sources))

$(sm-build-this)
