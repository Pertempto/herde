import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../data/herde_user.dart';
import 'herd_management.dart';
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
            Text('Hello, ${user.name}!', style: textTheme.headline4, textAlign: TextAlign.center),
            ElevatedButton.icon(
              icon: const Icon(MdiIcons.accountCowboyHat),
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HerdSettings.create())),
              label: const Text('Create a Herd'),
            ),
            OutlinedButton.icon(
              icon: const Icon(MdiIcons.dotsGrid),
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HerdManagement())),
              label: const Text('Herd Management'),
            ),
          ],
        ),
      ),
    );
  }
}
