import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../data/animal.dart';
import '../data/animal_manager.dart';
import '../data/data_store.dart';
import '../data/herd.dart';
import '../data/note.dart';
import 'animal_overview.dart';
import 'animal_settings.dart';

class AnimalDetails extends StatefulWidget {
  final String animalId;
  final String herdId;

  const AnimalDetails({required this.animalId, required this.herdId, Key? key}) : super(key: key);

  @override
  State<AnimalDetails> createState() => _AnimalDetailsState();
}

class _AnimalDetailsState extends State<AnimalDetails> {
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return DataStore.animalWidget(
        herdId: widget.herdId,
        animalId: widget.animalId,
        builder: (Herd? herd, Animal? animal) {
          List<Widget> children = [];

          if (animal != null) {
            List<Note> notes = animal.notes.values.toList();
            notes.sort((a, b) => -a.createdTimestamp.compareTo(b.createdTimestamp));
            children = [
              AnimalOverview(animalId: widget.animalId, herdId: widget.herdId),
              const SizedBox(height: 12),
              const Divider(),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text('Notes', style: textTheme.headline6),
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(MdiIcons.plus), onPressed: () => _addNote(animal, herd!)),
                ],
              ),
              ...notes.map((Note note) {
                String createdDateString = DateFormat.yMd().add_jm().format(note.createdTimestamp);
                String editedDateString = DateFormat.yMd().add_jm().format(note.editedTimestamp);
                bool wasEdited = note.editedTimestamp != note.createdTimestamp;
                return Builder(builder: (context) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _noteActions(note, animal, herd!, context),
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
                              ],
                            ),
                            if (wasEdited) Text('(Edited: $editedDateString)'),
                            const SizedBox(height: 4),
                            Text(note.content, style: textTheme.subtitle1!.copyWith(fontSize: 20)),
                          ],
                        ),
                      ),
                    ),
                  );
                });
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
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children)),
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
              herdId: herd.id,
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
          title: const Text('Add Note'),
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

  /* Show the note actions. */
  _noteActions(Note note, Animal animal, Herd herd, BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ButtonBar(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _editNote(note, animal, herd);
                      },
                      icon: const Icon(MdiIcons.pencil),
                      label: const Text('Edit'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteNote(note, animal, herd);
                      },
                      icon: const Icon(MdiIcons.delete),
                      label: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  /* Let the user edit a note. */
  _editNote(Note note, Animal animal, Herd herd) {
    TextEditingController textFieldController = TextEditingController(text: note.content);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Note'),
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
                AnimalManager.editNote(herd, animal, note.id, content);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  /* Let the user to delete a note. */
  _deleteNote(Note note, Animal animal, Herd herd) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Note'),
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
                AnimalManager.deleteNote(herd, animal, note.id);
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
