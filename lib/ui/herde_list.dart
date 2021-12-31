import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:herde/data/animal_manager.dart';
import 'package:herde/data/herd.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../data/animal.dart';
import '../data/data_store.dart';
import '../data/herde_user.dart';
import 'animal_details.dart';
import 'animal_overview.dart';
import 'animal_settings.dart';
import 'category_icon.dart';
import 'herd_settings.dart';
import 'settings.dart';
import 'type_icon.dart';

enum SortField {
  tagNumber,
  name,
  age,
}

String fieldName(SortField field) {
  switch (field) {
    case SortField.tagNumber:
      return 'Tag Number';
    case SortField.name:
      return 'Name';
    case SortField.age:
      return 'Age';
    default:
      return 'Unknown';
  }
}

class HerdeList extends StatefulWidget {
  final HerdeUser user;

  const HerdeList({required this.user, Key? key}) : super(key: key);

  @override
  State<HerdeList> createState() => _HerdeListState();
}

class _HerdeListState extends State<HerdeList> {
  late ConfettiController _confettiController;
  SortField sortField = SortField.age;
  bool ascendingSort = true;

  int Function(Animal, Animal) get sortFunction {
    Map map = {
      SortField.tagNumber: (Animal a, Animal b) {
        if (a.tagNumber == -1) return 1;
        if (b.tagNumber == -1) return -1;
        return a.tagNumber.compareTo(b.tagNumber) * sortFactor;
      },
      SortField.name: (Animal a, Animal b) {
        if (a.name.isEmpty) return 1;
        if (b.name.isEmpty) return -1;
        return a.name.compareTo(b.name) * sortFactor;
      },
      SortField.age: (Animal a, Animal b) {
        if (a.birthDate == null) return 1;
        if (b.birthDate == null) return -1;
        return -a.birthDate!.compareTo(b.birthDate!) * sortFactor;
      }
    };
    return map[sortField];
  }

  int get sortFactor => ascendingSort ? 1 : -1;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return DataStore.herdWidget(
        herdId: widget.user.currentHerd,
        builder: (herd) {
          if (herd == null) {
            DataStore.setCurrentHerd('');
            return Container();
          }
          List<Animal> animals = herd.animals.values.toList();
          animals.sort(sortFunction);
          return Stack(
            children: [
              Scaffold(
                appBar: AppBar(title: Text(herd.name), actions: [
                  IconButton(
                    icon: const Icon(MdiIcons.cog),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Settings())),
                    tooltip: 'Settings',
                  )
                ]),
                body: Column(
                  verticalDirection: VerticalDirection.up,
                  children: [
                    Material(
                      elevation: 2,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TypeIcon(type: herd.type),
                            const Spacer(),
                            TextButton.icon(
                              icon: const Icon(MdiIcons.pencil),
                              onPressed: () {
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => HerdSettings(herdId: herd.id)));
                              },
                              label: const Text('Edit'),
                            ),
                            TextButton.icon(
                              icon: const Icon(MdiIcons.sort),
                              onPressed: _selectSortField,
                              label: Text(fieldName(sortField)),
                            ),
                            // TODO: add filter feature
                            // IconButton(
                            //   icon: const Icon(MdiIcons.filterVariant),
                            //   onPressed: () {},
                            //   tooltip: 'Filter Animals',
                            // ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                          child: Column(
                            children: animals.map((Animal animal) {
                              return InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () => _previewAnimal(animal: animal, herd: herd),
                                onLongPress: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AnimalDetails(animalId: animal.id, herdId: herd.id)),
                                ),
                                child: Card(
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        CategoryIcon(category: animal.category),
                                        const SizedBox(width: 8),
                                        Text(animal.fullName, style: textTheme.headline6),
                                        const Spacer(),
                                        if (sortField == SortField.age)
                                          Text(animal.ageString, style: textTheme.headline6),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ].reversed.toList(),
                ),
                floatingActionButton: FloatingActionButton(
                  child: const Icon(MdiIcons.plus),
                  onPressed: () async {
                    Animal? animal = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AnimalSettings(animal: Animal(id: '', name: '', type: 'Goat', category: ''))));
                    if (animal != null) {
                      AnimalManager.addAnimal(herd, animal);
                      _confettiController.play();
                    }
                  },
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirection: 0.7 * pi,
                    emissionFrequency: 1,
                    numberOfParticles: 1,
                    maxBlastForce: 60,
                    minBlastForce: 10,
                    gravity: 0.1,
                    particleDrag: 0.07,
                    colors: [Theme.of(context).colorScheme.primary]),
              )
            ],
          );
        });
  }

  /* Allow the user to set the sort. */
  _selectSortField() {
    showDialog(
      context: context,
      builder: (context) {
        SortField? selectedField = sortField;
        bool selectAscendingSort = ascendingSort;
        return StatefulBuilder(builder: (context, innerSetState) {
          return AlertDialog(
            title: const Text('Sort'),
            contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Text('Field:'),
                    ),
                    const Spacer(),
                    DropdownButton(
                      value: selectedField,
                      onChanged: (SortField? value) {
                        innerSetState(() => selectedField = value);
                      },
                      items: SortField.values
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(fieldName(s)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Text('Ascending:'),
                    ),
                    const Spacer(),
                    Switch(
                      value: selectAscendingSort,
                      onChanged: (value) {
                        innerSetState(() => selectAscendingSort = value);
                      },
                    ),
                  ],
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
                  Navigator.of(context).pop();
                  if (selectedField != null) {
                    setState(() {
                      sortField = selectedField!;
                      ascendingSort = selectAscendingSort;
                    });
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  /* Show the Animal preview bottom sheet. */
  _previewAnimal({required Animal animal, required Herd herd}) async {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimalOverview(animalId: animal.id, herdId: herd.id),
                ButtonBar(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        Animal? newAnimal = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AnimalSettings(
                                  animal: animal,
                                  onDelete: () {
                                    AnimalManager.removeAnimal(herd, animal);
                                  })),
                        );
                        if (newAnimal != null) {
                          AnimalManager.updateAnimal(herd, newAnimal);
                        }
                      },
                      icon: const Icon(MdiIcons.pencil),
                      label: const Text('Edit'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AnimalDetails(animalId: animal.id, herdId: herd.id)));
                      },
                      icon: const Icon(MdiIcons.eye),
                      label: const Text('View'),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
