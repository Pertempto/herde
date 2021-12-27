import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../data/data_store.dart';
import '../data/herde_user.dart';
import 'animal_icon.dart';
import 'herd_settings.dart';
import 'settings.dart';

class HerdeList extends StatefulWidget {
  final HerdeUser user;

  const HerdeList({required this.user, Key? key}) : super(key: key);

  @override
  State<HerdeList> createState() => _HerdeListState();
}

class _HerdeListState extends State<HerdeList> {
  late int numFakeGoats = 0;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Herde'), actions: [
        IconButton(
          icon: const Icon(MdiIcons.cog),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Settings())),
          tooltip: 'Settings',
        )
      ]),
      body: DataStore.herdWidget(
        herdId: widget.user.currentHerd,
        builder: (herd) {
          if (herd == null) {
            DataStore.setCurrentHerd('');
            return Container();
          } else {
            return Column(
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
                        AnimalIcon(type: herd.type),
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
                        children: List.generate(numFakeGoats, (int index) {
                          String name = ["Clyde", "Bell", "Abby", "Fred"][index % 4];
                          Widget wetherIcon = const Tooltip(
                            message: 'Wether',
                            child: Icon(MdiIcons.circleMedium, color: Colors.green),
                          );
                          Widget doeIcon = const Tooltip(
                            message: 'Doe',
                            child: Icon(MdiIcons.plus, color: Colors.pink),
                          );
                          Widget billyIcon = const Tooltip(
                            message: 'Billy',
                            child: Icon(MdiIcons.multiplication, color: Colors.blue),
                          );
                          Widget categoryIcon = [wetherIcon, doeIcon, doeIcon, billyIcon][index % 4];
                          return Card(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text('#${index + 1} - $name', style: textTheme.headline6),
                                  const Spacer(),
                                  categoryIcon,
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ].reversed.toList(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(MdiIcons.plus),
        onPressed: () => setState(() => numFakeGoats++),
      ),
    );
  }
}
