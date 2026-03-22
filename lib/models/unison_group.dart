class UnisonGroup {
  final String id;
  final String name;

  UnisonGroup({required this.id, required this.name});

  factory UnisonGroup.fromMap(Map<String, dynamic> message) {
    return UnisonGroup(
      id: message["id"],
      name: message["name"],
    );
  }

  static List<UnisonGroup> fromList(List<Map<String, dynamic>> messages) {
    return messages.map((element) => UnisonGroup.fromMap(element)).toList();
  }
}
