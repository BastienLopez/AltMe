part of 'credential_manifest_pick_cubit.dart';

@JsonSerializable()
class CredentialManifestPickState extends Equatable {
  const CredentialManifestPickState({
    this.selected,
    required this.filteredCredentialList,
  });

  factory CredentialManifestPickState.fromJson(Map<String, dynamic> json) =>
      _$CredentialManifestPickStateFromJson(json);

  final int? selected;
  final List<CredentialModel> filteredCredentialList;

  CredentialManifestPickState copyWith({
    int? selected,
    List<CredentialModel>? filteredCredentialList,
  }) {
    return CredentialManifestPickState(
      selected: selected ?? this.selected,
      filteredCredentialList:
          filteredCredentialList ?? this.filteredCredentialList,
    );
  }

  Map<String, dynamic> toJson() => _$CredentialManifestPickStateToJson(this);

  @override
  List<Object?> get props => [
        selected,
        filteredCredentialList,
      ];
}
