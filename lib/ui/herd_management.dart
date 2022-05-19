import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../data/data_store.dart';
import '../data/herd.dart';
import '../data/herde_user.dart';
import 'herd_settings.dart';
import 'list_item.dart';
import 'loading.dart';
import 'type_icon.dart';

class HerdManagement extends StatefulWidget {
  const HerdManagement({Key? key}) : super(key: key);

  @override
  _HerdManagementState createState() => _HerdManagementState();
}

class _HerdManagementState extends State<HerdManagement> {
  @override
  Widget build(BuildContext context) {
    return DataStore.userWidget(builder: (HerdeUser? user, bool isLoading) {
      if (user == null || isLoading) {
        return const Loading();
      }
      return Scaffold(
        appBar: AppBar(title: const Text('Herd Management')),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _currentHerdSection(user.currentHerd),
              DataStore.ownedHerdsWidget(builder: (herds) => _ownedHerdsSection(user, herds!)),
              DataStore.sharedHerdsWidget(builder: (herds) => _sharedHerdsSection(user, herds!)),
            ],
          ),
        ),
      );
    });
  }

  Widget _currentHerdSection(String herdId) {
    if (herdId.isEmpty) {
      return Container();
    }

    return DataStore.herdWidget(
        herdId: herdId,
        builder: (Herd? herd, bool isLoading) {
          if (herd == null && !isLoading) {
            return Container();
          }
          TextTheme textTheme = Theme.of(context).textTheme;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Current Herd', style: textTheme.headline5),
              ),
              ListItem(
                title: isLoading ? 'Loading...' : herd!.name,
                trailing: isLoading
                    ? null
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(herd!.animals.length.toString(), style: textTheme.headline6),
                          const SizedBox(width: 12),
                          TypeIcon(type: herd.type),
                        ],
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ButtonBar(
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(MdiIcons.pencil),
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => HerdSettings(herdId: herd!.id)),
                              );
                            },
                      label: const Text('Edit'),
                    ),
                  ],
                ),
              ),
              const Divider(),
            ],
          );
        });
  }

  Widget _ownedHerdsSection(HerdeUser user, Map<String, Herd> herds) {
    List<Herd> herdList = herds.values.toList();
    herdList.sort((a, b) => a.name.compareTo(b.name));

    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('My Herds', style: textTheme.headline5),
        ),
        ...herdList.map(_herdItem).toList(),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ButtonBar(
            children: [
              OutlinedButton.icon(
                icon: const Icon(MdiIcons.accountCowboyHat),
                onPressed: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HerdSettings.create())),
                label: const Text('Create a Herd'),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _sharedHerdsSection(HerdeUser user, Map<String, Herd> herds) {
    List<Herd> herdList = herds.values.toList();
    herdList.sort((a, b) => a.name.compareTo(b.name));

    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Shared Herds', style: textTheme.headline5),
        ),
        ...herdList.map(_herdItem).toList(),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ButtonBar(
            children: [
              OutlinedButton.icon(
                icon: const Icon(MdiIcons.accountGroup),
                onPressed: () => print('TODO: JOIN HERD'),
                label: const Text('Join a Herd'),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _herdItem(Herd herd) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return ListItem(
      title: herd.name,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(herd.animals.length.toString(), style: textTheme.headline6),
          const SizedBox(width: 12),
          TypeIcon(type: herd.type),
        ],
      ),
      onTap: () => DataStore.setCurrentHerd(herd.id).then((value) => setState(() {})),
    );
  }
}
