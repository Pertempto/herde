import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'firebase_options.dart';
import 'herde_icons.dart';

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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, IconData> icons = {
    'Cowboy': MdiIcons.accountCowboyHat,
    'Cow': HerdeIcons.cow,
    'Goat': HerdeIcons.goat,
    'Cat': HerdeIcons.cat
  };
  late List<String> items = icons.keys.toList();

  @override
  Widget build(BuildContext context) {
    print(items);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Herde'),
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
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
