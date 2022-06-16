import 'package:altme/home/home.dart';
import 'package:credential_manifest/credential_manifest.dart';
import 'package:flutter/material.dart';

class DisplayPropertiesWidget extends StatelessWidget {
  const DisplayPropertiesWidget({
    this.properties,
    required this.item,
    this.textColor,
    Key? key,
  }) : super(key: key);

  final List<DisplayMapping>? properties;
  final CredentialModel item;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    properties?.forEach((element) {
      widgets.add(
        LabeledDisplayMappingWidget(
          displayMapping: element,
          item: item,
          textColor: textColor,
        ),
      );
    });
    if (widgets.isNotEmpty) {
      return Column(
        children: widgets,
      );
    }
    return const SizedBox.shrink();
  }
}
