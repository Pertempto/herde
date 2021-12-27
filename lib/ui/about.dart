import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'list_item.dart';

class About extends StatefulWidget {
  const About({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AboutState();
}

class _AboutState extends State<About> {
  String appVersion = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((value) {
      setState(() {
        appVersion = 'v' + value.version;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const String iconCredits = '''
App Icon by Addison Emig
Goat by Laymik from NounProject.com
Cow by Laymik from NounProject.com
Egyptian Cat by Laymik from NounProject.com
''';
    Widget body = ListView(children: [
      const ListItem(title: 'Developed By', value: 'Addison Emig'),
      ListItem(title: 'App Version', value: appVersion),
      const ListItem(title: 'Icon Credits', subtitle: iconCredits),
    ]);
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: body,
    );
  }
}
