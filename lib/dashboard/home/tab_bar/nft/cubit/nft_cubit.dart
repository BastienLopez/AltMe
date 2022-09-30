import 'package:arago_wallet/app/app.dart';
import 'package:arago_wallet/dashboard/dashboard.dart';
import 'package:arago_wallet/wallet/wallet.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'nft_cubit.g.dart';

part 'nft_state.dart';

class NftCubit extends Cubit<NftState> {
  NftCubit({
    required this.client,
    required this.walletCubit,
  }) : super(const NftState()) {
    getTezosNftList(offset: 0);
  }

  final DioClient client;
  final WalletCubit walletCubit;

  List<NftModel> data = [];

  Future<void> getTezosNftList({
    String baseUrl = '',
    required int offset,
    int limit = 15,
  }) async {
    if (data.length < offset) return;
    try {
      if (offset == 0) {
        emit(state.fetching());
      }
      final activeIndex = walletCubit.state.currentCryptoIndex;
      final walletAddress =
          walletCubit.state.cryptoAccount.data[activeIndex].walletAddress;
      final List<dynamic> response = await client.get(
        '$baseUrl/v1/tokens/balances',
        queryParameters: <String, dynamic>{
          'account': walletAddress,
          'balance.eq': 1,
          'select':
              'token.tokenId as id,token.metadata.name as name,token.metadata.displayUri as displayUri,balance', // ignore: lines_longer_than_80_chars
          'offset': offset,
          'limit': limit,
        },
      ) as List<dynamic>;
      // TODO(all): check the balance variable of NFTModel
      // and get right value from api
      final List<NftModel> newData = response
          // .where(
          //   (dynamic json) => json['displayUri'] != null,
          // )
          // .where(
          //   (dynamic json) => json['balance'] != '0',
          // )
          .map((dynamic e) => NftModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (offset == 0) {
        data = newData;
      } else {
        data.addAll(newData);
      }
      emit(state.populate(data: data));
    } catch (e) {
      if (isClosed) return;
      emit(
        state.errorWhileFetching(
          messageHandler: ResponseMessage(
            ResponseString.RESPONSE_STRING_SOMETHING_WENT_WRONG_TRY_AGAIN_LATER,
          ),
        ),
      );
    }
  }
}
