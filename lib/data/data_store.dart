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

  static Query<Object?> ownedHerdsQuery(String userId) => herdsCollection.where('ownerId', isEqualTo: userId);

  static Query<Object?> sharedHerdsQuery(String userId) => herdsCollection.where('userIds', arrayContains: userId);

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
    setCurrentHerd(herd.id);
  }

  static updateHerd({required Herd herd}) {
    herdsCollection.doc(herd.id).set(herd.toJson());
  }

  static deleteHerd(String herdId) {
    herdsCollection.doc(herdId).delete();
  }

  static FirestoreQueryBuilder firestoreFirstWidget(
      {required Query<Object?> query, required Function(Map<String, dynamic>?, bool) builder}) {
    return FirestoreQueryBuilder<Object?>(
      query: query,
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return builder(null, true);
        }
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong! ${snapshot.error}'));
        }
        if (snapshot.docs.isEmpty) {
          return builder(null, false);
        }
        return builder(snapshot.docs.first.data() as Map<String, dynamic>, false);
      },
    );
  }

  static FirestoreQueryBuilder firestoreAllWidget(
      {required Query<Object?> query,
      required Function(List<Map<String, dynamic>>?) builder,
      Function? loadingBuilder}) {
    return FirestoreQueryBuilder<Object?>(
      query: query,
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          if (loadingBuilder == null) {
            return const SizedBox(width: 0, height: 0);
          } else {
            return loadingBuilder();
          }
        }
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong! ${snapshot.error}'));
        }
        return builder(snapshot.docs.map((d) => d.data() as Map<String, dynamic>).toList());
      },
    );
  }

  static FirestoreQueryBuilder userWidget({required Function(HerdeUser?, bool) builder}) {
    return firestoreFirstWidget(
      query: userQuery(),
      builder: (data, isLoading) {
        if (data == null) {
          if (isLoading) {
            return builder(null, true);
          } else {
            createUser(user: FirebaseAuth.instance.currentUser!);
            return const Center(child: Text('Setting up account...'));
          }
        }
        HerdeUser user = HerdeUser.fromJson(data);
        return builder(user, isLoading);
      },
    );
  }

  static FirestoreQueryBuilder ownedHerdsWidget({required Function(Map<String, Herd>?) builder}) {
    return firestoreAllWidget(
      query: ownedHerdsQuery(FirebaseAuth.instance.currentUser!.uid),
      builder: (data) => builder(_dataToHerds(data)),
    );
  }

  static FirestoreQueryBuilder sharedHerdsWidget({required Function(Map<String, Herd>?) builder}) {
    return firestoreAllWidget(
      query: sharedHerdsQuery(FirebaseAuth.instance.currentUser!.uid),
      builder: (data) => builder(_dataToHerds(data)),
    );
  }

  static Map<String, Herd>? _dataToHerds(data) {
    if (data == null) {
      return null;
    }
    Map<String, Herd> herds = {};
    for (Map<String, dynamic> item in data) {
      Herd herd = Herd.fromJson(item);
      herds[herd.id] = herd;
    }
    return herds;
  }

  static FirestoreQueryBuilder herdWidget({
    required String herdId,
    required Function(Herd?, bool) builder,
  }) {
    return firestoreFirstWidget(
        query: herdQuery(herdId),
        builder: (data, isLoading) {
          if (isLoading) {
            return builder(null, true);
          } else if (data == null) {
            return builder(null, false);
          } else {
            return builder(Herd.fromJson(data), false);
          }
        });
  }

  static FirestoreQueryBuilder animalWidget(
      {required String herdId, required String? animalId, required Function(Herd?, Animal?, bool) builder}) {
    return firestoreFirstWidget(
      query: herdQuery(herdId),
      builder: (data, isLoading) {
        if (isLoading) {
          return builder(null, null, true);
        } else if (data == null) {
          return builder(null, null, false);
        }
        Herd herd = Herd.fromJson(data);
        return builder(herd, herd.animals[animalId], false);
      },
    );
  }

  static setUserName(String name) {
    String id = FirebaseAuth.instance.currentUser!.uid;
    usersCollection.doc(id).update({'name': name});
  }

  static Future setCurrentHerd(String currentHerdId) {
    String id = FirebaseAuth.instance.currentUser!.uid;
    return usersCollection.doc(id).update({'currentHerd': currentHerdId});
  }
}
