class MemberSummary {
  MemberSummary({required this.id, required this.referenceNumber, required this.name});

  final int id;
  final String? referenceNumber;
  final String name;

  factory MemberSummary.fromJson(Map<String, dynamic> json) => MemberSummary(
        id: json['id'] as int,
        referenceNumber: json['referenceNumber'] as String?,
        name: json['name'] as String,
      );
}
