import 'package:arago_wallet/app/app.dart';
import 'package:arago_wallet/dashboard/dashboard.dart';
import 'package:arago_wallet/l10n/l10n.dart';
import 'package:arago_wallet/theme/theme.dart';
import 'package:arago_wallet/wallet/cubit/wallet_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendReceiveHomePage extends StatefulWidget {
  const SendReceiveHomePage({
    Key? key,
    required this.selectedToken,
  }) : super(key: key);

  final TokenModel selectedToken;

  static Route route({required TokenModel selectedToken}) {
    return MaterialPageRoute<void>(
      builder: (_) => SendReceiveHomePage(
        selectedToken: selectedToken,
      ),
      settings: const RouteSettings(name: '/sendReceiveHomePage'),
    );
  }

  @override
  State<SendReceiveHomePage> createState() => _SendReceiveHomePageState();
}

class _SendReceiveHomePageState extends State<SendReceiveHomePage> {
  late final dioClient = DioClient(
    context.read<ManageNetworkCubit>().state.network.tzktUrl,
    Dio(),
  );

  late final sendReceiveHomeCubit = SendReceiveHomeCubit(
    client: dioClient,
    selectedToken: widget.selectedToken,
    walletCubit: context.read<WalletCubit>(),
    tokensCubit: context.read<TokensCubit>(),
  );

  @override
  void initState() {
    Future.microtask(
      sendReceiveHomeCubit.init,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SendReceiveHomeCubit>(
      create: (_) => sendReceiveHomeCubit,
      child: const _SendReceiveHomePageView(),
    );
  }
}

class _SendReceiveHomePageView extends StatefulWidget {
  const _SendReceiveHomePageView({
    Key? key,
  }) : super(key: key);

  @override
  State<_SendReceiveHomePageView> createState() =>
      _SendReceiveHomePageViewState();
}

class _SendReceiveHomePageViewState extends State<_SendReceiveHomePageView> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BasePage(
      scrollView: false,
      titleLeading: const BackLeadingButton(),
      titleTrailing: const CryptoAccountSwitcherButton(),
      body: MultiBlocListener(
        listeners: [
          BlocListener<WalletCubit, WalletState>(
            listenWhen: (prev, next) =>
                prev.currentCryptoIndex != next.currentCryptoIndex,
            listener: (_, walletState) {
              context.read<SendReceiveHomeCubit>().init(
                    baseUrl: context
                        .read<ManageNetworkCubit>()
                        .state
                        .network
                        .tzktUrl,
                  );
            },
          ),
          BlocListener<ManageNetworkCubit, ManageNetworkState>(
            listenWhen: (prev, next) => prev.network != next.network,
            listener: (_, manageNetworkState) {
              context
                  .read<SendReceiveHomeCubit>()
                  .init(baseUrl: manageNetworkState.network.tzktUrl);
            },
          ),
          BlocListener<SendReceiveHomeCubit, SendReceiveHomeState>(
            listenWhen: (prev, next) => prev.status != next.status,
            listener: (_, sendReceiveHomeState) {
              if (sendReceiveHomeState.status == AppStatus.loading) {
                LoadingView().show(context: context);
              } else {
                LoadingView().hide();
                if (sendReceiveHomeState.status == AppStatus.error) {
                  AlertMessage.showStateMessage(
                    context: context,
                    stateMessage:
                        sendReceiveHomeState.message ?? const StateMessage(),
                  );
                }
              }
            },
          ),
        ],
        child: BlocBuilder<SendReceiveHomeCubit, SendReceiveHomeState>(
          builder: (context, state) {
            return Stack(
              fit: StackFit.expand,
              children: [
                const BackgroundCard(
                  height: double.infinity,
                  width: double.infinity,
                  margin: EdgeInsets.only(top: Sizes.icon3x / 2),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CachedImageFromNetwork(
                      state.selectedToken.iconUrl ?? '',
                      width: Sizes.icon3x,
                      height: Sizes.icon3x,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(Sizes.icon3x),
                      ),
                    ),
                    const SizedBox(
                      height: Sizes.spaceSmall,
                    ),
                    Text(
                      l10n.myTokens,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    TezosNetworkSwitcherButton(
                      onTap: () {
                        ChangeNetworkBottomSheetView.show(context: context);
                      },
                    ),
                    const SizedBox(
                      height: Sizes.spaceLarge,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText(
                          state.selectedToken.calculatedBalance.formatNumber(),
                          style: Theme.of(context).textTheme.headline4,
                          maxLength: 12,
                        ),
                        const SizedBox(
                          width: Sizes.spaceXSmall,
                        ),
                        MyText(
                          state.selectedToken.symbol,
                          style: Theme.of(context).textTheme.headline4,
                          maxLength: 8,
                        ),
                      ],
                    ),
                    MyText(
                      r'$' +
                          state.selectedToken.balanceUSDPrice
                              .toStringAsFixed(2)
                              .formatNumber(),
                      style: Theme.of(context).textTheme.normal,
                    ),
                    const SizedBox(
                      height: Sizes.spaceNormal,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.spaceSmall,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            child: MyGradientButton(
                              upperCase: false,
                              text: l10n.send,
                              verticalSpacing: 0,
                              fontSize: 16,
                              borderRadius: Sizes.smallRadius,
                              icon: Image.asset(
                                IconStrings.send,
                                width: Sizes.icon,
                              ),
                              onPressed: () {
                                Navigator.of(context).push<void>(
                                  SendToPage.route(
                                    defaultSelectedToken: state.selectedToken,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            width: Sizes.spaceNormal,
                          ),
                          Flexible(
                            child: MyGradientButton(
                              upperCase: false,
                              text: l10n.receive,
                              verticalSpacing: 0,
                              fontSize: 16,
                              borderRadius: Sizes.smallRadius,
                              icon: Image.asset(
                                IconStrings.receive,
                                width: Sizes.icon,
                              ),
                              onPressed: () {
                                Navigator.of(context).push<void>(
                                  ReceivePage.route(
                                    accountAddress: context
                                        .read<WalletCubit>()
                                        .state
                                        .currentAccount
                                        .walletAddress,
                                    tokenSymbol: state.selectedToken.symbol,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: Sizes.spaceNormal,
                    ),
                    RecentTransactions(
                      decimal: int.parse(state.selectedToken.decimals),
                      symbol: state.selectedToken.symbol,
                      tokenUsdPrice: state.selectedToken.tokenUSDPrice,
                      onRefresh: () async {
                        await context
                            .read<SendReceiveHomeCubit>()
                            .getOperations(
                              baseUrl: context
                                  .read<ManageNetworkCubit>()
                                  .state
                                  .network
                                  .tzktUrl,
                            );
                      },
                      operations: state.operations,
                    )
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
