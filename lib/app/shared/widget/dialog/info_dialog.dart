import 'package:altme/app/app.dart';
import 'package:altme/theme/theme.dart';
import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  const InfoDialog({
    Key? key,
    required this.title,
    this.subtitle,
    required this.button,
    this.icon = IconStrings.cardReceive,
    this.dialogColor,
    this.bgColor,
    this.textColor,
  }) : super(key: key);

  final String title;
  final String? subtitle;
  final String button;
  final Color? dialogColor;
  final Color? bgColor;
  final Color? textColor;
  final String icon;

  @override
  Widget build(BuildContext context) {
    final color = dialogColor ?? Theme.of(context).colorScheme.primary;
    final background = bgColor ?? Theme.of(context).colorScheme.onBackground;
    final text = textColor ?? Theme.of(context).colorScheme.dialogText;
    return AlertDialog(
      backgroundColor: background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ImageIcon(
            AssetImage(icon),
            size: 50,
            color: color,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style:
                Theme.of(context).textTheme.dialogTitle.copyWith(color: text),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: Theme.of(context)
                  .textTheme
                  .dialogSubtitle
                  .copyWith(color: text),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: MyElevatedButton(
              text: button,
              verticalSpacing: 8,
              backgroundColor: color,
              textColor: background,
              fontSize: 13,
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ),
        ],
      ),
    );
  }
}
