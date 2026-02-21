// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'socio_repo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberRepository _$SocioRepoFromJson(Map<String, dynamic> json) => MemberRepository(
      name: json['name'] as String,
      memberNumber: json['memberNumber'] as String,
      joiningDate: json['joiningDate'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      isActive: json['isActive'] as bool,
      notes: json['notes'] as String,
    );

Map<String, dynamic> _$SocioRepoToJson(MemberRepository instance) => <String, dynamic>{
      'name': instance.name,
      'memberNumber': instance.memberNumber,
      'joiningDate': instance.joiningDate,
      'dateOfBirth': instance.dateOfBirth,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'isActive': instance.isActive,
      'notes': instance.notes,
    };
