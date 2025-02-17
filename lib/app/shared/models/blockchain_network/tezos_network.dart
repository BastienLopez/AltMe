import 'package:altme/app/app.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tezos_network.g.dart';

@JsonSerializable()
class TezosNetwork extends BlockchainNetwork {
  const TezosNetwork({
    required String networkname,
    required String apiUrl,
    required String rpcNodeUrl,
    required String title,
    required String subTitle,
    String apiKey = '',
  }) : super(
          networkname: networkname,
          apiUrl: apiUrl,
          rpcNodeUrl: rpcNodeUrl,
          title: title,
          subTitle: subTitle,
          apiKey: apiKey,
          type: BlockchainType.tezos,
        );

  factory TezosNetwork.fromJson(Map<String, dynamic> json) =>
      _$TezosNetworkFromJson(json);

  factory TezosNetwork.mainNet() => const TezosNetwork(
        networkname: 'Mainnet',
        apiUrl: Urls.tzktMainnetUrl,
        rpcNodeUrl: Urls.mainnetRPC,
        title: 'Tezos Mainnet',
        subTitle:
            'This network is the official Tezos blockchain running Network.'
            ' You should use this network by default.',
      );

  factory TezosNetwork.ghostnet() => const TezosNetwork(
        networkname: 'Ghostnet',
        apiUrl: Urls.tzktGhostnetUrl,
        rpcNodeUrl: Urls.ghostnetRPC,
        title: 'Tezos Ghostnet',
        subTitle: 'This network is used to test protocol upgrades'
            ' (do not use it unless you are a developer).',
      );

  @override
  Map<String, dynamic> toJson() => _$TezosNetworkToJson(this);
}
