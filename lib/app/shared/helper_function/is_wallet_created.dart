import 'package:altme/app/shared/constants/constants.dart';
import 'package:altme/did/did.dart';
import 'package:altme/wallet/cubit/wallet_cubit.dart';
import 'package:secure_storage/secure_storage.dart';

Future<bool> isWalletCreated({
  required SecureStorageProvider secureStorageProvider,
  required DIDCubit didCubit,
  required WalletCubit walletCubit,
}) async {
  final String? key =
      await secureStorageProvider.get('${SecureStorageKeys.key}/0');
  if (key == null || key.isEmpty) {
    return false;
  }

  final String? did = await secureStorageProvider.get(SecureStorageKeys.did);

  if (did == null || did.isEmpty) {
    return false;
  }

  final String? didMethod =
      await secureStorageProvider.get(SecureStorageKeys.didMethod);
  if (didMethod == null || didMethod.isEmpty) {
    return false;
  }

  final String? didMethodName =
      await secureStorageProvider.get(SecureStorageKeys.didMethodName);
  if (didMethodName == null || didMethodName.isEmpty) {
    return false;
  }

  final String? verificationMethod =
      await secureStorageProvider.get(SecureStorageKeys.verificationMethod);
  if (verificationMethod == null || verificationMethod.isEmpty) {
    return false;
  }

  final String? walletAddress =
      await secureStorageProvider.get('${SecureStorageKeys.walletAddresss}/0');
  if (walletAddress == null || walletAddress.isEmpty) {
    return false;
  }

  final String? isEnterprise =
      await secureStorageProvider.get(SecureStorageKeys.isEnterpriseUser);

  if (isEnterprise != null && isEnterprise.isNotEmpty) {
    if (isEnterprise == 'true') {
      final rsaKeyJson =
          await secureStorageProvider.get(SecureStorageKeys.rsaKeyJson);
      if (rsaKeyJson == null || rsaKeyJson.isEmpty) {
        return false;
      }
    }
  }

  await didCubit.load(
    did: did,
    didMethod: didMethod,
    didMethodName: didMethodName,
    verificationMethod: verificationMethod,
  );

  final String? currentAccountIndex =
      await secureStorageProvider.get(SecureStorageKeys.currentAccountIndex);
  if (currentAccountIndex == null || currentAccountIndex.isEmpty) {
    return false;
  }

  await walletCubit.setCurrentWalletAccount(int.parse(currentAccountIndex));

  return true;
}
