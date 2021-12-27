import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
      body: ListView(
        children: items.map((name) => ListTile(leading: Icon(icons[name]), title: Text(name))).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Random rand = Random();
          String name = icons.keys.toList()[rand.nextInt(icons.length)];
          setState(() {
            items.add(name);
          });
        },
        tooltip: 'Add Animal',
        child: const Icon(MdiIcons.plus),
      ),
    );
  }
}
