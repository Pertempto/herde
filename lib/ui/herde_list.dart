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
import 'family_tree.dart';
import 'herd_settings.dart';
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
                                parents.add('Unknown');
                              }
                              if (herd.animals[animal.motherId] != null) {
                                parents.add(herd.animals[animal.motherId]!.fullName);
                              } else {
                                parents.add('Unknown');
                              }
                              String parentString = parents.join(' & ');
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
                                                if (parentString.isNotEmpty) Text('Parents: $parentString'),
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
  _selectSortField({required Herd herd}) {
    showDialog(
      context: context,
      builder: (context) {
        Field? selectedField = sortFilter.sortField;
        bool selectAscendingSort = sortFilter.ascendingSort;
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
                      onChanged: (Field? value) {
                        innerSetState(() => selectedField = value);
                      },
                      items: sortFilter.sortFields
                          .map((s) => DropdownMenuItem(value: s, child: Text(SortFilter.fieldName(s))))
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
                      sortFilter.sortField = selectedField!;
                      sortFilter.ascendingSort = selectAscendingSort;
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

  /* Allow the user to set the filter. */
  _selectFilter({required Herd herd}) async {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          Field filterField = sortFilter.filterField;
          String? filterValue = sortFilter.filterValue;
          return StatefulBuilder(builder: (context, innerSetState) {
            _editParent(Parent parent) async {
              String? newParentId = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ParentSelector(parent: parent, herd: herd)),
              );
              if (newParentId != null) {
                innerSetState(() {
                  filterValue = newParentId;
                });
              }
            }

            Widget filterValueWidget = Container();
            VoidCallback? editFilterValue;

            if (filterField == Field.category) {
              filterValueWidget = DataStore.animalWidget(
                  herdId: herd.id,
                  animalId: filterValue,
                  builder: (herd, animal) {
                    return Text(animal?.fullName ?? '',
                        style: textTheme.headline6!.copyWith(fontWeight: FontWeight.w400));
                  });
              editFilterValue = () => _editParent(Parent.father);
            } else if (filterField == Field.father) {
              filterValueWidget = DataStore.animalWidget(
                  herdId: herd.id,
                  animalId: filterValue,
                  builder: (herd, animal) {
                    return Text(animal?.fullName ?? '',
                        style: textTheme.headline6!.copyWith(fontWeight: FontWeight.w400));
                  });
              editFilterValue = () => _editParent(Parent.father);
            } else if (filterField == Field.mother) {
              filterValueWidget = DataStore.animalWidget(
                  herdId: herd.id,
                  animalId: filterValue,
                  builder: (herd, animal) {
                    return Text(animal?.fullName ?? '',
                        style: textTheme.headline6!.copyWith(fontWeight: FontWeight.w400));
                  });
              editFilterValue = () => _editParent(Parent.mother);
            }
            return Container(
              color: colorScheme.surface,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Filter', style: textTheme.headline5),
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Row(
                      children: <Widget>[
                        Text('Field:', style: textTheme.headline6),
                        const Spacer(),
                        DropdownButton(
                          value: filterField,
                          onChanged: (Field? value) {
                            if (value != null) {
                              innerSetState(() {
                                filterField = value;
                                filterValue = null;
                              });
                            }
                          },
                          items: sortFilter.filterFields
                              .map((s) => DropdownMenuItem(value: s, child: Text(SortFilter.fieldName(s))))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Row(
                      children: <Widget>[
                        Text('Value:', style: textTheme.headline6),
                        const Spacer(),
                        filterValueWidget,
                        if (filterValue != null)
                          IconButton(
                              onPressed: () => innerSetState(() => filterValue = null),
                              icon: const Icon(MdiIcons.close)),
                        if (editFilterValue != null)
                          IconButton(onPressed: editFilterValue, icon: const Icon(MdiIcons.pencil)),
                      ],
                    ),
                  ),
                  ButtonBar(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          setState(() {
                            sortFilter.filterField = Field.none;
                            sortFilter.filterValue = null;
                          });
                        },
                        icon: const Icon(MdiIcons.close),
                        label: const Text('Clear Filter'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            sortFilter.filterField = filterField;
                            sortFilter.filterValue = filterValue;
                          });
                        },
                        icon: const Icon(MdiIcons.filterVariant),
                        label: const Text('Filter'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          });
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
              ],
            ),
          );
        });
  }
}
