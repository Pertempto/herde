import 'package:firebase_auth/firebase_auth.dart';
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
              headerMaxExtent: 200,
              headerBuilder: (context, constraints, _) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Image.asset('assets/icon/herde.png'),
                );
              },
              providerConfigs: const [EmailProviderConfiguration()],
              actions: [AuthStateChangeAction<UserCreated>((context, state) {
                print("NEW USER: ${state.credential.user!.email} ${state.credential.user!.uid}");
              })
              ],
            );
          }
          User user = snapshot.data!;
          print("DATA: ${user.email} ${user.uid}");
          return const Home();
        });
  }
}
