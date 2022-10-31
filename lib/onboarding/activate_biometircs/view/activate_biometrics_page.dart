import 'package:altme/app/app.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:altme/onboarding/onboarding.dart';
import 'package:altme/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_storage/secure_storage.dart';

class ActiviateBiometricsPage extends StatelessWidget {
  const ActiviateBiometricsPage({Key? key}) : super(key: key);

  static Route route() => RightToLeftRoute<void>(
        builder: (context) => const ActiviateBiometricsPage(),
        settings: const RouteSettings(name: '/activiateBiometricsPage'),
      );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BiometricsCubit(),
      child: ActivateBiometricsView(localAuthApi: LocalAuthApi()),
    );
  }
}

class ActivateBiometricsView extends StatelessWidget {
  const ActivateBiometricsView({
    Key? key,
    required this.localAuthApi,
  }) : super(key: key);
  final LocalAuthApi localAuthApi;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BasePage(
        scrollView: false,
        padding: const EdgeInsets.symmetric(horizontal: Sizes.space2XSmall),
        titleLeading: const BackLeadingButton(),
        body: BlocBuilder<BiometricsCubit, BiometricsState>(
          builder: (context, state) {
            return Column(
              children: [
                const MStepper(
                  step: 2,
                  totalStep: 3,
                ),
                const Spacer(),
                Text(
                  l10n.activateBiometricsTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5,
                ),
                const Spacer(),
                Image.asset(
                  ImageStrings.biometrics,
                  fit: BoxFit.fitHeight,
                  height: MediaQuery.of(context).size.longestSide * 0.26,
                ),
                const SizedBox(
                  height: Sizes.spaceSmall,
                ),
                BiometricsSwitch(
                  value: state.isBiometricsEnabled,
                  onChange: (value) async {
                    final hasBiometrics = await localAuthApi.hasBiometrics();
                    if (hasBiometrics) {
                      final result = await localAuthApi.authenticate(
                        localizedReason: l10n.scanFingerprintToAuthenticate,
                      );
                      if (result) {
                        await getSecureStorage.set(
                          SecureStorageKeys.fingerprintEnabled,
                          value.toString(),
                        );
                        context
                            .read<BiometricsCubit>()
                            .setFingerprintEnabled(enabled: value);
                        await showDialog<bool>(
                          context: context,
                          builder: (context) => InfoDialog(
                            title: value
                                ? l10n.biometricsEnabledMessage
                                : l10n.biometricsDisabledMessage,
                            button: l10n.ok,
                          ),
                        );
                      }
                    } else {
                      await showDialog<bool>(
                        context: context,
                        builder: (context) => ConfirmDialog(
                          title: l10n.biometricsNotSupported,
                          subtitle: l10n
                              .yourDeviceDoseNotSupportBiometricsAuthentication,
                          yes: l10n.ok,
                        ),
                      );
                    }
                  },
                ),
                const Spacer(
                  flex: 5,
                ),
                MyGradientButton(
                  text: l10n.next,
                  onPressed: () {
                    Navigator.of(context)
                        .push<void>(OnBoardingGenPhrasePage.route());
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
