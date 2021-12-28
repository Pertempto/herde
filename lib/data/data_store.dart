import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

import 'animal.dart';
import 'herd.dart';
import 'herde_user.dart';

class DataStore {
  static CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  static CollectionReference herdsCollection = FirebaseFirestore.instance.collection('herds');

  static Query<Object?> userQuery() => usersCollection.where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid);

  static Query<Object?> herdQuery(String herdId) => herdsCollection.where('id', isEqualTo: herdId);

  static createUser({required User user}) {
    String email = user.email ?? '';
    String name = 'New User';
    if (email.split('@').isNotEmpty) {
      name = email.split('@').first;
    }
    HerdeUser herdeUser = HerdeUser(uid: user.uid, name: name);
    usersCollection.doc(user.uid).set(herdeUser.toJson());
  }

  static createHerd({required String ownerId, required String name, required String type}) {
    DocumentReference doc = herdsCollection.doc();
    Herd herd = Herd(id: doc.id, ownerId: ownerId, name: name, type: type);
    doc.set(herd.toJson());
    usersCollection.doc(ownerId).update({'currentHerd': herd.id});
  }

  static updateHerd({required Herd herd}) {
    herdsCollection.doc(herd.id).set(herd.toJson());
  }

  static deleteHerd(String herdId) {
    herdsCollection.doc(herdId).delete();
  }

  static FirestoreQueryBuilder firestoreWidget(
      {required Query<Object?> query, required Function(Map<String, dynamic>?) builder}) {
    return FirestoreQueryBuilder<Object?>(
      query: query,
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong! ${snapshot.error}'));
        }
        if (snapshot.docs.isEmpty) {
          return builder(null);
        }
        return builder(snapshot.docs.first.data() as Map<String, dynamic>);
      },
    );
  }

  static FirestoreQueryBuilder userWidget({required Function(HerdeUser) builder}) {
    return firestoreWidget(
      query: userQuery(),
      builder: (data) {
        if (data == null) {
          createUser(user: FirebaseAuth.instance.currentUser!);
          return const Center(child: Text('Setting up account...'));
        }
        HerdeUser user = HerdeUser.fromJson(data);
        return builder(user);
      },
    );
  }

  static FirestoreQueryBuilder herdWidget({required String herdId, required Function(Herd?) builder}) {
    return firestoreWidget(
      query: herdQuery(herdId),
      builder: (data) {
        if (data == null) {
          return builder(null);
        }
        Herd herd = Herd.fromJson(data);
        return builder(herd);
      },
    );
  }

  static FirestoreQueryBuilder animalWidget(
      {required String herdId, required String animalId, required Function(Herd?, Animal?) builder}) {
    return firestoreWidget(
      query: herdQuery(herdId),
      builder: (data) {
        if (data == null) {
          return builder(null, null);
        }
        Herd herd = Herd.fromJson(data);
        return builder(herd, herd.animals[animalId]);
      },
    );
  }

  static setUserName(String name) {
    String id = FirebaseAuth.instance.currentUser!.uid;
    usersCollection.doc(id).update({'name': name});
  }

  static setCurrentHerd(String currentHerd) {
    String id = FirebaseAuth.instance.currentUser!.uid;
    usersCollection.doc(id).update({'currentHerd': currentHerd});
  }
}
