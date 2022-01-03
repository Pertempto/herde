import 'package:confetti/confetti.dart';
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
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((value) {
      setState(() {
        appVersion = 'v' + value.version;
      });
    });

    _confettiController = ConfettiController(duration: const Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String iconCredits = '''
App Icon by Addison Emig
Goat by Laymik from NounProject.com
Cow by Laymik from NounProject.com
Egyptian Cat by Laymik from NounProject.com
''';
    const String verse = '''
He blesseth them also, so that they are multiplied greatly; and suffereth not their cattle to decrease.
''';
    Widget body = ListView(children: [
      const ListItem(title: 'Developed By', value: 'Addison Emig'),
      ListItem(title: 'App Version', value: appVersion, onTap: _easterEgg),
      const ListItem(title: 'Icon Credits', subtitle: iconCredits),
      const ListItem(title: 'Psalm 107:38', subtitle: verse),
    ]);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('About')),
          body: body,
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
              confettiController: _confettiController,
              emissionFrequency: 1,
              numberOfParticles: 1,
              maxBlastForce: 25,
              minBlastForce: 5,
              gravity: 0.1,
              particleDrag: 0.07,
              blastDirectionality: BlastDirectionality.explosive,
              colors: [Theme.of(context).colorScheme.primary]),
        )
      ],
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
                onPressed: () {
                  Navigator.of(context).pop();
                  _confettiController.play();
                }),
          ],
        );
      },
    );
  }
}
