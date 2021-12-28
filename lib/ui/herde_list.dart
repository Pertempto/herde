import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:herde/data/animal_manager.dart';
import 'package:herde/data/herd.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../data/animal.dart';
import '../data/data_store.dart';
import '../data/herde_user.dart';
import 'animal.dart';
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
          return Scaffold(
            appBar: AppBar(title: const Text('Herde'), actions: [
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
                        Text(herd.name, style: textTheme.headline6),
                        const SizedBox(width: 16),
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
                        children: herd.animals.values.map((Animal animal) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => _goToAnimal(animal: animal, herd: herd),
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
                }
              },
            ),
          );
        });
  }

  _goToAnimal({required Animal animal, required Herd herd}) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AnimalScreen(animalId: animal.id, herdId: herd.id)));
  }
}
