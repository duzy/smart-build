# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} ../out/android-sdk/debug/android-sdk-notepad/res/com/example/android/notepad/R.java
test-check-file ${BASH_SOURCE}:${LINENO} ../AndroidManifest.xml
test-check-file ${BASH_SOURCE}:${LINENO} .keystore
test-check-file ${BASH_SOURCE}:${LINENO} .keypass
test-check-file ${BASH_SOURCE}:${LINENO} .storepass
