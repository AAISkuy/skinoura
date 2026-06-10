class RitualModel {
  int? id;
  String title;
  String subtitle;
  bool isDone;
  String ownerEmail;

  RitualModel({
    this.id,
    required this.title,
    required this.subtitle,
    required this.isDone,
    required this.ownerEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'isDone': isDone ? 1 : 0,
      'ownerEmail': ownerEmail,
    };
  }

  factory RitualModel.fromMap(Map<String, dynamic> map) {
    return RitualModel(
      id: map['id'],
      title: map['title'],
      subtitle: map['subtitle'],
      isDone: map['isDone'] == 1,
      ownerEmail: map['ownerEmail'],
    );
  }
}