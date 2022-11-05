import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:muet_past_papers/screens/department_screen.dart';
import 'package:muet_past_papers/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: !kIsWeb
        ? null
        : const FirebaseOptions(
            apiKey: "AIzaSyCtEpeDs2j2xo5hUu00wYHF1MlyP43T-Eg",
            authDomain: "muet-past-papers.firebaseapp.com",
            projectId: "muet-past-papers",
            storageBucket: "muet-past-papers.appspot.com",
            messagingSenderId: "290616115106",
            appId: "1:290616115106:web:736ecfb0e4b2582383fcfb",
            measurementId: "G-32YF57KN2N",
          ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MUET Past Papers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
