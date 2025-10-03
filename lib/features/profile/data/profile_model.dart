class UserData {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String activeStatus;
  final bool verified;
  final DateTime joinDate;

  UserData({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.activeStatus,
    required this.verified,
    required this.joinDate,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json['_id'],
    username: json['username'],
    email: json['email'],
    fullName: json['full_name'],
    activeStatus: json['active_status'] ?? '',
    verified: json['verified'] ?? false,
    joinDate: DateTime.parse(json['join_date']),
  );
}
