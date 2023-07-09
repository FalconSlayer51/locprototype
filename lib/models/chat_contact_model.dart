class ChatContact {
  final String username;
  final String profilePic;
  final String contactId;
  final DateTime timeSent;
  final String lastMessage;

  ChatContact({
    required this.contactId,
    required this.lastMessage,
    required this.profilePic,
    required this.timeSent,
    required this.username,
  });

  Map<String, dynamic> toMap() {
    return {
      'contactId': contactId,
      'lastMessage': lastMessage,
      'profilePic': profilePic,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'username': username,
    };
  }

  factory ChatContact.fromMap(Map<String, dynamic> map) {
    return ChatContact(
      contactId: map['contactId'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      profilePic: map['profilePic'] ?? '',
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      username: map['username'] ?? '',
    );
  }
}
