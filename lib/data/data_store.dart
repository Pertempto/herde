import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

import 'herde_user.dart';

class DataStore {
  static CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  static Query<Object?> userQuery() => usersCollection.where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid);

  static createUser({required String uid, required String name}) {
    HerdeUser user = HerdeUser(uid: uid, name: name);
    usersCollection.doc(uid).set(user.toJson());
  }

  static FirestoreQueryBuilder userWidget({required Function(HerdeUser) builder}) {
    return FirestoreQueryBuilder<Object?>(
      query: DataStore.userQuery(),
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong! ${snapshot.error}'));
        }
        if (snapshot.docs.isEmpty) {
          return const Center(child: Text('Something went wrong! User not found.'));
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
