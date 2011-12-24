# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/toolsets/android-sdk/NotePad/AndroidManifest.xml
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/toolsets/android-sdk/NotePad/sign.keystore
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/toolsets/android-sdk/NotePad/.keypass
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/toolsets/android-sdk/NotePad/.storepass
