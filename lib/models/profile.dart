class Profile {
  Profile({
    required this.id,
    required this.referenceNumber,
    required this.name,
    required this.photoUrl,
    required this.membershipStartDate,
    required this.lastRenewedYear,
    required this.unreadNotifications,
  });

  final int id;
  final String? referenceNumber;
  final String name;
  final String? photoUrl;
  final DateTime? membershipStartDate;
  final int? lastRenewedYear;
  final int unreadNotifications;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as int,
        referenceNumber: json['referenceNumber'] as String?,
        name: json['name'] as String,
        photoUrl: json['photoUrl'] as String?,
        membershipStartDate: json['membershipStartDate'] == null
            ? null
            : DateTime.parse(json['membershipStartDate'] as String),
        lastRenewedYear: json['lastRenewedYear'] as int?,
        unreadNotifications: json['unreadNotifications'] as int,
      );
}
