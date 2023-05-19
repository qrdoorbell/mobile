#!/bin/sh

export APP_STORE_CONNECT_ISSUER_ID=e240ce47-7e4b-4eba-bb2d-308222a93e33
export APP_STORE_CONNECT_KEY_IDENTIFIER=97QJQFVG62
export APP_STORE_CONNECT_PRIVATE_KEY=`cat ../AuthKey_97QJQFVG62.p8`

flutter build ipa --dart-define=USE_CRASHALYTICS=true && ./ios/Pods/FirebaseCrashlytics/upload-symbols -gsp ios/Runner/GoogleService-Info.plist -p ios build/ios
