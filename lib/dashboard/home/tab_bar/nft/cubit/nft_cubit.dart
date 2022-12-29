import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/wallet/wallet.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'nft_cubit.g.dart';

part 'nft_state.dart';

class NftCubit extends Cubit<NftState> {
  NftCubit({
    required this.client,
    required this.walletCubit,
    required this.manageNetworkCubit,
  }) : super(const NftState()) {
    getTezosNftList();
  }

  final DioClient client;
  final WalletCubit walletCubit;
  final ManageNetworkCubit manageNetworkCubit;

  final int _limit = 10;
  int _offsetOfLoadedData = -1;

  List<NftModel> data = [];

  final log = getLogger('NftCubit');

  Future<void> getTezosNftList() async {
    final activeIndex = walletCubit.state.currentCryptoIndex;
    if (walletCubit.state.cryptoAccount.data[activeIndex].blockchainType !=
        BlockchainType.tezos) {
      emit(state.copyWith(status: AppStatus.idle));
      return;
    }

    if (state.offset == _offsetOfLoadedData) return;
    _offsetOfLoadedData = state.offset;
    if (data.length < state.offset) return;
    try {
      log.i('starting funtion getTezosNftList()');
      if (state.offset == 0) {
        emit(state.fetching());
      } else {
        emit(state.loading());
      }

      //final activeIndex = walletCubit.state.currentCryptoIndex;
      final walletAddress =
          walletCubit.state.cryptoAccount.data[activeIndex].walletAddress;

      final baseUrl = manageNetworkCubit.state.network.tzktUrl;

      final List<dynamic> response = await client.get(
        '$baseUrl/v1/tokens/balances',
        queryParameters: <String, dynamic>{
          'account': walletAddress,
          'balance.eq': 1,
          'token.metadata.null': false,
          'sort.desc': 'firstLevel',
          'select':
              'token.tokenId as tokenId,token.id as id,token.metadata.name as name,token.metadata.displayUri as displayUri,balance,token.metadata.thumbnailUri as thumbnailUri,token.metadata.description as description,token.standard as standard,token.metadata.symbol as symbol,token.contract.address as contractAddress,token.metadata.identifier as identifier,token.metadata.creators as creators,token.metadata.publishers as publishers,token.metadata.date as date,token.metadata.is_transferable as isTransferable', // ignore: lines_longer_than_80_chars
          'offset': state.offset,
          'limit': _limit,
        },
      ) as List<dynamic>;
      // TODO(all): check the balance variable of NFTModel
      // and get right value from api
      final List<NftModel> newData = response
          .map((dynamic e) => NftModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (state.offset == 0) {
        data = newData;
      } else {
        data.addAll(newData);
      }
      log.i('nfts - $data');
      emit(state.populate(data: data));
    } catch (e, s) {
      if (isClosed) return;
      log.e('failed to fetch nfts, e: $e, s: $s');
      emit(
        state.copyWith(
          status: state.offset == 0
              ? AppStatus.errorWhileFetching
              : AppStatus.error,
          message: StateMessage.error(
            messageHandler: ResponseMessage(
              ResponseString
                  .RESPONSE_STRING_SOMETHING_WENT_WRONG_TRY_AGAIN_LATER,
            ),
          ),
          offset: state.offset == 0 ? 0 : state.offset - 1,
        ),
      );
    }
  }

  Future<void> fetchFromZero() async {
    log.i('refreshing nft page');
    _offsetOfLoadedData = -1;
    emit(state.copyWith(offset: 0));
    await getTezosNftList();
  }

  Future<void> fetchMoreTezosNfts() async {
    log.i('fetching more nfts');
    final offset = state.offset + _limit;
    emit(state.copyWith(offset: offset));
    await getTezosNftList();
  }
}
