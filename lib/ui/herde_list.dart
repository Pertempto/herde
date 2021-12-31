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
import 'animal.dart';
import 'animal_overview.dart';
import 'animal_settings.dart';
import 'category_icon.dart';
import 'herd_settings.dart';
import 'settings.dart';
import 'type_icon.dart';

class HerdeList extends StatefulWidget {
  final HerdeUser user;

  const HerdeList({required this.user, Key? key}) : super(key: key);

  @override
  State<HerdeList> createState() => _HerdeListState();
}

class _HerdeListState extends State<HerdeList> {
  late ConfettiController _confettiController;

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
          animals.sort((a, b) => a.fullName.compareTo(b.fullName));
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
                        padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TypeIcon(type: herd.type),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(MdiIcons.pencil),
                              onPressed: () {
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => HerdSettings(herdId: herd.id)));
                              },
                              tooltip: 'Edit Herd',
                            ),
                            IconButton(
                              icon: const Icon(MdiIcons.sort),
                              onPressed: () {},
                              tooltip: 'Sort Animals',
                            ),
                            IconButton(
                              icon: const Icon(MdiIcons.filterVariant),
                              onPressed: () {},
                              tooltip: 'Filter Animals',
                            ),
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
                                      builder: (context) => AnimalScreen(animalId: animal.id, herdId: herd.id)),
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
                        context, MaterialPageRoute(builder: (context) => AnimalSettings(type: herd.type)));
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
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => AnimalSettings(animal: animal)));
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
                                builder: (context) => AnimalScreen(animalId: animal.id, herdId: herd.id)));
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
