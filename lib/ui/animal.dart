import 'package:flutter/material.dart';
import 'package:herde/data/animal_manager.dart';
import 'package:herde/data/data_store.dart';
import 'package:herde/data/note.dart';
import 'package:herde/ui/category_icon.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../data/animal.dart';
import '../data/herd.dart';
import 'animal_settings.dart';
import 'type_icon.dart';

class AnimalScreen extends StatefulWidget {
  final String animalId;
  final String herdId;

  const AnimalScreen({required this.animalId, required this.herdId, Key? key}) : super(key: key);

  @override
  State<AnimalScreen> createState() => _AnimalScreenState();
}

class _AnimalScreenState extends State<AnimalScreen> {
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return DataStore.animalWidget(
        herdId: widget.herdId,
        animalId: widget.animalId,
        builder: (Herd? herd, Animal? animal) {
          List<Widget> children = [];
          if (animal != null) {
            children = [
              Text(animal.fullName, style: textTheme.headline4),
              const SizedBox(height: 12),
              TypeIcon(type: animal.type, showLabel: true),
              CategoryIcon(category: animal.category, showLabel: true),
              const SizedBox(height: 12),
              const Divider(),
              Row(
                children: [
                  Text('Notes', style: textTheme.headline6),
                  const Spacer(),
                  IconButton(icon: const Icon(MdiIcons.plus), onPressed: () => _addNote(animal, herd!)),
                ],
              ),
              ...animal.notes.values.toList().reversed.map((Note note) {
                String createdDateString = DateFormat.yMd().add_jms().format(note.createdTimestamp);
                String editedDateString = DateFormat.yMd().add_jms().format(note.editedTimestamp);
                return Card(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(createdDateString),
                            const Spacer(),
                            if (editedDateString != createdDateString) Text('(Edited: $editedDateString)'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(note.content, style: textTheme.subtitle1!.copyWith(fontSize: 20)),
                      ],
                    ),
                  ),
                );
              })
            ];
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text('Animal'),
              actions: [
                IconButton(
                  icon: const Icon(MdiIcons.pencil),
                  onPressed: () => _edit(animal!, herd!, context),
                )
              ],
            ),
            body: SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
            )),
          );
        });
  }

  /* Let the user edit the animal. */
  _edit(Animal animal, Herd herd, BuildContext context) async {
    Animal? newAnimal = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AnimalSettings(
              animal: animal,
              onDelete: () {
                AnimalManager.removeAnimal(herd, animal);
                Navigator.of(context).pop();
              })),
    );
    if (newAnimal != null) {
      AnimalManager.updateAnimal(herd, newAnimal);
    }
  }

  /* Let the user add a note. */
  _addNote(Animal animal, Herd herd) {
    TextEditingController textFieldController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add note'),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          content: TextField(
            autofocus: true,
            minLines: 3,
            maxLines: null,
            controller: textFieldController,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                String content = textFieldController.value.text.trim();
                if (content.isEmpty) {
                  return;
                }
                DateTime now = DateTime.now();
                Note note = Note(id: '', createdTimestamp: now, editedTimestamp: now, content: content);
                AnimalManager.addNote(herd, animal, note);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
