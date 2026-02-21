import 'package:equatable/equatable.dart';

class Member extends Equatable {
  final String? id;
  final String? name;
  final String? avatarUrl;
  final String? memberNumber;
  final String? joiningDate;
  final String? dateOfBirth;
  final String? phoneNumber;
  final String? email;
  final bool? isActive;
  final String? notes;
  final int? age;

  const Member({
    required this.id,
    required this.name,
    required this.memberNumber,
    required this.joiningDate,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.email,
    required this.isActive,
    required this.notes,
    this.age,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        memberNumber,
        joiningDate,
        dateOfBirth,
        phoneNumber,
        email,
        isActive,
        notes,
        age,
        avatarUrl,
      ];


  Member copyWith({
    final String? id,
    final String? name,
    final String? memberNumber,
    final String? joiningDate,
    final String? dateOfBirth,
    final String? phoneNumber,
    final String? email,
    final bool? isActive,
    final String? notes,
    final int? age,
    final String? avatarUrl,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      memberNumber: memberNumber ?? this.memberNumber,
      joiningDate: joiningDate ?? this.joiningDate,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      age: age ?? this.age,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  factory Member.fromDoc(doc) {
    return Member(
      id: doc.id,
      name: doc.data()['name'] ?? 'No Name',
      memberNumber: doc.data()['memberNumber'] ?? 'No Number',
      joiningDate: doc.data()['joiningDate'] ?? 'No Joining Date',
      phoneNumber: doc.data()['phoneNumber'] ?? 'No Phone Number',
      dateOfBirth: doc.data()['dateOfBirth'] ?? 'No Date Of Birth',
      email: doc.data()['email'] ?? 'No Email',
      isActive: doc.data()['isActive'] ?? 'Unknown',
      notes: doc.data()['notes'] ?? 'No Notes',
    );
  }
}
