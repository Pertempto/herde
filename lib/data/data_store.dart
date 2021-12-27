import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

import 'herde_user.dart';

class DataStore {
  static CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  static Query<Object?> userQuery() => usersCollection.where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid);

  static createUser({required User user}) {
    String email = user.email ?? '';
    String name = 'New User';
    if (email.split('@').isNotEmpty) {
      name = email.split('@').first;
    }
    HerdeUser herdeUser = HerdeUser(uid: user.uid, name: name);
    usersCollection.doc(user.uid).set(herdeUser.toJson());
  }

  static FirestoreQueryBuilder userWidget({required Function(HerdeUser) builder}) {
    return FirestoreQueryBuilder<Object?>(
      query: DataStore.userQuery(),
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong! ${snapshot.error}'));
        }
        if (snapshot.docs.isEmpty) {
          createUser(user: FirebaseAuth.instance.currentUser!);
          return const Center(child: Text('Setting up account...'));
        }
        HerdeUser user = HerdeUser.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
        return builder(user);
      },
    );
  }

  static setUserName(String name) {
    String id = FirebaseAuth.instance.currentUser!.uid;
    usersCollection.doc(id).update({'name': name});
  }
}
