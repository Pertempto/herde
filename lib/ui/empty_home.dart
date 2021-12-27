import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../data/herde_user.dart';
import '../herde_icons.dart';
import 'herd_settings.dart';
import 'settings.dart';

class EmptyHome extends StatelessWidget {
  final HerdeUser user;

  const EmptyHome({required this.user, Key? key}) : super(key: key);

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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hello, ${user.name}!', style: textTheme.headline4),
            ElevatedButton.icon(
              icon: const Icon(HerdeIcons.goat),
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HerdSettings(herdId: ''))),
              label: const Text('Create a Herd'),
            ),
          ],
        ),
      ),
    );
  }
}
