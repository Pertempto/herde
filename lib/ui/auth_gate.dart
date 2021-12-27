import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';

import 'home.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            headerMaxExtent: 250,
            headerBuilder: (context, constraints, _) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(child: Image.asset('assets/icon/herde.png')),
                  ],
                ),
              );
            },
            providerConfigs: const [EmailProviderConfiguration()],
          );
        }
        return const Home();
      },
    );
  }
}
