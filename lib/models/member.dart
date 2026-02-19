import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Member extends Equatable {
  final String? id;
  final String? name;
  final String? avatarUrl;

  /// millisecondsSinceEpoch (derivado de Timestamp no Firestore)
  final int? avatarUpdatedAtMs;

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
    this.avatarUpdatedAtMs,
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
    avatarUpdatedAtMs,
  ];

  Member copyWith({
    String? id,
    String? name,
    String? memberNumber,
    String? joiningDate,
    String? dateOfBirth,
    String? phoneNumber,
    String? email,
    bool? isActive,
    String? notes,
    int? age,
    String? avatarUrl,
    int? avatarUpdatedAtMs,
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
      avatarUpdatedAtMs: avatarUpdatedAtMs ?? this.avatarUpdatedAtMs,
    );
  }

  factory Member.fromDoc(doc) {
    final data = doc.data() as Map<String, dynamic>;

    final ts = data['avatarUpdatedAt'];
    final updatedAtMs = (ts is Timestamp) ? ts.millisecondsSinceEpoch : null;

    return Member(
      id: doc.id,
      name: data['name'] ?? 'No Name',
      memberNumber: data['memberNumber'] ?? 'No Number',
      joiningDate: data['joiningDate'] ?? 'No Joining Date',
      phoneNumber: data['phoneNumber'] ?? 'No Phone Number',
      dateOfBirth: data['dateOfBirth'] ?? 'No Date Of Birth',
      email: data['email'] ?? 'No Email',
      isActive: (data['isActive'] as bool?) ?? false,
      notes: data['notes'] ?? 'No Notes',
      avatarUrl: data['avatarUrl'],
      avatarUpdatedAtMs: updatedAtMs,
    );
  }
}
