import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:herde/data/data_store.dart';
import 'package:herde/data/herd.dart';
import 'package:herde/ui/type_selector.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'animal_icon.dart';
import 'list_item.dart';

class HerdSettings extends StatefulWidget {
  final String herdId;

  const HerdSettings({required this.herdId, Key? key}) : super(key: key);

  @override
  State<HerdSettings> createState() => _HerdSettingsState();
}

class _HerdSettingsState extends State<HerdSettings> {
  late String herdId = widget.herdId;
  String name = '';
  String type = '';

  bool get isNew => herdId.isEmpty;

  @override
  void initState() {
    super.initState();
    if (isNew) {
      name = 'My Herd';
      type = 'Goat';
    } else {
      DataStore.herdQuery(herdId).get().then((value) {
        Herd herd = Herd.fromJson(value.docs.first.data() as Map<String, dynamic>);
        setState(() {
          name = herd.name;
          type = herd.type;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DataStore.userWidget(builder: (user) {
      Widget body = ListView(
        children: [
          ListItem(title: 'Name', value: name, onTap: () => setState(() => _editHerdName(context))),
          ListItem(
            title: 'Type',
            trailing: AnimalIcon(type: type, showLabel: true),
            onTap: () => setState(() => _editHerdType(context)),
          ),
          if (!isNew)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: OutlinedButton.icon(
                icon: const Icon(MdiIcons.delete),
                label: const Text('Delete Herd'),
                onPressed: _deleteHerd,
                style: OutlinedButton.styleFrom(primary: Colors.red),
              ),
            ),
        ],
      );
      return Scaffold(
        appBar: AppBar(title: Text(isNew ? 'Create Herd' : 'Edit Herd'), actions: [
          if (isNew)
            IconButton(
              onPressed: () {
                DataStore.createHerd(ownerId: user.uid, name: name, type: type);
                Navigator.of(context).pop();
              },
              icon: const Icon(MdiIcons.check),
              tooltip: 'Create Herd',
            ),
          if (!isNew)
            IconButton(
              onPressed: () {
                Herd herd = Herd(id: herdId, ownerId: user.uid, name: name, type: type);
                DataStore.updateHerd(herd: herd);
                Navigator.of(context).pop();
              },
              icon: const Icon(MdiIcons.check),
              tooltip: 'Save Herd',
            ),
        ]),
        body: body,
      );
    });
  }

  /* Allow the user to edit the herd name. */
  _editHerdName(BuildContext context) {
    TextEditingController textFieldController = TextEditingController(text: name);
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
                child: Text('Herd Name:'),
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
                String newName = textFieldController.value.text.trim();
                if (newName.isEmpty) {
                  return;
                }
                setState(() {
                  name = newName;
                  Navigator.pop(context);
                });
              },
            ),
          ],
        );
      },
    );
  }

  /* Allow the user to edit the herd name. */
  _editHerdType(BuildContext context) async {
    // TODO: don't allow changing the type if the herd contains animals.
    String newType = await Navigator.push(context, MaterialPageRoute(builder: (context) => const TypeSelector()));
    setState(() {
      type = newType;
    });
  }

  /* Allow the user to delete the herd. */
  _deleteHerd() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Herd'),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          content: const Text('Are you sure? This is permanent.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                DataStore.deleteHerd(herdId);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(primary: Colors.red),
            ),
          ],
        );
      },
    );
  }
}
