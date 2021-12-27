import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../data/data_store.dart';
import '../data/herde_user.dart';
import 'about.dart';
import 'list_item.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    Widget body = DataStore.userWidget(builder: (HerdeUser user) {
      return ListView(
        children: [
          ListItem(title: 'Name', value: user.name, onTap: () => _editUserName(user.name)),
        ],
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), actions: [
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const About())),
          icon: const Icon(MdiIcons.informationOutline),
          tooltip: 'About',
        ),
        IconButton(
          onPressed: () => FirebaseAuth.instance.signOut().then((value) => Navigator.of(context).pop()),
          icon: const Icon(MdiIcons.exitRun),
          tooltip: 'Sign Out',
        ),
      ]),
      body: body,
    );
  }

  /* Allow the user to edit their name. */
  _editUserName(String currentName) {
    TextEditingController textFieldController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Text('Name:'),
              ),
              Expanded(
                child: TextField(autofocus: true, controller: textFieldController),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                String name = textFieldController.value.text.trim();
                if (name.isEmpty) {
                  return;
                }
                Navigator.pop(context);
                DataStore.setUserName(name);
              },
            ),
          ],
        );
      },
    );
  }
}
