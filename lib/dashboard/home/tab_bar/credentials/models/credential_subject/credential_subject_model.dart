import 'package:arago_wallet/app/app.dart';
import 'package:arago_wallet/dashboard/dashboard.dart';
import 'package:json_annotation/json_annotation.dart';

part 'credential_subject_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CredentialSubjectModel {
  CredentialSubjectModel({
    this.id,
    this.type,
    this.issuedBy,
    required this.credentialSubjectType,
    required this.credentialCategory,
  });

  factory CredentialSubjectModel.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'MembershipCard_1':
        return TezotopiaMembershipModel.fromJson(json);
      case 'Nationality':
        return NationalityModel.fromJson(json);
      case 'ResidentCard':
        return ResidentCardModel.fromJson(json);
      case 'Gender':
        return GenderModel.fromJson(json);
      case 'TezosAssociatedAddress':
        return TezosAssociatedAddressModel.fromJson(json);
      case 'SelfIssued':
        return SelfIssuedModel.fromJson(json);
      case 'IdentityPass':
        return IdentityPassModel.fromJson(json);
      case 'IdCard':
        return IdentityCardModel.fromJson(json);
      case 'Voucher':
        return VoucherModel.fromJson(json);
      case 'TezVoucher_1':
        return TezotopiaVoucherModel.fromJson(json);
      case 'Ecole42LearningAchievement':
        return Ecole42LearningAchievementModel.fromJson(json);
      case 'LoyaltyCard':
        return LoyaltyCardModel.fromJson(json);
      case 'Over18':
        return Over18Model.fromJson(json);
      case 'ProfessionalStudentCard':
        return ProfessionalStudentCardModel.fromJson(json);
      case 'StudentCard':
        return StudentCardModel.fromJson(json);
      case 'CertificateOfEmployment':
        return CertificateOfEmploymentModel.fromJson(json);
      case 'EmailPass':
        return EmailPassModel.fromJson(json);
      case 'AgeRange':
        return AgeRangeModel.fromJson(json);
      case 'PhonePass':
        return PhonePassModel.fromJson(json);
      case 'ProfessionalExperienceAssessment':
        return ProfessionalExperienceAssessmentModel.fromJson(json);
      case 'ProfessionalSkillAssessment':
        return ProfessionalSkillAssessmentModel.fromJson(json);
      case 'LearningAchievement':
        return LearningAchievementModel.fromJson(json);
      case 'TalaoCommunity':
        return TalaoCommunityCardModel.fromJson(json);
    }
    return DefaultCredentialSubjectModel.fromJson(json);
  }

  final String? id;
  final String? type;
  @JsonKey(fromJson: fromJsonAuthor)
  final Author? issuedBy;
  final CredentialSubjectType credentialSubjectType;
  final CredentialCategory credentialCategory;

  Map<String, dynamic> toJson() => _$CredentialSubjectModelToJson(this);

  static Author fromJsonAuthor(dynamic json) {
    if (json == null || json == '') {
      return const Author('', '');
    }
    return Author.fromJson(json as Map<String, dynamic>);
  }
}
