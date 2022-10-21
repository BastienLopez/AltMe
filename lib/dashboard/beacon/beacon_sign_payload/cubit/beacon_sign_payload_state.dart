part of 'beacon_sign_payload_cubit.dart';

@JsonSerializable()
class BeaconSignPayloadState extends Equatable {
  const BeaconSignPayloadState({
    this.status = AppStatus.init,
    this.message,
    this.payloadMessage,
    this.encodedPaylod,
  });

  factory BeaconSignPayloadState.fromJson(Map<String, dynamic> json) =>
      _$BeaconSignPayloadStateFromJson(json);

  final AppStatus status;
  final StateMessage? message;
  final String? payloadMessage;
  final String? encodedPaylod;

  BeaconSignPayloadState loading() {
    return BeaconSignPayloadState(
      status: AppStatus.loading,
      payloadMessage: payloadMessage,
      encodedPaylod: encodedPaylod,
    );
  }

  BeaconSignPayloadState error({
    required MessageHandler messageHandler,
  }) {
    return BeaconSignPayloadState(
      status: AppStatus.error,
      message: StateMessage.error(messageHandler: messageHandler),
      payloadMessage: payloadMessage,
      encodedPaylod: encodedPaylod,
    );
  }

  BeaconSignPayloadState copyWith({
    AppStatus appStatus = AppStatus.idle,
    MessageHandler? messageHandler,
    String? payloadMessage,
    String? encodedPaylod,
  }) {
    return BeaconSignPayloadState(
      status: appStatus,
      message: messageHandler == null
          ? null
          : StateMessage.success(messageHandler: messageHandler),
      payloadMessage: payloadMessage ?? this.payloadMessage,
      encodedPaylod: encodedPaylod ?? this.encodedPaylod,
    );
  }

  Map<String, dynamic> toJson() => _$BeaconSignPayloadStateToJson(this);

  @override
  List<Object?> get props => [status, message, payloadMessage, encodedPaylod];
}
