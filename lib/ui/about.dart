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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Try tapping the app version!'),
        duration: Duration(milliseconds: 2000),
        behavior: SnackBarBehavior.floating,
      ));
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
      ListItem(title: 'App Version', value: appVersion, onTap: _easterEgg),
      const ListItem(title: 'Icon Credits', subtitle: iconCredits),
    ]);
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: body,
    );
  }

  _easterEgg() {
    String credit = '''
Special thanks to our beta testers:
- David Landes
- Ellie Boone
- Curtis Emig
- Jaden Emig''';
    showDialog(
      context: context,
      builder: (context) {
        TextStyle textStyle = Theme.of(context).textTheme.subtitle1!;
        return AlertDialog(
          title: const Text('Beta Testers'),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          content: Text(credit, style: textStyle),
          actions: <Widget>[
            TextButton(
              child: const Text('Awesome!!'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
