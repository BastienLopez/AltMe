part of 'manage_network_cubit.dart';

@JsonSerializable()
class ManageNetworkState extends Equatable {
  const ManageNetworkState({
    required this.network,
  });

  factory ManageNetworkState.fromJson(Map<String, dynamic> json) =>
      _$ManageNetworkStateFromJson(json);

  final BlockchainNetwork network;
  List<BlockchainNetwork> get allNetworks => [
        TezosNetwork.mainNet(),
        TezosNetwork.ghostnet(),
        EthereumNetwork.mainNet(),
      ];

  List<TezosNetwork> get tezosNetworks => [
        TezosNetwork.mainNet(),
        TezosNetwork.ghostnet(),
      ];

  List<EthereumNetwork> get ethereumNetworks => [
        EthereumNetwork.mainNet(),
      ];

  ManageNetworkState copyWith({
    BlockchainNetwork? network,
  }) {
    return ManageNetworkState(
      network: network ?? this.network,
    );
  }

  Map<String, dynamic> toJson() => _$ManageNetworkStateToJson(this);

  @override
  List<Object?> get props => [
        network,
        allNetworks,
      ];
}
