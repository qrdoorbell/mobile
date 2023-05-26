#!/bin/sh

flutter build ipa --dart-define=USE_CRASHALYTICS=true --dart-define=NEWRELIC_APP_TOKEN=eu01xx79f98fc731cd7778b793ed8af8a632bce3d0-NRMA --dart-define=GOOGLE_CLIENT_ID=AIzaSyBVBruJnxt4zW0Eqlg7JtLVvotnSSiz8UI && ./ios/Pods/FirebaseCrashlytics/upload-symbols -gsp ios/Runner/GoogleService-Info.plist -p ios build/ios