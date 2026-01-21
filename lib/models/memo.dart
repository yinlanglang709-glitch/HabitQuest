class Memo {
  //备忘录
  final String id;
  final String content;
  final String createdAt;

  Memo({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'content': content,
    'created_at': createdAt,
  };

  static Memo fromMap(Map<String, dynamic> map) => Memo(
    id: map['id'],
    content: map['content'],
    createdAt: map['created_at'],
  );
}