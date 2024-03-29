import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../data/animal.dart';
import '../data/category.dart';
import '../data/data_store.dart';
import '../data/herd.dart';
import '../data/herde_user.dart';
import 'category_icon.dart';
import 'category_selector.dart';
import 'list_item.dart';
import 'loading.dart';
import 'parent_selector.dart';

class AnimalSettings extends StatefulWidget {
  final Animal animal;
  final String herdId;
  final VoidCallback? onDelete;

  const AnimalSettings({required this.animal, required this.herdId, this.onDelete, Key? key}) : super(key: key);

  @override
  State<AnimalSettings> createState() => _AnimalSettingsState();
}

class _AnimalSettingsState extends State<AnimalSettings> {
  late Animal animal = widget.animal;

  bool get isNew => animal.id.isEmpty;

  bool get isValid => (animal.tagNumber != -1 || animal.name.isNotEmpty) && animal.categoryName.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return DataStore.userWidget(builder: (HerdeUser? user, bool isLoading) {
      if (user == null || isLoading) {
        return const Loading();
      }
      Widget body = ListView(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            width: double.infinity,
            child: const Text('Tap to edit, press and hold to clear.', textAlign: TextAlign.center),
          ),
          ListItem(
            title: 'Tag Number',
            value: animal.tagNumber == -1 ? '' : animal.tagNumber.toString(),
            onTap: () => setState(() => _editTagNumber(context)),
            onLongPress: () => setState(() => animal = animal.copyWith(tagNumber: -1)),
          ),
          ListItem(
            title: 'Name',
            value: animal.name.isEmpty ? 'None' : animal.name,
            onTap: () => _editName(context),
            onLongPress: () => setState(() => animal = animal.copyWith(name: '')),
          ),
          ListItem(
            title: 'Category',
            trailing: CategoryIcon(typeName: animal.typeName, categoryName: animal.categoryName, showLabel: true),
            onTap: () => _editCategory(context),
            onLongPress: () => setState(() => animal = animal.copyWith(categoryName: '')),
          ),
          ListItem(
            title: 'Birth Date',
            value: animal.birthDateString,
            onTap: () => _editBirthDate(context),
            onLongPress: () => setState(() => animal = animal.copyWith(birthDate: null)),
          ),
          DataStore.animalWidget(
              herdId: widget.herdId,
              animalId: animal.fatherId,
              builder: (herd, father, isLoading) {
                return ListItem(
                  title: 'Father',
                  value: father?.fullName ?? 'Unknown',
                  onTap: () => _editParent(Parent.father, herd!, context),
                  onLongPress: () => setState(() => animal = animal.copyWith(fatherId: null)),
                );
              }),
          DataStore.animalWidget(
              herdId: widget.herdId,
              animalId: animal.motherId,
              builder: (herd, mother, isLoading) {
                return ListItem(
                  title: 'Mother',
                  value: mother?.fullName ?? 'Unknown',
                  onTap: () => _editParent(Parent.mother, herd!, context),
                  onLongPress: () => setState(() => animal = animal.copyWith(motherId: null)),
                );
              }),
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
                Navigator.of(context).pop(animal);
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
        TextEditingController(text: animal.tagNumber == -1 ? '' : animal.tagNumber.toString());
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
            if (animal.name.isNotEmpty)
              TextButton(
                child: const Text('None'),
                onPressed: () {
                  setState(() {
                    animal = animal.copyWith(tagNumber: -1);
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
                if (newTagNumber == -1 && animal.name.isEmpty) {
                  return;
                }
                setState(() {
                  animal = animal.copyWith(tagNumber: newTagNumber);
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
    TextEditingController textFieldController = TextEditingController(text: animal.name);
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
            if (animal.tagNumber != -1)
              TextButton(
                child: const Text('None'),
                onPressed: () {
                  setState(() {
                    animal = animal.copyWith(name: '');
                    Navigator.pop(context);
                  });
                },
              ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                String newName = textFieldController.value.text.trim();
                // the animal must have a tag number or a name, they can't both be empty
                if (newName.isEmpty && animal.tagNumber == -1) {
                  return;
                }
                setState(() {
                  animal = animal.copyWith(name: newName);
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
      MaterialPageRoute(builder: (context) => CategorySelector(typeName: animal.typeName)),
    );
    if (newCategory != null) {
      setState(() {
        animal = animal.copyWith(categoryName: newCategory);
      });
    }
  }

  /* Allow the user to edit the birth date of the animal. */
  _editBirthDate(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: animal.birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    ).then((value) {
      if (value != null) {
        setState(() => animal = animal.copyWith(birthDate: value));
      }
    });
  }

  /* Allow the user to edit a parent of the animal. */
  _editParent(Parent parent, Herd herd, BuildContext context) async {
    Iterable<String> treeMembers = herd.getDescendentTree(animal).allMembers.map((a) => a.id);
    String? newParentId = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ParentSelector(
              parent: parent,
              herd: herd,
              filterFunction: (other) {
                if (treeMembers.contains(other.id)) {
                  // Descendants can not be the parent of this animal.
                  return false;
                }
                if (animal.birthDate != null && other.birthDate != null) {
                  // A potential parent must be older than this animal.
                  return other.birthDate!.isBefore(animal.birthDate!);
                }
                return true;
              })),
    );
    if (newParentId != null) {
      setState(() {
        if (parent == Parent.father) {
          animal = animal.copyWith(fatherId: newParentId);
        } else if (parent == Parent.mother) {
          animal = animal.copyWith(motherId: newParentId);
        }
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
