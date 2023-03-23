// ignore_for_file: constant_identifier_names

import 'package:firebase_core/firebase_core.dart';

const String GOOGLE_CLIENT_ID = "AIzaSyBVBruJnxt4zW0Eqlg7JtLVvotnSSiz8UI";

const bool USE_AUTH_EMULATOR = bool.fromEnvironment('USE_AUTH_EMULATOR', defaultValue: false);
const bool USE_DATABASE_MOCK = bool.fromEnvironment('USE_DATABASE_MOCK', defaultValue: false);
const bool USE_DATABASE_EMULATOR = bool.fromEnvironment('USE_DATABASE_EMULATOR', defaultValue: false);
const bool USE_CRASHALYTICS = bool.fromEnvironment('USE_CRASHALYTICS', defaultValue: false);

const FirebaseOptions WebFirebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyD1xqacoQ_f7Oh3ScC4KaoXuOiirF3PAzM",
    authDomain: "qrdoorbell-v1.firebaseapp.com",
    databaseURL: "https://qrdoorbell-v1-default-rtdb.europe-west1.firebasedatabase.app",
    projectId: "qrdoorbell-v1",
    storageBucket: "qrdoorbell-v1.appspot.com",
    messagingSenderId: "596595019913",
    appId: "1:596595019913:web:47d10b576c1737542ef658",
    measurementId: "G-BER8W6T7WE");
