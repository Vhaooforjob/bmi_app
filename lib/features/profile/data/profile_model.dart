class UserData {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String activeStatus;
  final bool verified;
  final DateTime joinDate;

  final DateTime? birthdate;
  final String? sex;

  UserData({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.activeStatus,
    required this.verified,
    required this.joinDate,
    this.birthdate,
    this.sex,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json['_id'],
    username: json['username'],
    email: json['email'],
    fullName: json['full_name'],
    activeStatus: json['active_status']?.toString() ?? '',
    verified: json['verified'] ?? false,
    joinDate: DateTime.parse(json['join_date']),
    birthdate:
        json['birthdate'] != null ? DateTime.tryParse(json['birthdate']) : null,
    sex: json['sex']?.toString(),
  );

  Map<String, dynamic> toUpdatePayload() => {
    'username': username,
    'email': email,
    'full_name': fullName,
    if (birthdate != null) 'birthdate': birthdate!.toUtc().toIso8601String(),
    if (sex != null) 'sex': sex,
  };
}
