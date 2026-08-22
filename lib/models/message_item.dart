class MessageItem {
  MessageItem({required this.id, required this.senderType, required this.body, required this.createdAt});

  final int id;
  final String senderType; // "member" or "admin"
  final String body;
  final DateTime createdAt;

  bool get isFromMember => senderType == 'member';

  factory MessageItem.fromJson(Map<String, dynamic> json) => MessageItem(
        id: json['id'] as int,
        senderType: json['senderType'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
