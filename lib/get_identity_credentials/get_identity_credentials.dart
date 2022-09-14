import 'dart:convert';

import 'package:altme/app/shared/dio_client/dio_client.dart';
import 'package:altme/dashboard/home/tab_bar/credentials/models/activity/activity.dart';
import 'package:altme/dashboard/home/tab_bar/credentials/models/credential_model/credential_model.dart';
import 'package:altme/wallet/wallet.dart';
import 'package:did_kit/did_kit.dart';
import 'package:secure_storage/secure_storage.dart' as secure_storage;

/// At the end of PassBase Process the wallet get identityAccessKey which
/// is used as preAuthorizedCode to get the identity credentials of the user.
/// That’s a 4 steps process:
/// 1/ Wallet get credential_manifest from https://issuer.talao.co/.well-known/openid-configuration
/// 2/ Wallet extract list of credential types from in the credential_manifest
/// 3/ After 5 minutes wallet ask a token to tokenEndPoint and provide preAuthorizedCode
/// 4/ For each credential type of the list, wallet is getting the credential from credentialEndPoint, providing accessToken and credentialType

Future<void> getIdentityCredentials(
  String preAuthorizedCode,
  DioClient client,
  WalletCubit walletCubit,
) async {
  print('in the place');
// TODO(all): getCredentialManifest()
// address of well_known containing credential manifest: https://issuer.talao.co/.well-known/openid-configuration
// TODO(all): getCredentialTypesList (credential manifest)
  const List<String> credentialTypeList = [
    'Over18',
    'AgeRange',
    'Gender',
    'IdCard',
    'EmailPass'
  ];

// Wait 5 minutes
  // Future.delayed(const Duration(minutes: 5), () async {
  const String tokenEndPoint = 'https://issuer.talao.co/token';
  const String credentialEndPoint = 'https://issuer.talao.co/credential';
  final dynamic accessTokenAndNonce =
      await getAccessToken(tokenEndPoint, preAuthorizedCode, client);
  final dynamic data = accessTokenAndNonce is String
      ? jsonDecode(accessTokenAndNonce)
      : accessTokenAndNonce;
  final String accessToken = data['access_token'] as String;
  final String nonce = data['c_nonce'] as String;
  for (final type in credentialTypeList) {
    final dynamic credential = await getCredential(
        accessToken, nonce, credentialEndPoint, type, client);
    if (credential != null) {
      final Map<String, dynamic> newCredential =
          Map<String, dynamic>.from(credential as Map<String, dynamic>);
      newCredential['credentialPreview'] = credential;

      final credentialModel = CredentialModel.copyWithData(
        oldCredentialModel: CredentialModel.fromJson(
          newCredential,
        ),
        newData: credential,
        activities: [Activity(acquisitionAt: DateTime.now())],
      );
      await walletCubit.insertCredential(
        CredentialModel.fromJson(
          newCredential,
        ),
      );
    }
  }
// show popup telling user he will receive multiple credentials
// 	Loop on credential types to get each credentials

// 	GetCredential(accessToken, credentialEndPoint, credentialType)
  // });
}

Future<dynamic> getCredential(
  String accessToken,
  String nonce,
  String credentialEndPoint,
  String type,
  DioClient client,
) async {
  try {
    final secureStorageProvider = secure_storage.getSecureStorage;
    // final did = (await secureStorageProvider.get(SecureStorageKeys.did))!;
    const did = 'did:key:z6Mkmtke1zQpoa21FnkHobmfMPw478SzLkRj9ZTujaFRg39u';

    /// If credential manifest exist we follow instructions to present
    /// credential
    /// If credential manifest doesn't exist we add DIDAuth to the post
    /// If id was in preview we send it in the post
    ///  https://github.com/TalaoDAO/wallet-interaction/blob/main/README.md#credential-offer-protocol
    ///
    // final key = (await secureStorageProvider.get(SecureStorageKeys.ssiKey))!;
    const key =
        '{"kty":"OKP","crv":"Ed25519","d":"g6lh_xxgQyoconYGSbsiJut9EoKiq0_3E0EKK1z4MQE=","x":"bomo2KEz8xbRzuckXmQW17WJzUWHAolOUF54SYRB_-Q="}';
    final verificationMethod =
        'did:key:z6Mkmtke1zQpoa21FnkHobmfMPw478SzLkRj9ZTujaFRg39u#z6Mkmtke1zQpoa21FnkHobmfMPw478SzLkRj9ZTujaFRg39u';
    // final verificationMethod =
    //     await secureStorageProvider.get(SecureStorageKeys.verificationMethod);

    final options = <String, dynamic>{
      'verificationMethod': verificationMethod,
      'proofPurpose': 'authentication',
      'challenge': nonce,
      'domain': 'issuer.talao.co',
    };

    final DIDKitProvider didKitProvider = DIDKitProvider();
    final String did_auth = await didKitProvider.didAuth(
      did,
      jsonEncode(options),
      key,
    );
    print('didKit version: ${didKitProvider.getVersion()}');
    final verif = await didKitProvider.verifyPresentation(did_auth, '{}');
    print('type: $type');
    final dynamic response = await client.post(
      credentialEndPoint,
      headers: <String, dynamic>{
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      data: <String, dynamic>{
        'type': type,
        'format': 'ldp_vc',
        'did': did,
        'proof': {'proof_type': 'ldp_vp', 'vp': did_auth}
      },
    );
    print('got the response 2');
    return jsonDecode(response['credential'] as String);
  } catch (e) {
    print('got a problem 2');
  }
}

Future<dynamic> getAccessToken(
  String tokenEndPoint,
  String preAuthorizedCode,
  DioClient client,
) async {
  print('you really want to do this?');
  try {
    final dynamic response = await client.post(
      'https://issuer.talao.co/token',
      headers: <String, dynamic>{
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer mytoken',
        'X-API-KEY': '99999-99999-99999',
      },
      data: <String, dynamic>{
        'pre-authorized_code': preAuthorizedCode,
        'grant_type': 'urn:ietf:params:oauth:grant-type:pre-authorized_code',
      },
    );
    print('got the response');
    return response;
  } catch (e) {
    print('got a problem');
  }
}
