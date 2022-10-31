import 'package:altme/app/shared/constants/sizes.dart';
import 'package:altme/theme/theme.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends PreferredSize {
  CustomAppBar({
    Key? key,
    this.title,
    this.leading,
    this.trailing,
  }) : super(
          key: key,
          child: Container(),
          preferredSize: const Size.fromHeight(Sizes.appBarHeight),
        );

  final String? title;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
            ),
            padding: const EdgeInsets.only(
              top: 12,
              bottom: 18,
              left: 64,
              right: 64,
            ),
            child: MyText(
              title ?? '',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.appBar,
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(
              top: 12,
              bottom: 12,
              left: 8,
              right: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                leading ?? const SizedBox(width: 16, height: 16),
                trailing ?? const SizedBox(width: 16, height: 16),
              ],
            ),
          ),
        ],
      );

  // @override
  // Size get preferredSize => const Size(300, 70);
}
