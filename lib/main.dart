import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'ui/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Herde',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xff466328),
          primaryVariant: Color(0xff34481e),
          secondary: Color(0xff323250),
          secondaryVariant: Color(0xff27273f),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
      ),
      home: const AuthGate(),
    );
  }
}
