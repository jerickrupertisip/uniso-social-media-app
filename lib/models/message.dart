class Message {
  final String content;
  final DateTime createdAt;

  Message({required this.content, required this.createdAt});

  factory Message.fromMap(Map<String, dynamic> message) {
    return Message(
      content: message["content"],
      createdAt: DateTime.parse(message["created_at"]),
    );
  }

  static List<Message> fromList(List<Map<String, dynamic>> messages) {
    return messages.map((element) => Message.fromMap(element)).toList();
  }
}
