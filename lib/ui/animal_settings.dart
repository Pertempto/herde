import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:herde/data/animal.dart';
import 'package:herde/data/data_store.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'category_icon.dart';
import 'category_selector.dart';
import 'list_item.dart';

class AnimalSettings extends StatefulWidget {
  final Animal? animal;
  final String? type;
  final VoidCallback? onDelete;

  const AnimalSettings({this.animal, this.type, this.onDelete, Key? key}) : super(key: key);

  @override
  State<AnimalSettings> createState() => _AnimalSettingsState();
}

class _AnimalSettingsState extends State<AnimalSettings> {
  late Animal? animal = widget.animal;
  int tagNumber = -1;
  String name = '';
  String type = '';
  String category = '';

  bool get isNew => animal == null;

  bool get isValid => (tagNumber != -1 || name.isNotEmpty) && category.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (animal == null) {
      type = widget.type ?? 'Goat';
    } else {
      tagNumber = animal!.tagNumber;
      name = animal!.name;
      type = animal!.type;
      category = animal!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DataStore.userWidget(builder: (user) {
      Widget body = ListView(
        children: [
          ListItem(
              title: 'Tag Number',
              value: tagNumber == -1 ? '' : tagNumber.toString(),
              onTap: () => setState(() => _editTagNumber(context))),
          ListItem(title: 'Name', value: name, onTap: () => _editName(context)),
          ListItem(
            title: 'Category',
            trailing: CategoryIcon(category: category, showLabel: true),
            onTap: () => _editCategory(context),
          ),
          if (!isNew)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: OutlinedButton.icon(
                icon: const Icon(MdiIcons.delete),
                label: const Text('Delete Animal'),
                onPressed: _delete,
                style: OutlinedButton.styleFrom(primary: Colors.red),
              ),
            ),
        ],
      );
      return Scaffold(
        appBar: AppBar(title: Text(isNew ? 'Add Animal' : 'Edit Animal'), actions: [
          if (isValid)
            IconButton(
              onPressed: () {
                Navigator.of(context).pop(Animal(tagNumber: tagNumber, name: name, type: type, category: category));
              },
              icon: const Icon(MdiIcons.check),
              tooltip: isNew ? 'Add Animal' : 'Save Animal',
            ),
        ]),
        body: body,
      );
    });
  }

  /* Allow the user to edit the animal tag number. */
  _editTagNumber(BuildContext context) {
    TextEditingController textFieldController =
        TextEditingController(text: tagNumber == -1 ? '' : tagNumber.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Tag Number'),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Text('Tag Number:'),
              ),
              Expanded(
                child: TextField(
                  autofocus: true,
                  controller: textFieldController,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'\d'))],
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            if (name.isNotEmpty)
              TextButton(
                child: const Text('None'),
                onPressed: () {
                  setState(() {
                    tagNumber = -1;
                    Navigator.pop(context);
                  });
                },
              ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                String value = textFieldController.value.text.trim();
                int newTagNumber = value.isEmpty ? -1 : int.parse(value);
                // the animal must have a tag number or a name, they can't both be empty
                if (newTagNumber == -1 && name.isEmpty) {
                  return;
                }
                setState(() {
                  tagNumber = newTagNumber;
                  Navigator.pop(context);
                });
              },
            ),
          ],
        );
      },
    );
  }

  /* Allow the user to edit the animal name. */
  _editName(BuildContext context) {
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
            if (tagNumber != -1)
              TextButton(
                child: const Text('None'),
                onPressed: () {
                  setState(() {
                    name = '';
                    Navigator.pop(context);
                  });
                },
              ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                String newName = textFieldController.value.text.trim();
                // the animal must have a tag number or a name, they can't both be empty
                if (newName.isEmpty && tagNumber == -1) {
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

  /* Allow the user to edit the category of the animal. */
  _editCategory(BuildContext context) async {
    String? newCategory = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategorySelector(type: type)),
    );
    if (newCategory != null) {
      setState(() {
        category = newCategory;
      });
    }
  }

  /* Allow the user to delete the animal. */
  _delete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Animal'),
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
                Navigator.pop(context);
                Navigator.pop(context);
                if (widget.onDelete != null) {
                  widget.onDelete!();
                }
              },
              style: TextButton.styleFrom(primary: Colors.red),
            ),
          ],
        );
      },
    );
  }
}
