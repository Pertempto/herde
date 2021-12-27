import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../data/data_store.dart';
import '../data/herde_user.dart';
import '../herde_icons.dart';
import 'settings.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, IconData> icons = {
    'Cowboy': MdiIcons.accountCowboyHat,
    'Cow': HerdeIcons.cow,
    'Goat': HerdeIcons.goat,
    'Cat': HerdeIcons.cat
  };
  late List<String> items = icons.keys.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Herde'),
        actions: [
          IconButton(
            icon: const Icon(MdiIcons.cog),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Settings())),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: DataStore.userWidget(
        builder: (HerdeUser user) {
          return Center(child: Text('Hello, ${user.name}!', style: Theme.of(context).textTheme.headline3!));
        },
      ),
    );
  }
}
