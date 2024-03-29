import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../herde_icons.dart';

class TypeIcon extends StatelessWidget {
  static const Map<String, IconData> icons = {
    'Cow': HerdeIcons.cow,
    'Goat': HerdeIcons.goat,
    'Cat': HerdeIcons.cat,
    'Duck': HerdeIcons.duck,
    'Dog': HerdeIcons.dog,
  };
  final String type;
  final bool showLabel;
  final bool onPrimary;
  final VoidCallback? onTap;

  const TypeIcon({
    Key? key,
    required this.type,
    this.showLabel = false,
    this.onPrimary = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    TextStyle textStyle = textTheme.headline6!.copyWith(fontWeight: FontWeight.w400);
    if (showLabel) {
      return GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(type, style: textStyle),
            const SizedBox(width: 8),
            Icon(icons[type] ?? MdiIcons.helpCircleOutline,
                color: onPrimary ? colorScheme.onPrimary : colorScheme.onBackground),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: onTap,
        child: Tooltip(
          message: type,
          child: Icon(icons[type] ?? MdiIcons.helpCircleOutline,
              color: onPrimary ? colorScheme.onPrimary : colorScheme.onBackground),
        ),
      );
    }
  }
}
