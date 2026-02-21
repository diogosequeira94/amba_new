import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'socio_repo.g.dart';

@JsonSerializable()
class MemberRepository extends Equatable {
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'memberNumber')
  final String memberNumber;
  @JsonKey(name: 'joiningDate')
  final String joiningDate;
  @JsonKey(name: 'dateOfBirth')
  final String dateOfBirth;
  @JsonKey(name: 'phoneNumber')
  final String phoneNumber;
  @JsonKey(name: 'email')
  final String email;
  @JsonKey(name: 'isActive')
  final bool isActive;
  @JsonKey(name: 'notes')
  final String notes;

  const MemberRepository({
    required this.name,
    required this.memberNumber,
    required this.joiningDate,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.email,
    required this.isActive,
    required this.notes,
  });

  @override
  List<Object?> get props => [
    name,
    memberNumber,
    joiningDate,
    dateOfBirth,
    phoneNumber,
    email,
    isActive,
  ];

  factory MemberRepository.fromJson(Map<String, dynamic> json) => _$SocioRepoFromJson(json);
}
