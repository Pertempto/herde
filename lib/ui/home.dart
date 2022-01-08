import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../data/data_store.dart';
import '../data/herde_user.dart';
import 'empty_home.dart';
import 'herde_list.dart';
import 'loading.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return DataStore.userWidget(
      builder: (HerdeUser? user, isLoading) {
        if (user == null || isLoading) {
          return const Loading();
        }
        if (user.currentHerd.isEmpty) {
          return EmptyHome(user: user);
        } else {
          return HerdeList(user: user);
        }
      },
    );
  }
}
