import 'package:arago_wallet/app/app.dart';
import 'package:arago_wallet/beacon/beacon.dart';
import 'package:arago_wallet/dashboard/dashboard.dart';
import 'package:arago_wallet/l10n/l10n.dart';
import 'package:arago_wallet/onboarding/first/onboarding_first.dart';
import 'package:arago_wallet/pin_code/pin_code.dart';
import 'package:arago_wallet/scan/scan.dart';
import 'package:arago_wallet/splash/splash.dart';
import 'package:arago_wallet/wallet/wallet.dart';
import 'package:beacon_flutter/beacon_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final splashBlocListener = BlocListener<SplashCubit, SplashState>(
  listener: (BuildContext context, SplashState state) {
    if (state.status == SplashStatus.routeToPassCode) {
      Navigator.of(context).push<void>(
        PinCodePage.route(
          isValidCallback: () {
            Navigator.of(context).push<void>(DashboardPage.route());
          },
        ),
      );
    }

    if (state.status == SplashStatus.routeToOnboarding) {
      Navigator.of(context).push<void>(OnBoardingFirstPage.route());
    }
  },
);

final walletBlocListener = BlocListener<WalletCubit, WalletState>(
  listener: (BuildContext context, WalletState state) {
    if (state.message != null) {
      AlertMessage.showStateMessage(
        context: context,
        stateMessage: state.message!,
      );
    }
    if (state.status == WalletStatus.delete) {
      Navigator.of(context).pop();
    }
    if (state.status == WalletStatus.reset) {
      /// Removes every stack except first route (splashPage)
      Navigator.pushAndRemoveUntil<void>(
        context,
        DashboardPage.route(),
        (Route<dynamic> route) => route.isFirst,
      );
    }
  },
);

final scanBlocListener = BlocListener<ScanCubit, ScanState>(
  listener: (BuildContext context, ScanState state) async {
    final l10n = context.l10n;

    if (state.message != null) {
      AlertMessage.showStateMessage(
        context: context,
        stateMessage: state.message!,
      );
    }

    if (state.status == ScanStatus.askPermissionDidAuth) {
      final scanCubit = context.read<ScanCubit>();
      final state = scanCubit.state;
      final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => ConfirmDialog(
              title:
                  '''${l10n.credentialPresentTitleDIDAuth}\n\n${l10n.confimrDIDAuth}''',
              yes: l10n.showDialogYes,
              no: l10n.showDialogNo,
            ),
          ) ??
          false;

      if (confirm) {
        await scanCubit.getDIDAuthCHAPI(
          keyId: state.keyId!,
          done: state.done!,
          uri: state.uri!,
          challenge: state.challenge!,
          domain: state.domain!,
        );
      } else {
        Navigator.of(context).pop();
      }
    }
    if (state.status == ScanStatus.success) {
      Navigator.of(context).pop();
    }
    if (state.status == ScanStatus.error) {
      Navigator.of(context).pop();
    }
  },
);

final qrCodeBlocListener = BlocListener<QRCodeScanCubit, QRCodeScanState>(
  listener: (BuildContext context, QRCodeScanState state) async {
    final l10n = context.l10n;

    if (state.status == QrScanStatus.loading) {
      LoadingView().show(context: context);
    } else {
      LoadingView().hide();
    }

    if (state.status == QrScanStatus.acceptHost) {
      if (state.uri != null) {
        final profileCubit = context.read<ProfileCubit>();
        var approvedIssuer = Issuer.emptyIssuer(state.uri!.host);
        final isIssuerVerificationSettingTrue =
            profileCubit.state.model.issuerVerificationUrl != '';
        if (isIssuerVerificationSettingTrue) {
          try {
            approvedIssuer = await CheckIssuer(
              DioClient(Urls.checkIssuerTalaoUrl, Dio()),
              profileCubit.state.model.issuerVerificationUrl,
              state.uri!,
            ).isIssuerInApprovedList();
          } catch (e) {
            if (e is MessageHandler) {
              await context.read<QRCodeScanCubit>().emitError(e);
            } else {
              await context.read<QRCodeScanCubit>().emitError(
                    ResponseMessage(
                      ResponseString
                          .RESPONSE_STRING_SOMETHING_WENT_WRONG_TRY_AGAIN_LATER,
                    ),
                  );
            }
            return;
          }
        }

        var acceptHost = true;

        if (approvedIssuer.did.isEmpty) {
          acceptHost = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmDialog(
                    title: l10n.scanPromptHost,
                    subtitle: (approvedIssuer.did.isEmpty)
                        ? state.uri!.host
                        : '''${approvedIssuer.organizationInfo.legalName}\n${approvedIssuer.organizationInfo.currentAddress}''',
                    yes: l10n.communicationHostAllow,
                    no: l10n.communicationHostDeny,
                    //lock: state.uri!.scheme == 'http',
                  );
                },
              ) ??
              false;
        }

        if (acceptHost) {
          await context.read<QRCodeScanCubit>().accept(
                uri: state.uri!,
                issuer: approvedIssuer,
              );
        } else {
          await context.read<QRCodeScanCubit>().emitError(
                ResponseMessage(
                  ResponseString.RESPONSE_STRING_SCAN_REFUSE_HOST,
                ),
              );
          return;
        }
      }
    }

    if (state.status == QrScanStatus.success) {
      if (state.route != null) {
        if (state.isDeepLink) {
          await Navigator.of(context).push<void>(state.route!);
        } else {
          await Navigator.of(context).pushReplacement<void, void>(state.route!);
        }
      }
    }

    if (state.message != null) {
      AlertMessage.showStateMessage(
        context: context,
        stateMessage: state.message!,
      );
    }
  },
);

final beaconBlocListener = BlocListener<BeaconCubit, BeaconState>(
  listener: (BuildContext context, BeaconState state) {
    final manageNetworkCubit = context.read<ManageNetworkCubit>();

    final Beacon beacon = Beacon();

    final incomingNetworkType =
        describeEnum(state.beaconRequest!.request!.network!.type!);
    final currentNetworkType =
        manageNetworkCubit.state.network.networkname.toLowerCase();

    // if network type does not match
    if (incomingNetworkType != currentNetworkType) {
      final MessageHandler messageHandler = ResponseMessage(
        ResponseString.RESPONSE_STRING_SWITCH_NETWORK_MESSAGE,
      );
      final String message = messageHandler.getMessage(context, messageHandler);

      AlertMessage.showStringMessage(
        context: context,
        message: '$message $incomingNetworkType.',
        messageType: MessageType.error,
      );

      final requestId = state.beaconRequest!.request!.id!;

      if (state.status == BeaconStatus.permission) {
        beacon.permissionResponse(
          id: requestId,
          publicKey: null,
          address: null,
        );
        Navigator.pop(context);
      }
      if (state.status == BeaconStatus.signPayload) {
        beacon.signPayloadResponse(id: requestId, signature: null);
      }
      if (state.status == BeaconStatus.operation) {
        beacon.operationResponse(id: requestId, transactionHash: null);
      }

      return;
    }

    if (state.status == BeaconStatus.permission) {
      Navigator.of(context).pushReplacement<void, void>(
        BeaconConfirmConnectionPage.route(),
      );
    }
    if (state.status == BeaconStatus.signPayload) {
      Navigator.of(context).push<void>(BeaconSignPayloadPage.route());
    }
    if (state.status == BeaconStatus.operation) {
      Navigator.of(context).push<void>(BeaconOperationPage.route());
    }
  },
);
