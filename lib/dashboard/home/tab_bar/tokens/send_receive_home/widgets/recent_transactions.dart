import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:altme/theme/theme.dart';
import 'package:flutter/material.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({
    Key? key,
    this.operations = const [],
    required this.onRefresh,
  }) : super(key: key);

  final List<OperationModel> operations;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(Sizes.spaceSmall),
        padding: const EdgeInsets.all(Sizes.spaceSmall),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(Sizes.normalRadius),
          ),
          color: Theme.of(context).hoverColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              l10n.recentTransactions,
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(
              height: Sizes.spaceNormal,
            ),
            Expanded(
              child: operations.isEmpty
                  ? Container()
                  : RefreshIndicator(
                      onRefresh: onRefresh,
                      child: ListView.separated(
                        itemBuilder: (_, index) => TransactionItem(
                          operationModel: operations[index],
                        ),
                        separatorBuilder: (_, __) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: Sizes.spaceSmall,
                            ),
                            child: Divider(
                              height: 0.2,
                              color: Theme.of(context).colorScheme.borderColor,
                            ),
                          );
                        },
                        itemCount: operations.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
