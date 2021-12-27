import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../herde_icons.dart';

class AnimalIcon extends StatelessWidget {
  static const Map<String, IconData> icons = {'Cow': HerdeIcons.cow, 'Goat': HerdeIcons.goat, 'Cat': HerdeIcons.cat};
  final String type;
  final bool showLabel;

  const AnimalIcon({required this.type, this.showLabel = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    TextStyle textStyle = textTheme.headline6!.copyWith(fontWeight: FontWeight.w400);
    if (showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(type, style: textStyle),
          const SizedBox(width: 8),
          Icon(icons[type] ?? MdiIcons.helpCircleOutline, color: Colors.black54),
        ],
      );
    } else {
      return Tooltip(
        message: type,
        child: Icon(icons[type] ?? MdiIcons.helpCircleOutline, color: Colors.black54),
      );
    }
  }
}
