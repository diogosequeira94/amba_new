import 'package:amba_new/features/members/models/member.dart';
import 'package:equatable/equatable.dart';

class PhoneMessageMember extends Equatable {
  final String memberNumber;
  final String name;
  final String phoneNumber;
  final bool isSelected;

  const PhoneMessageMember({
    required this.memberNumber,
    required this.name,
    required this.phoneNumber,
    required this.isSelected,
  });

  factory PhoneMessageMember.fromMember(Member member) {
    return PhoneMessageMember(
      memberNumber: member.memberNumber!,
      name: member.name!,
      phoneNumber: member.phoneNumber!,
      isSelected: false,
    );
  }

  @override
  List<Object?> get props => [
        memberNumber,
        name,
        phoneNumber,
        isSelected,
      ];

  PhoneMessageMember copyWith({
    final String? memberNumber,
    final String? name,
    final String? phoneNumber,
    final bool? isSelected,
  }) {
    return PhoneMessageMember(
      memberNumber: memberNumber ?? this.memberNumber,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
