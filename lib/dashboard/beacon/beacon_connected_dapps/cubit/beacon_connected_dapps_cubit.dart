import 'package:altme/app/app.dart';
import 'package:altme/beacon/beacon.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:beacon_flutter/beacon_flutter.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'beacon_connected_dapps_cubit.g.dart';
part 'beacon_connected_dapps_state.dart';

class BeaconConnectedDappsCubit extends Cubit<BeaconConnectedDappsState> {
  BeaconConnectedDappsCubit({
    required this.beacon,
    required this.networkCubit,
    required this.client,
    required this.beaconRepository,
  }) : super(BeaconConnectedDappsState());

  final Beacon beacon;
  final ManageNetworkCubit networkCubit;
  final DioClient client;
  final BeaconRepository beaconRepository;

  final log = getLogger('BeaconConnectedDappsCubit');

  Future<void> init(String walletAddress) async {
    await getXtzData(walletAddress);
    await getPeers(walletAddress);
  }

  Future<void> getXtzData(String walletAddress) async {
    try {
      log.i('fetching xtzData');
      emit(state.loading());

      final baseUrl = networkCubit.state.network.tzktUrl;

      log.i('fetching balance');
      final int balance = await client
          .get('$baseUrl/v1/accounts/$walletAddress/balance') as int;

      final formattedBalance = balance / 1e6;

      log.i('fetching xtz USD price');
      final response = await client.get(Urls.xtzPrice) as Map<String, dynamic>;
      final XtzData xtzData = XtzData.fromJson(response);

      final xtzUSDPrice = xtzData.price!;

      final token = TokenModel(
        id: -1,
        contractAddress: '',
        name: 'Tezos',
        symbol: 'XTZ',
        icon: 'https://s2.coinmarketcap.com/static/img/coins/64x64/2011.png',
        balance: balance.toString(),
        decimals: '6',
        standard: 'fa1.2',
        tokenUSDPrice: xtzUSDPrice,
        balanceInUSD: formattedBalance * xtzUSDPrice,
      );

      emit(
        state.copyWith(status: AppStatus.idle, xtzModel: token),
      );
    } catch (e) {
      log.e('xtzData fetching failure , e: $e');
      if (e is MessageHandler) {
        emit(state.error(messageHandler: e));
      } else {
        emit(
          state.error(
            messageHandler: ResponseMessage(
              ResponseString
                  .RESPONSE_STRING_SOMETHING_WENT_WRONG_TRY_AGAIN_LATER,
            ),
          ),
        );
      }
    }
  }

  Future<void> getPeers(String walletAddress) async {
    try {
      log.i('fetching connected peers');
      emit(state.loading());

      // final peers = await beacon.getPeers();
      // final Map<String, dynamic> requestJson =
      //     jsonDecode(jsonEncode(peers)) as Map<String, dynamic>;
      // final ConnectedPeers connectedPeers =
      //     ConnectedPeers.fromJson(requestJson);
      // TODO(bibash): filter list based on paired and walletaddress

      final List<BeaconRequest> beaconRequests =
          await beaconRepository.findAll();

      final _peersList = <P2PPeer>[];
      // TODO(bibash): filter list based on walletaddress
      for (final request in beaconRequests) {
        _peersList.add(request.peer!);
      }
      emit(state.copyWith(status: AppStatus.idle, peers: _peersList));
    } catch (e) {
      log.e('getPeers failure , e: $e');
      if (e is MessageHandler) {
        emit(state.error(messageHandler: e));
      } else {
        emit(
          state.error(
            messageHandler: ResponseMessage(
              ResponseString
                  .RESPONSE_STRING_SOMETHING_WENT_WRONG_TRY_AGAIN_LATER,
            ),
          ),
        );
      }
    }
  }
}
