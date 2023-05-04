#!/bin/sh

flutter build ipa --dart-define=USE_CRASHALYTICS=true && ./ios/Pods/FirebaseCrashlytics/upload-symbols -gsp ios/Runner/GoogleService-Info.plist -p ios build/ios