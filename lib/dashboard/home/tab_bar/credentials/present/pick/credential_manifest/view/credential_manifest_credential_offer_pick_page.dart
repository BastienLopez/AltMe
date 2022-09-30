import 'package:arago_wallet/app/app.dart';
import 'package:arago_wallet/dashboard/home/tab_bar/credentials/credential.dart';
import 'package:arago_wallet/l10n/l10n.dart';
import 'package:arago_wallet/pin_code/pin_code.dart';
import 'package:arago_wallet/scan/cubit/scan_cubit.dart';
import 'package:arago_wallet/theme/theme.dart';
import 'package:arago_wallet/wallet/wallet.dart';
import 'package:credential_manifest/credential_manifest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CredentialManifestOfferPickPage extends StatelessWidget {
  const CredentialManifestOfferPickPage({
    Key? key,
    required this.uri,
    required this.credential,
    required this.issuer,
    required this.inputDescriptorIndex,
    required this.credentialsToBePresented,
  }) : super(key: key);

  final Uri uri;
  final CredentialModel credential;
  final Issuer issuer;
  final int inputDescriptorIndex;
  final List<CredentialModel> credentialsToBePresented;

  static Route route({
    required Uri uri,
    required CredentialModel credential,
    required Issuer issuer,
    required int inputDescriptorIndex,
    required List<CredentialModel> credentialsToBePresented,
  }) {
    return MaterialPageRoute<void>(
      builder: (context) => CredentialManifestOfferPickPage(
        uri: uri,
        credential: credential,
        issuer: issuer,
        inputDescriptorIndex: inputDescriptorIndex,
        credentialsToBePresented: credentialsToBePresented,
      ),
      settings: const RouteSettings(name: '/CredentialManifestOfferPickPage'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final presentationDefinition =
            credential.credentialManifest!.presentationDefinition!;
        return CredentialManifestPickCubit(
          presentationDefinition: presentationDefinition.toJson(),
          credentialList: context.read<WalletCubit>().state.credentials,
          inputDescriptorIndex: inputDescriptorIndex,
        );
      },
      child: CredentialManifestOfferPickView(
        uri: uri,
        credential: credential,
        issuer: issuer,
        inputDescriptorIndex: inputDescriptorIndex,
        credentialsToBePresented: credentialsToBePresented,
      ),
    );
  }
}

class CredentialManifestOfferPickView extends StatelessWidget {
  const CredentialManifestOfferPickView({
    Key? key,
    required this.uri,
    required this.credential,
    required this.issuer,
    required this.inputDescriptorIndex,
    required this.credentialsToBePresented,
  }) : super(key: key);

  final Uri uri;
  final CredentialModel credential;
  final Issuer issuer;
  final int inputDescriptorIndex;
  final List<CredentialModel> credentialsToBePresented;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final PresentationDefinition presentationDefinition =
        credential.credentialManifest!.presentationDefinition!;

    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, walletState) {
        return BlocBuilder<CredentialManifestPickCubit,
            CredentialManifestPickState>(
          builder: (context, credentialManifestState) {
            final _purpose = presentationDefinition
                .inputDescriptors[inputDescriptorIndex].purpose;

            return BlocListener<ScanCubit, ScanState>(
              listener: (context, scanState) {
                if (scanState.status == ScanStatus.loading) {
                  LoadingView().show(context: context);
                } else {
                  LoadingView().hide();
                }
              },
              child: BasePage(
                title: l10n.credentialPickTitle,
                titleTrailing: const WhiteCloseButton(),
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                body: Column(
                  children: <Widget>[
                    if (_purpose != null)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          _purpose,
                          style: Theme.of(context).textTheme.credentialSubtitle,
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    if (credentialManifestState.filteredCredentialList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          l10n.credentialSelectionListEmptyError,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      )
                    else
                      Text(
                        l10n.credentialPickSelect,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    const SizedBox(height: 12),
                    ...List.generate(
                      credentialManifestState.filteredCredentialList.length,
                      (index) => CredentialsListPageItem(
                        credentialModel: credentialManifestState
                            .filteredCredentialList[index],
                        selected: credentialManifestState.selected == index,
                        onTap: () => context
                            .read<CredentialManifestPickCubit>()
                            .toggle(index),
                      ),
                    ),
                  ],
                ),
                navigation: credentialManifestState
                        .filteredCredentialList.isNotEmpty
                    ? SafeArea(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Tooltip(
                            message: l10n.credentialPickPresent,
                            child: Builder(
                              builder: (context) {
                                return MyGradientButton(
                                  onPressed: credentialManifestState.selected ==
                                          null
                                      ? null
                                      : () async {
                                          final selectedCredential =
                                              credentialManifestState
                                                      .filteredCredentialList[
                                                  credentialManifestState
                                                      .selected!];

                                          final updatedCredentials = List.of(
                                            credentialsToBePresented,
                                          )..add(selectedCredential);

                                          if (inputDescriptorIndex + 1 !=
                                              presentationDefinition
                                                  .inputDescriptors.length) {
                                            await Navigator.of(context)
                                                .pushReplacement<void, void>(
                                              CredentialManifestOfferPickPage
                                                  .route(
                                                uri: uri,
                                                credential: credential,
                                                issuer: issuer,
                                                inputDescriptorIndex:
                                                    inputDescriptorIndex + 1,
                                                credentialsToBePresented:
                                                    updatedCredentials,
                                              ),
                                            );
                                          } else {
                                            /// Authenticate
                                            bool authenticated = false;
                                            await Navigator.of(context)
                                                .push<void>(
                                              PinCodePage.route(
                                                restrictToBack: false,
                                                isValidCallback: () {
                                                  authenticated = true;
                                                },
                                              ),
                                            );

                                            if (!authenticated) {
                                              return;
                                            }

                                            await context
                                                .read<ScanCubit>()
                                                .credentialOffer(
                                                  uri: uri,
                                                  credentialModel: credential,
                                                  keyId:
                                                      SecureStorageKeys.ssiKey,
                                                  credentialsToBePresented:
                                                      updatedCredentials,
                                                  issuer: issuer,
                                                );
                                          }
                                        },
                                  text: l10n.credentialPickPresent,
                                );
                              },
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}
