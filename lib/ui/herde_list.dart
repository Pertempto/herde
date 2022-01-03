import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../data/animal.dart';
import '../data/animal_manager.dart';
import '../data/category.dart';
import '../data/data_store.dart';
import '../data/herd.dart';
import '../data/herde_user.dart';
import '../shared/sort_filter.dart';
import 'animal_details.dart';
import 'animal_overview.dart';
import 'animal_settings.dart';
import 'category_icon.dart';
import 'category_selector.dart';
import 'family_tree.dart';
import 'herd_settings.dart';
import 'list_item.dart';
import 'parent_selector.dart';
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
  SortFilter sortFilter = SortFilter();

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
          List<Animal> animals = sortFilter.process(herd);

          return Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  title: Text(herd.name),
                  leading: TypeIcon(type: herd.type, onPrimary: true),
                  actions: [
                    IconButton(
                      icon: const Icon(MdiIcons.cog),
                      onPressed: () =>
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const Settings())),
                      tooltip: 'Settings',
                    )
                  ],
                ),
                body: Column(
                  verticalDirection: VerticalDirection.up,
                  children: [
                    Material(
                      elevation: 2,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(MdiIcons.pencil),
                              onPressed: () {
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => HerdSettings(herdId: herd.id)));
                              },
                              label: const Text('Edit'),
                            ),
                            TextButton.icon(
                              icon: const Icon(MdiIcons.familyTree),
                              onPressed: () {
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => FamilyTree(herdId: herd.id)));
                              },
                              label: const Text('Family Tree'),
                            ),
                            TextButton.icon(
                              icon: const Icon(MdiIcons.sort),
                              onPressed: () => _selectSortField(herd: herd),
                              label: Text(sortFilter.sortFieldName),
                            ),
                            TextButton.icon(
                              icon: const Icon(MdiIcons.filterVariant),
                              onPressed: () => _selectFilter(herd: herd),
                              label: Text(sortFilter.getFilterString(herd)),
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
                              List<String> parents = [];
                              if (herd.animals[animal.fatherId] != null) {
                                parents.add(herd.animals[animal.fatherId]!.fullName);
                              } else {
                                parents.add('');
                              }
                              if (herd.animals[animal.motherId] != null) {
                                parents.add(herd.animals[animal.motherId]!.fullName);
                              } else {
                                parents.add('');
                              }
                              String parentString = 'Unknown';
                              if (parents[0].isNotEmpty && parents[1].isNotEmpty) {
                                parentString = 'Parents: ' + parents.join(' & ');
                              } else if (parents[0].isNotEmpty) {
                                parentString = 'Father: ${parents[0]}';
                              } else if (parents[1].isNotEmpty) {
                                parentString = 'Mother: ${parents[1]}';
                              }
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
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            CategoryIcon(typeName: animal.typeName, categoryName: animal.categoryName),
                                            const SizedBox(width: 8),
                                            Text(animal.fullName, style: textTheme.headline5),
                                            const Spacer(),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                if (parentString.isNotEmpty) Text('$parentString'),
                                                if (animal.birthDate != null) Text('Age: ${animal.ageString}')
                                              ],
                                            ),
                                          ],
                                        ),
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
                            builder: (context) => AnimalSettings(
                                  animal: Animal(id: '', name: '', typeName: herd.type),
                                  herdId: herd.id,
                                )));
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
  _selectSortField({required Herd herd}) async {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(builder: (context, innerSetState) {
            return Container(
              color: colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text('Sort', style: textTheme.headline5),
                      ),
                      ListItem(
                        title: 'Sort By',
                        trailing: DropdownButton(
                          value: sortFilter.sortField,
                          onChanged: (Field? value) => innerSetState(() => sortFilter.sortField = value!),
                          items: sortFilter.sortFields
                              .map((s) => DropdownMenuItem(value: s, child: Text(SortFilter.fieldName(s))))
                              .toList(),
                        ),
                      ),
                      ListItem(
                        title: 'Ascending',
                        trailing: Switch(
                          value: sortFilter.ascendingSort,
                          onChanged: (value) => innerSetState(() => sortFilter.ascendingSort = value),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ],
              ),
            );
          });
        }).then((value) => setState(() {})); // update the parent widget
  }

  /* Allow the user to set the filter. */
  _selectFilter({required Herd herd}) async {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(builder: (context, innerSetState) {
            _editParent(Parent parent) async {
              String? newParentId = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ParentSelector(parent: parent, herd: herd)),
              );
              if (newParentId != null) {
                innerSetState(() => sortFilter.filterValue = newParentId);
              }
            }

            Widget filterValueWidget = Container(width: 0);
            VoidCallback? editFilterValue;

            if (sortFilter.filterField == Field.category) {
              filterValueWidget = CategoryIcon(
                typeName: herd.type,
                categoryName: sortFilter.filterValue ?? '',
                showLabel: true,
              );
              editFilterValue = () async {
                String? newCategoryName = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategorySelector(typeName: herd.type)),
                );
                if (newCategoryName != null) {
                  innerSetState(() => sortFilter.filterValue = newCategoryName);
                }
              };
            } else if (sortFilter.filterField == Field.father) {
              filterValueWidget = DataStore.animalWidget(
                  herdId: herd.id,
                  animalId: sortFilter.filterValue,
                  builder: (herd, animal) {
                    return Text(animal?.fullName ?? '',
                        style: textTheme.headline6!.copyWith(fontWeight: FontWeight.w400));
                  });
              editFilterValue = () => _editParent(Parent.father);
            } else if (sortFilter.filterField == Field.mother) {
              filterValueWidget = DataStore.animalWidget(
                  herdId: herd.id,
                  animalId: sortFilter.filterValue,
                  builder: (herd, animal) {
                    return Text(animal?.fullName ?? '',
                        style: textTheme.headline6!.copyWith(fontWeight: FontWeight.w400));
                  });
              editFilterValue = () => _editParent(Parent.mother);
            }
            return Container(
              color: colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text('Filter', style: textTheme.headline5),
                      ),
                      ListItem(
                        title: 'Field',
                        trailing: DropdownButton(
                          value: sortFilter.filterField,
                          onChanged: (Field? value) {
                            if (value != null) {
                              innerSetState(() {
                                sortFilter.filterField = value;
                                sortFilter.filterValue = null;
                              });
                            }
                          },
                          items: sortFilter.filterFields
                              .map((s) => DropdownMenuItem(value: s, child: Text(SortFilter.fieldName(s))))
                              .toList(),
                        ),
                        onLongPress: () => innerSetState(() => sortFilter.filterField = Field.none),
                      ),
                      ListItem(
                        title: 'Value',
                        trailing: filterValueWidget,
                        onTap: editFilterValue,
                        onLongPress: () => innerSetState(() => sortFilter.filterValue = null),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        width: double.infinity,
                        child: const Text('Tap to edit the filter value, press and hold to clear.',
                            textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ],
              ),
            );
          });
        }).then((value) => setState(() {})); // update the parent widget
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimalOverview(animalId: animal.id, herdId: herd.id),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                  child: ButtonBar(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          Animal? newAnimal = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AnimalSettings(
                                    animal: animal,
                                    herdId: herd.id,
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
                ),
              ],
            ),
          );
        });
  }
}
